-- End-to-end ledger test. Run AFTER the ledger migration inside a transaction
-- that is never committed: the final RAISE aborts it on purpose, so nothing
-- persists whether the tests pass or fail. Success message: LEDGER_TESTS_PASSED.
do $$
declare
  a uuid := gen_random_uuid();
  b uuid := gen_random_uuid();
  pm uuid;
  v numeric;
  v2 numeric;
  usd numeric;
  msg text;
  failed boolean;
begin
  -- Fixtures ---------------------------------------------------------------
  insert into auth.users (id, email, aud, role, instance_id)
  values (a, 'ledger-a@test.invalid', 'authenticated', 'authenticated', '00000000-0000-0000-0000-000000000000'),
         (b, 'ledger-b@test.invalid', 'authenticated', 'authenticated', '00000000-0000-0000-0000-000000000000');
  insert into public.wallets (id, wallet_id, balance, status, currency)
  values (a, 'KWPLEDGERA', 0, 'Active', 'USD'), (b, 'KWPLEDGERB', 0, 'Active', 'USD');
  insert into public.tourism_merchants (code, name, category, location, country, currency, available, status)
  values ('ledger_test_op', 'Ledger Test Operator', 'tour', 'Accra', 'GH', 'GHS', 0, 'live');
  insert into public.payment_providers (id, display_name, supports_collections, supports_payouts, is_active)
  values ('ledger_test_gw', 'Ledger Test Gateway', true, true, true);

  perform set_config('request.jwt.claim.sub', a::text, true);
  perform set_config('request.jwt.claims', json_build_object('sub', a, 'role', 'authenticated')::text, true);

  -- 1. Top-up settles from the gateway collections pool ---------------------
  insert into public.transactions (wallet_id, type, amount, currency, status, description, reference, provider)
  values (a, 'Top Up', 100, 'GHS', 'Pending', 'test top-up', 'KWP-TXN-LEDGERTEST-1', 'ledger_test_gw');
  perform public.settle_provider_transaction('KWP-TXN-LEDGERTEST-1', 'Completed', 'evt-1');
  select available into v from public.wallet_balances where wallet_id = a and currency = 'GHS';
  if v is distinct from 100 then raise exception 'T1 top-up: expected A GHS 100, got %', v; end if;

  -- settling again is a no-op (idempotent)
  perform public.settle_provider_transaction('KWP-TXN-LEDGERTEST-1', 'Completed', 'evt-1');
  select available into v from public.wallet_balances where wallet_id = a and currency = 'GHS';
  if v is distinct from 100 then raise exception 'T1b repeat settle changed balance: %', v; end if;

  -- 2. Transfer A -> B ------------------------------------------------------
  perform public.transfer_funds('KWPLEDGERB', 30, 'KWP-TXN-LEDGERTEST-2', 'GHS');
  select available into v from public.wallet_balances where wallet_id = a and currency = 'GHS';
  select available into v2 from public.wallet_balances where wallet_id = b and currency = 'GHS';
  if v <> 70 or v2 <> 30 then raise exception 'T2 transfer: expected A 70 / B 30, got % / %', v, v2; end if;

  -- 3. Merchant payment ------------------------------------------------------
  perform public.pay_operator_bill('ledger_test_op', 'BOOK1234', 20, 'GHS', 'KWP-TXN-LEDGERTEST-3');
  select available into v from public.wallet_balances where wallet_id = a and currency = 'GHS';
  select available into v2 from public.tourism_merchants where code = 'ledger_test_op';
  if v <> 50 or v2 <> 20 then raise exception 'T3 merchant: expected A 50 / merchant 20, got % / %', v, v2; end if;

  -- 4. FX conversion is rounded to 2 decimals --------------------------------
  perform public.convert_wallet_funds('GHS', 'USD', 10, 'KWP-TXN-LEDGERTEST-4');
  select available into v from public.wallet_balances where wallet_id = a and currency = 'GHS';
  select available into usd from public.wallet_balances where wallet_id = a and currency = 'USD';
  if v <> 40 then raise exception 'T4 fx: expected A GHS 40, got %', v; end if;
  if usd is null or usd <= 0 or usd <> round(usd, 2) then raise exception 'T4 fx: bad USD credit %', usd; end if;
  if (select balance from public.wallets where id = a) <> usd then raise exception 'T4 fx: legacy USD mirror out of sync'; end if;

  -- 5. Payout reserved then failed: funds return ----------------------------
  insert into public.payment_methods (user_id, kind, rail, msisdn, is_default)
  values (a, 'momo', 'mtn', '233244123456', true) returning id into pm;
  perform public.create_ghana_payout_from_payment_method(15, 'KWP-TXN-LEDGERTEST-5', pm);
  select available into v from public.wallet_balances where wallet_id = a and currency = 'GHS';
  if v <> 25 then raise exception 'T5 reserve: expected A 25, got %', v; end if;
  perform public.settle_ghana_payout('KWP-TXN-LEDGERTEST-5', 'Failed', null, null, 'test failure');
  select available into v from public.wallet_balances where wallet_id = a and currency = 'GHS';
  if v <> 40 then raise exception 'T5 reversal: expected A 40, got %', v; end if;

  -- 6. Payout completed: money leaves, completed_at is set -------------------
  perform public.create_ghana_payout_from_payment_method(5, 'KWP-TXN-LEDGERTEST-6', pm);
  perform public.settle_ghana_payout('KWP-TXN-LEDGERTEST-6', 'Completed', 'gw-payout-6');
  perform public.settle_ghana_payout('KWP-TXN-LEDGERTEST-6', 'Completed', 'gw-payout-6'); -- idempotent
  select available into v from public.wallet_balances where wallet_id = a and currency = 'GHS';
  if v <> 35 then raise exception 'T6 payout: expected A 35, got %', v; end if;
  if (select completed_at from public.payout_intents where reference = 'KWP-TXN-LEDGERTEST-6') is null then
    raise exception 'T6 payout: completed_at not set';
  end if;
  if exists (
    select 1 from public.ledger_entries e join public.ledger_accounts ac on ac.id = e.account_id
    where ac.code = 'system:payouts_in_flight:GHS' having sum(e.amount) <> 0
  ) then raise exception 'T6: payouts_in_flight should net to zero'; end if;

  -- 7. Guards ---------------------------------------------------------------
  failed := false;
  begin
    perform public.transfer_funds('KWPLEDGERB', 1000, 'KWP-TXN-LEDGERTEST-7', 'GHS');
  exception when others then
    failed := sqlerrm like '%Insufficient balance%';
  end;
  if not failed then raise exception 'T7a overdraft was not rejected'; end if;

  failed := false;
  begin
    perform public.adjust_wallet_balance(a, 'GHS', 1);
  exception when others then
    failed := sqlerrm like '%retired%';
  end;
  if not failed then raise exception 'T7b adjust_wallet_balance still works'; end if;

  failed := false;
  begin
    update public.ledger_entries set amount = amount + 1 where id = (select min(id) from public.ledger_entries);
  exception when others then
    failed := sqlerrm like '%append-only%';
  end;
  if not failed then raise exception 'T7c ledger entry could be edited'; end if;

  failed := false;
  begin
    perform public.ledger_move('manual', 'KWP-TXN-LEDGERTEST-8',  null,
      public.ledger_wallet_account(a, 'GHS'), public.ledger_wallet_account(b, 'GHS'), 0.001);
  exception when others then
    failed := sqlerrm like '%two decimal%';
  end;
  if not failed then raise exception 'T7d sub-cent posting was accepted'; end if;

  -- 8. Books agree ----------------------------------------------------------
  if exists (select 1 from public.ledger_verify()) then
    select string_agg(problem || ' ' || subject, '; ') into msg from public.ledger_verify();
    raise exception 'T8 ledger_verify found problems: %', msg;
  end if;
  if exists (select 1 from public.ledger_entries group by currency having sum(amount) <> 0) then
    raise exception 'T8 ledger does not net to zero per currency';
  end if;

  raise exception 'LEDGER_TESTS_PASSED: A GHS=35, A USD=%, B GHS=30, merchant=20, journals=%, entries=%',
    usd,
    (select count(*) from public.ledger_journals),
    (select count(*) from public.ledger_entries);
end;
$$;
