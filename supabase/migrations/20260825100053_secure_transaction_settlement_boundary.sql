-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create or replace function public.settle_provider_transaction(
  p_reference text,
  p_status text,
  p_provider text,
  p_provider_reference text default null
)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized_reference text := upper(trim(p_reference));
  normalized_status text := trim(p_status);
  normalized_provider text := lower(trim(p_provider));
  txn public.transactions;
begin
  if normalized_reference = ''
    or normalized_reference not like 'KWP-TXN-%'
    or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  if normalized_status not in ('Completed', 'Failed', 'Cancelled') then
    raise exception 'Invalid transaction status';
  end if;

  if normalized_provider = '' then
    raise exception 'Provider is required';
  end if;

  if normalized_provider in (
    'kwanpay_test',
    'ghana_momo_test',
    'kwanpay_fx_test',
    'kwanpay_operator_test',
    'ghana_collector_test',
    'stellar_testnet'
  ) then
    raise exception 'Test providers cannot settle real transactions';
  end if;

  select *
  into txn
  from public.transactions
  where reference = normalized_reference
  for update;

  if not found then
    raise exception 'Transaction not found';
  end if;

  if txn.provider <> normalized_provider then
    raise exception 'Provider does not match transaction';
  end if;

  if txn.status = normalized_status then
    return txn;
  end if;

  if txn.status <> 'Pending' then
    raise exception 'Transaction can no longer be settled';
  end if;

  if p_provider_reference is not null and trim(p_provider_reference) <> '' then
    update public.transactions
    set
      status = normalized_status,
      provider_reference = trim(p_provider_reference)
    where id = txn.id
    returning * into txn;
  else
    update public.transactions
    set status = normalized_status
    where id = txn.id
    returning * into txn;
  end if;

  if normalized_status = 'Completed' and txn.type = 'Top Up' then
    perform public.adjust_wallet_balance(
      txn.wallet_id,
      txn.currency,
      txn.amount
    );
  end if;

  return txn;
end;
$$;

revoke execute on function public.adjust_wallet_balance(uuid, text, numeric) from public, anon, authenticated;
revoke execute on function public.settle_provider_transaction(text, text, text, text) from public, anon, authenticated;
grant execute on function public.settle_provider_transaction(text, text, text, text) to service_role;

revoke execute on function public.initiate_test_funding(numeric, text, text, text, text, text) from public, anon, authenticated;
revoke execute on function public.apply_funding_status(uuid, text) from public, anon, authenticated;

drop function if exists public.initiate_test_funding(numeric, text, text, text, text, text);
drop function if exists public.apply_funding_status(uuid, text);
