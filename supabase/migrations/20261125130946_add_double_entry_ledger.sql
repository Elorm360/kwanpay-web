-- Phase 2, milestone 1: double-entry ledger.
--
-- Every money movement is recorded as a journal of entries whose signed
-- amounts sum to zero per currency. Entries are append-only. wallet_balances
-- (and tourism_merchants.available) become caches maintained by ledger_post,
-- so a balance can always be re-derived from the ledger and verified with
-- ledger_verify().
--
-- Also fixes: FX conversions credited unrounded amounts (cache drifted from
-- the 2-decimal transaction history), and completed payouts never got a
-- completed_at timestamp.

-- 1. Tables ------------------------------------------------------------------

create table public.ledger_accounts (
  id bigint generated always as identity primary key,
  code text not null unique,
  kind text not null check (kind in ('wallet', 'merchant', 'system')),
  wallet_id uuid references public.wallets (id) on delete restrict,
  merchant_code text references public.tourism_merchants (code) on delete restrict,
  currency text not null check (currency ~ '^[A-Z]{3}$'),
  created_at timestamptz not null default timezone('utc', now()),
  constraint ledger_accounts_owner_matches_kind check (
    (kind = 'wallet' and wallet_id is not null and merchant_code is null)
    or (kind = 'merchant' and merchant_code is not null and wallet_id is null)
    or (kind = 'system' and wallet_id is null and merchant_code is null)
  )
);

create unique index ledger_accounts_wallet_currency
  on public.ledger_accounts (wallet_id, currency) where kind = 'wallet';
create unique index ledger_accounts_merchant_currency
  on public.ledger_accounts (merchant_code, currency) where kind = 'merchant';

comment on table public.ledger_accounts is
  'Double-entry accounts: one per wallet+currency, per merchant+currency, and system pools.';

create table public.ledger_journals (
  id bigint generated always as identity primary key,
  kind text not null check (kind ~ '^[a-z_]{3,40}$'),
  reference text not null,
  transaction_id uuid references public.transactions (id) on delete restrict,
  memo text,
  created_at timestamptz not null default timezone('utc', now()),
  constraint ledger_journals_kind_reference_key unique (kind, reference)
);

create index ledger_journals_transaction_id on public.ledger_journals (transaction_id);

comment on table public.ledger_journals is
  'One balanced money event. (kind, reference) is unique, so a posting cannot be duplicated.';

create table public.ledger_entries (
  id bigint generated always as identity primary key,
  journal_id bigint not null references public.ledger_journals (id) on delete restrict,
  account_id bigint not null references public.ledger_accounts (id) on delete restrict,
  currency text not null check (currency ~ '^[A-Z]{3}$'),
  amount numeric(20, 2) not null check (amount <> 0),
  created_at timestamptz not null default timezone('utc', now())
);

create index ledger_entries_account_id on public.ledger_entries (account_id, id);
create index ledger_entries_journal_id on public.ledger_entries (journal_id);

comment on table public.ledger_entries is
  'Append-only signed entries. An account balance is the sum of its entries.';

-- 2. Integrity guards ---------------------------------------------------------

-- Journals must net to zero per currency. Checked at commit, after all lines
-- of the journal exist.
create function public.ledger_assert_journal_balanced()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_bad text;
begin
  select string_agg(currency || '=' || total::text, ', ')
  into v_bad
  from (
    select currency, sum(amount) as total
    from public.ledger_entries
    where journal_id = new.journal_id
    group by currency
    having sum(amount) <> 0
  ) unbalanced;

  if v_bad is not null then
    raise exception 'Ledger journal % is unbalanced: %', new.journal_id, v_bad;
  end if;

  return null;
end;
$$;

create constraint trigger ledger_entries_balanced
  after insert on public.ledger_entries
  deferrable initially deferred
  for each row execute function public.ledger_assert_journal_balanced();

create function public.ledger_reject_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Ledger % rows are append-only', tg_table_name;
end;
$$;

create trigger ledger_entries_append_only
  before update or delete on public.ledger_entries
  for each row execute function public.ledger_reject_mutation();

create trigger ledger_journals_append_only
  before update or delete on public.ledger_journals
  for each row execute function public.ledger_reject_mutation();

-- 3. Access -------------------------------------------------------------------
-- Writes happen only inside SECURITY DEFINER functions. Users may read their
-- own wallet accounts and entries.

alter table public.ledger_accounts enable row level security;
alter table public.ledger_journals enable row level security;
alter table public.ledger_entries enable row level security;

revoke all on table public.ledger_accounts, public.ledger_journals, public.ledger_entries
  from anon, authenticated, service_role;
grant select on table public.ledger_accounts, public.ledger_journals, public.ledger_entries
  to authenticated, service_role;

create policy "Users read own ledger accounts"
on public.ledger_accounts for select to authenticated
using (kind = 'wallet' and wallet_id = (select auth.uid()));

create policy "Users read own ledger entries"
on public.ledger_entries for select to authenticated
using (exists (
  select 1 from public.ledger_accounts a
  where a.id = ledger_entries.account_id
    and a.kind = 'wallet'
    and a.wallet_id = (select auth.uid())
));

create policy "Users read journals touching their wallet"
on public.ledger_journals for select to authenticated
using (exists (
  select 1
  from public.ledger_entries e
  join public.ledger_accounts a on a.id = e.account_id
  where e.journal_id = ledger_journals.id
    and a.kind = 'wallet'
    and a.wallet_id = (select auth.uid())
));

-- 4. Account lookup (get or create) ------------------------------------------

create function public.ledger_wallet_account(p_wallet_id uuid, p_currency text)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_currency text := upper(trim(p_currency));
  v_id bigint;
begin
  insert into public.ledger_accounts (code, kind, wallet_id, currency)
  values ('wallet:' || p_wallet_id::text || ':' || v_currency, 'wallet', p_wallet_id, v_currency)
  on conflict (code) do nothing;

  select id into v_id from public.ledger_accounts
  where code = 'wallet:' || p_wallet_id::text || ':' || v_currency;
  return v_id;
end;
$$;

create function public.ledger_merchant_account(p_merchant_code text, p_currency text)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_code text := lower(trim(p_merchant_code));
  v_currency text := upper(trim(p_currency));
  v_id bigint;
begin
  insert into public.ledger_accounts (code, kind, merchant_code, currency)
  values ('merchant:' || v_code || ':' || v_currency, 'merchant', v_code, v_currency)
  on conflict (code) do nothing;

  select id into v_id from public.ledger_accounts
  where code = 'merchant:' || v_code || ':' || v_currency;
  return v_id;
end;
$$;

-- System pools, e.g. collections:<provider>, payouts_in_flight,
-- payouts:<provider>, fx, opening_balances.
create function public.ledger_system_account(p_name text, p_currency text)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_name text := lower(trim(p_name));
  v_currency text := upper(trim(p_currency));
  v_id bigint;
begin
  if v_name !~ '^[a-z_]+(:[a-z0-9_]+)?$' then
    raise exception 'Invalid system account name: %', p_name;
  end if;

  insert into public.ledger_accounts (code, kind, currency)
  values ('system:' || v_name || ':' || v_currency, 'system', v_currency)
  on conflict (code) do nothing;

  select id into v_id from public.ledger_accounts
  where code = 'system:' || v_name || ':' || v_currency;
  return v_id;
end;
$$;

-- 5. Posting ------------------------------------------------------------------
-- p_lines: [{"account_id": <bigint>, "amount": <numeric>}, ...]
-- Positive amounts increase an account's balance. Lines must net to zero per
-- currency. Wallet balances may never go negative.
create function public.ledger_post(
  p_kind text,
  p_reference text,
  p_transaction_id uuid,
  p_memo text,
  p_lines jsonb
)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_journal_id bigint;
  v_line record;
  v_new_available numeric;
  v_updated int;
begin
  if jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) < 2 then
    raise exception 'A ledger journal needs at least two lines';
  end if;

  if exists (
    select 1 from jsonb_array_elements(p_lines) l
    where (l ->> 'amount')::numeric = 0
       or (l ->> 'amount')::numeric <> round((l ->> 'amount')::numeric, 2)
  ) then
    raise exception 'Ledger amounts must be non-zero with at most two decimal places';
  end if;

  if exists (
    select a.currency
    from jsonb_array_elements(p_lines) l
    join public.ledger_accounts a on a.id = (l ->> 'account_id')::bigint
    group by a.currency
    having sum((l ->> 'amount')::numeric) <> 0
  ) then
    raise exception 'Ledger journal does not balance';
  end if;

  if (select count(*) from jsonb_array_elements(p_lines) l
      left join public.ledger_accounts a on a.id = (l ->> 'account_id')::bigint
      where a.id is null) > 0 then
    raise exception 'Unknown ledger account';
  end if;

  insert into public.ledger_journals (kind, reference, transaction_id, memo)
  values (p_kind, upper(trim(p_reference)), p_transaction_id, p_memo)
  returning id into v_journal_id;

  -- Lock and update balances in account-id order to avoid deadlocks.
  for v_line in
    select a.id, a.kind, a.wallet_id, a.merchant_code, a.currency,
           (l ->> 'amount')::numeric as amount
    from jsonb_array_elements(p_lines) l
    join public.ledger_accounts a on a.id = (l ->> 'account_id')::bigint
    order by a.id
  loop
    insert into public.ledger_entries (journal_id, account_id, currency, amount)
    values (v_journal_id, v_line.id, v_line.currency, v_line.amount);

    if v_line.kind = 'wallet' then
      insert into public.wallet_balances (wallet_id, currency, available)
      values (v_line.wallet_id, v_line.currency, 0)
      on conflict (wallet_id, currency) do nothing;

      update public.wallet_balances
      set available = available + v_line.amount,
          updated_at = timezone('utc', now())
      where wallet_id = v_line.wallet_id
        and currency = v_line.currency
        and available + v_line.amount >= 0
      returning available into v_new_available;

      if v_new_available is null then
        raise exception 'Insufficient balance';
      end if;

      -- Legacy mirror kept for older app builds that read wallets.balance.
      if v_line.currency = 'USD' then
        update public.wallets
        set balance = v_new_available, updated_at = timezone('utc', now())
        where id = v_line.wallet_id;
      end if;
    elsif v_line.kind = 'merchant' then
      update public.tourism_merchants
      set available = available + v_line.amount,
          updated_at = timezone('utc', now())
      where code = v_line.merchant_code
        and currency = v_line.currency;
      get diagnostics v_updated = row_count;
      if v_updated <> 1 then
        raise exception 'Merchant % has no % balance', v_line.merchant_code, v_line.currency;
      end if;
    end if;
  end loop;

  return v_journal_id;
end;
$$;

-- Convenience for the common two-line case.
create function public.ledger_move(
  p_kind text,
  p_reference text,
  p_transaction_id uuid,
  p_from_account bigint,
  p_to_account bigint,
  p_amount numeric,
  p_memo text default null
)
returns bigint
language sql
security definer
set search_path = ''
as $$
  select public.ledger_post(
    p_kind, p_reference, p_transaction_id, p_memo,
    jsonb_build_array(
      jsonb_build_object('account_id', p_from_account, 'amount', -p_amount),
      jsonb_build_object('account_id', p_to_account, 'amount', p_amount)
    )
  );
$$;

-- 6. Verification -------------------------------------------------------------
-- Returns one row per problem; an empty result means the books agree.
create function public.ledger_verify()
returns table (problem text, subject text, cached numeric, ledger numeric)
language sql
stable
security definer
set search_path = ''
as $$
  with sums as (
    select account_id, sum(amount) as total
    from public.ledger_entries
    group by account_id
  )
  select 'wallet cache differs from ledger', a.code, coalesce(b.available, 0), coalesce(s.total, 0)
  from public.ledger_accounts a
  left join sums s on s.account_id = a.id
  left join public.wallet_balances b on b.wallet_id = a.wallet_id and b.currency = a.currency
  where a.kind = 'wallet' and coalesce(b.available, 0) <> coalesce(s.total, 0)
  union all
  select 'wallet balance has no ledger account', b.wallet_id::text || ':' || b.currency, b.available, 0
  from public.wallet_balances b
  where b.available <> 0
    and not exists (
      select 1 from public.ledger_accounts a
      where a.kind = 'wallet' and a.wallet_id = b.wallet_id and a.currency = b.currency
    )
  union all
  select 'merchant cache differs from ledger', a.code, coalesce(m.available, 0), coalesce(s.total, 0)
  from public.ledger_accounts a
  left join sums s on s.account_id = a.id
  left join public.tourism_merchants m on m.code = a.merchant_code and m.currency = a.currency
  where a.kind = 'merchant' and coalesce(m.available, 0) <> coalesce(s.total, 0)
  union all
  select 'journal unbalanced', j.id::text || ':' || e.currency, null, sum(e.amount)
  from public.ledger_journals j
  join public.ledger_entries e on e.journal_id = j.id
  group by j.id, e.currency
  having sum(e.amount) <> 0;
$$;

revoke all on function
  public.ledger_wallet_account(uuid, text),
  public.ledger_merchant_account(text, text),
  public.ledger_system_account(text, text),
  public.ledger_post(text, text, uuid, text, jsonb),
  public.ledger_move(text, text, uuid, bigint, bigint, numeric, text),
  public.ledger_verify(),
  public.ledger_assert_journal_balanced(),
  public.ledger_reject_mutation()
from public, anon, authenticated, service_role;

grant execute on function public.ledger_verify() to service_role;

-- 7. Opening balances ---------------------------------------------------------
-- Carry any existing cached balance into the ledger against opening_balances.
-- (All balances were zero when this was written; this keeps it correct anyway.)
do $$
declare
  r record;
  v_journal bigint;
begin
  for r in
    select wallet_id, currency, available from public.wallet_balances where available <> 0
  loop
    insert into public.ledger_journals (kind, reference, memo)
    values ('opening_balance', 'OPEN-W-' || r.wallet_id::text || '-' || r.currency, 'Balance before ledger')
    returning id into v_journal;
    insert into public.ledger_entries (journal_id, account_id, currency, amount) values
      (v_journal, public.ledger_wallet_account(r.wallet_id, r.currency), r.currency, r.available),
      (v_journal, public.ledger_system_account('opening_balances', r.currency), r.currency, -r.available);
  end loop;

  for r in
    select code, currency, available from public.tourism_merchants where available <> 0
  loop
    insert into public.ledger_journals (kind, reference, memo)
    values ('opening_balance', 'OPEN-M-' || r.code || '-' || r.currency, 'Balance before ledger')
    returning id into v_journal;
    insert into public.ledger_entries (journal_id, account_id, currency, amount) values
      (v_journal, public.ledger_merchant_account(r.code, r.currency), r.currency, r.available),
      (v_journal, public.ledger_system_account('opening_balances', r.currency), r.currency, -r.available);
  end loop;
end;
$$;

-- 8. Retire the old balance mutator ------------------------------------------
-- Fails closed so no code path can change a balance without a journal.
create or replace function public.adjust_wallet_balance(p_wallet_id uuid, p_currency text, p_delta numeric)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  raise exception 'adjust_wallet_balance is retired; post money movements through ledger_post';
end;
$$;

-- 9. Money functions now post to the ledger -----------------------------------

-- 9a. Top-up settlement: gateway collections pool -> wallet.
create or replace function public.settle_provider_transaction(
  p_reference text,
  p_status text,
  p_provider_reference text default null
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $function$
declare
  normalized_reference text := upper(trim(coalesce(p_reference, '')));
  normalized_status text := initcap(lower(trim(coalesce(p_status, ''))));
  existing_txn public.transactions;
  updated_txn public.transactions;
begin
  if normalized_reference = ''
     or normalized_reference not like 'KWP-TXN-%'
     or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  if normalized_status not in ('Completed', 'Failed', 'Cancelled') then
    raise exception 'Invalid settlement status';
  end if;

  select * into existing_txn
  from public.transactions
  where reference = normalized_reference
  for update;

  if not found then
    raise exception 'Transaction not found';
  end if;

  if existing_txn.provider is null then
    raise exception 'Transaction has no provider';
  end if;

  if existing_txn.status = normalized_status then
    if p_provider_reference is not null
       and (existing_txn.provider_reference is null
            or existing_txn.provider_reference <> p_provider_reference) then
      update public.transactions
      set provider_reference = p_provider_reference
      where id = existing_txn.id
      returning * into updated_txn;
      return updated_txn;
    end if;
    return existing_txn;
  end if;

  if existing_txn.status in ('Completed', 'Failed', 'Cancelled') then
    raise exception 'Transaction is already finalized';
  end if;

  if existing_txn.status <> 'Pending' then
    raise exception 'Transaction is not pending';
  end if;

  if normalized_status in ('Failed', 'Cancelled') then
    update public.transactions
    set status = normalized_status,
        provider_reference = coalesce(p_provider_reference, provider_reference)
    where id = existing_txn.id
    returning * into updated_txn;

    update public.collection_intents
    set status = case when normalized_status = 'Failed' then 'failed' else 'cancelled' end,
        provider_event_id = coalesce(p_provider_reference, provider_event_id)
    where transaction_id = existing_txn.id;

    return updated_txn;
  end if;

  if existing_txn.type <> 'Top Up' then
    raise exception 'Provider settlement is not supported for this transaction type';
  end if;

  if not exists (
    select 1 from public.payment_providers
    where id = existing_txn.provider and supports_collections
  ) then
    raise exception 'Unsupported settlement provider';
  end if;

  if existing_txn.currency <> 'GHS' then
    raise exception 'Unsupported funding currency';
  end if;

  perform public.ledger_move(
    'collection',
    existing_txn.reference,
    existing_txn.id,
    public.ledger_system_account('collections:' || existing_txn.provider, existing_txn.currency),
    public.ledger_wallet_account(existing_txn.wallet_id, existing_txn.currency),
    existing_txn.amount,
    'Top-up via ' || existing_txn.provider
  );

  update public.transactions
  set status = 'Completed',
      provider_reference = coalesce(p_provider_reference, provider_reference)
  where id = existing_txn.id
  returning * into updated_txn;

  update public.collection_intents
  set status = 'settled',
      provider_event_id = coalesce(p_provider_reference, provider_event_id),
      settled_at = timezone('utc', now())
  where transaction_id = existing_txn.id;

  return updated_txn;
end;
$function$;

-- 9b. Wallet-to-wallet transfer.
create or replace function public.transfer_funds(
  p_receiver_wallet_id text,
  p_transfer_amount numeric,
  p_reference text,
  p_currency text
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $function$
declare
  caller uuid := auth.uid();
  normalized_wallet_id text := upper(trim(p_receiver_wallet_id));
  normalized_reference text := upper(trim(p_reference));
  normalized_currency text := upper(trim(p_currency));
  receiver_uuid uuid;
  existing_txn public.transactions;
  send_txn public.transactions;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if p_transfer_amount is null or p_transfer_amount <= 0 then
    raise exception 'Invalid amount';
  end if;

  if p_transfer_amount <> round(p_transfer_amount, 2) then
    raise exception 'Amount can have at most two decimal places';
  end if;

  if normalized_currency not in ('USD', 'GHS', 'NGN') then
    raise exception 'Unsupported currency';
  end if;

  if normalized_reference = ''
    or normalized_reference not like 'KWP-TXN-%'
    or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  select * into existing_txn
  from public.transactions
  where reference = normalized_reference;

  if found then
    if existing_txn.wallet_id = caller
      and existing_txn.type = 'Send'
      and existing_txn.amount = p_transfer_amount
      and existing_txn.currency = normalized_currency
      and existing_txn.provider = 'kwanpay_transfer'
      and existing_txn.provider_reference = normalized_wallet_id
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;
    raise exception 'Transaction reference is already in use';
  end if;

  select w.id into receiver_uuid
  from public.wallets w
  where upper(w.wallet_id) = normalized_wallet_id
    and w.status = 'Active';

  if receiver_uuid is null then
    raise exception 'Recipient wallet not found';
  end if;

  if receiver_uuid = caller then
    raise exception 'Cannot send to yourself';
  end if;

  insert into public.transactions (
    wallet_id, type, amount, currency, status, description, reference, provider, provider_reference
  ) values (
    caller, 'Send', p_transfer_amount, normalized_currency, 'Pending',
    'Transfer Sent', normalized_reference, 'kwanpay_transfer', normalized_wallet_id
  ) returning * into send_txn;

  perform public.ledger_move(
    'transfer',
    normalized_reference,
    send_txn.id,
    public.ledger_wallet_account(caller, normalized_currency),
    public.ledger_wallet_account(receiver_uuid, normalized_currency),
    p_transfer_amount,
    'Wallet transfer'
  );

  insert into public.transactions (
    wallet_id, type, amount, currency, status, description, reference, provider, provider_reference
  ) values (
    receiver_uuid, 'Receive', p_transfer_amount, normalized_currency, 'Completed',
    'Transfer Received', normalized_reference || '-R', 'kwanpay_transfer', normalized_reference
  );

  update public.transactions
  set status = 'Completed'
  where id = send_txn.id
  returning * into send_txn;

  return send_txn;
exception
  when unique_violation then
    select * into existing_txn
    from public.transactions
    where reference = normalized_reference;

    if found
      and existing_txn.wallet_id = caller
      and existing_txn.type = 'Send'
      and existing_txn.amount = p_transfer_amount
      and existing_txn.currency = normalized_currency
      and existing_txn.provider = 'kwanpay_transfer'
      and existing_txn.provider_reference = normalized_wallet_id
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
end;
$function$;

-- 9c. Currency conversion: wallet(from) -> fx pool(from); fx pool(to) -> wallet(to).
-- The credited amount is rounded to 2 decimals so the cache, the ledger and
-- the transaction history always agree.
create or replace function public.convert_wallet_funds(
  p_from_currency text,
  p_to_currency text,
  p_from_amount numeric,
  p_reference text
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $function$
declare
  caller uuid := auth.uid();
  from_code text := upper(trim(p_from_currency));
  to_code text := upper(trim(p_to_currency));
  normalized_reference text := upper(trim(p_reference));
  quote_row record;
  existing_txn public.transactions;
  debit_txn public.transactions;
  to_amount numeric;
  fx_provider text := 'kwanpay_fx';
begin
  if caller is null then raise exception 'Not authenticated'; end if;
  if p_from_amount is null or p_from_amount <= 0 then raise exception 'Invalid amount'; end if;
  if p_from_amount <> round(p_from_amount, 2) then raise exception 'Amount can have at most two decimal places'; end if;
  if from_code = to_code then raise exception 'Choose two different currencies'; end if;
  if normalized_reference = '' or normalized_reference not like 'KWP-TXN-%' or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  select * into quote_row from public.get_fx_quote(from_code, to_code, p_from_amount);
  to_amount := round(quote_row.to_amount, 2);
  if to_amount is null or to_amount <= 0 then raise exception 'Amount is too small to convert'; end if;

  select * into existing_txn from public.transactions where reference = normalized_reference;
  if found then
    if existing_txn.wallet_id = caller
      and existing_txn.type = 'Convert Out'
      and existing_txn.amount = p_from_amount
      and existing_txn.currency = from_code
      and existing_txn.provider = fx_provider
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;
    raise exception 'Transaction reference is already in use';
  end if;

  insert into public.transactions (wallet_id, type, amount, currency, status, description, reference, provider, provider_reference)
  values (caller, 'Convert Out', p_from_amount, from_code, 'Completed', 'Converted to ' || to_code, normalized_reference, fx_provider, to_code || ':' || to_amount::text)
  returning * into debit_txn;

  insert into public.transactions (wallet_id, type, amount, currency, status, description, reference, provider, provider_reference)
  values (caller, 'Convert In', to_amount, to_code, 'Completed', 'Converted from ' || from_code, normalized_reference || '-C', fx_provider, from_code || ':' || p_from_amount::text);

  perform public.ledger_post(
    'fx_conversion',
    normalized_reference,
    debit_txn.id,
    from_code || ' ' || p_from_amount::text || ' -> ' || to_code || ' ' || to_amount::text,
    jsonb_build_array(
      jsonb_build_object('account_id', public.ledger_wallet_account(caller, from_code), 'amount', -p_from_amount),
      jsonb_build_object('account_id', public.ledger_system_account('fx', from_code), 'amount', p_from_amount),
      jsonb_build_object('account_id', public.ledger_system_account('fx', to_code), 'amount', -to_amount),
      jsonb_build_object('account_id', public.ledger_wallet_account(caller, to_code), 'amount', to_amount)
    )
  );

  return debit_txn;
exception
  when unique_violation then
    select * into existing_txn from public.transactions where reference = normalized_reference;
    if found
      and existing_txn.wallet_id = caller
      and existing_txn.type = 'Convert Out'
      and existing_txn.amount = p_from_amount
      and existing_txn.currency = from_code
      and existing_txn.provider = fx_provider
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;
    raise exception 'Transaction reference is already in use';
end;
$function$;

-- 9d. Merchant payment: wallet -> merchant account.
create or replace function public.pay_operator_bill(
  p_operator_code text,
  p_account_number text,
  p_amount numeric,
  p_currency text,
  p_reference text
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $function$
declare
  caller uuid := auth.uid();
  normalized_code text := lower(trim(p_operator_code));
  normalized_currency text := upper(trim(p_currency));
  normalized_reference text := upper(trim(p_reference));
  normalized_account text;
  merchant public.tourism_merchants;
  existing_txn public.transactions;
  payment_txn public.transactions;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if p_amount is null or p_amount <= 0 then
    raise exception 'Invalid amount';
  end if;

  if p_amount <> round(p_amount, 2) then
    raise exception 'Amount can have at most two decimal places';
  end if;

  if normalized_currency <> 'GHS' then
    raise exception 'Pay in Ghana cedis';
  end if;

  if normalized_reference = ''
    or normalized_reference not like 'KWP-TXN-%'
    or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  select * into merchant
  from public.tourism_merchants
  where code = normalized_code
  for update;

  if not found or merchant.status <> 'live' then
    raise exception 'Unknown operator';
  end if;

  normalized_account := upper(regexp_replace(coalesce(p_account_number, ''), '[^A-Za-z0-9]', '', 'g'));

  if length(normalized_account) < 6 or length(normalized_account) > 24 then
    raise exception 'Enter a valid booking reference';
  end if;

  select * into existing_txn
  from public.transactions
  where reference = normalized_reference;

  if found then
    if existing_txn.wallet_id = caller
      and existing_txn.type = 'Payment'
      and existing_txn.amount = p_amount
      and existing_txn.currency = 'GHS'
      and existing_txn.provider = 'kwanpay_merchant'
      and existing_txn.provider_reference = normalized_code || ':' || normalized_account
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
  end if;

  insert into public.transactions (
    wallet_id, type, amount, currency, status, description, reference, provider, provider_reference
  )
  values (
    caller, 'Payment', p_amount, 'GHS', 'Pending', merchant.name,
    normalized_reference, 'kwanpay_merchant', normalized_code || ':' || normalized_account
  )
  returning * into payment_txn;

  perform public.ledger_move(
    'merchant_payment',
    normalized_reference,
    payment_txn.id,
    public.ledger_wallet_account(caller, 'GHS'),
    public.ledger_merchant_account(merchant.code, 'GHS'),
    p_amount,
    merchant.name || ' booking ' || normalized_account
  );

  update public.transactions
  set status = 'Completed'
  where id = payment_txn.id
  returning * into payment_txn;

  return payment_txn;
exception
  when unique_violation then
    select * into existing_txn
    from public.transactions
    where reference = normalized_reference;

    if found
      and existing_txn.wallet_id = caller
      and existing_txn.type = 'Payment'
      and existing_txn.amount = p_amount
      and existing_txn.currency = 'GHS'
      and existing_txn.provider = 'kwanpay_merchant'
      and existing_txn.provider_reference = normalized_code || ':' || normalized_account
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
end;
$function$;

-- 9e. Payout creation reserves funds: wallet -> payouts_in_flight.
create or replace function public.create_ghana_payout(
  p_amount numeric,
  p_reference text,
  p_withdrawal_method_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_method public.withdrawal_methods%rowtype;
  v_transaction public.transactions%rowtype;
  v_payout public.payout_intents%rowtype;
  v_reference text := upper(trim(p_reference));
  v_snapshot jsonb;
  v_provider text;
begin
  if v_user_id is null then raise exception 'Not authenticated.'; end if;
  if p_amount is null or p_amount <= 0 then raise exception 'Withdrawal amount must be greater than zero.'; end if;
  if p_amount <> round(p_amount, 2) then raise exception 'Withdrawal amount can have at most two decimal places.'; end if;
  if v_reference !~ '^KWP-TXN-[A-Z0-9-]{1,80}$' then raise exception 'Invalid withdrawal reference.'; end if;

  if exists (select 1 from public.transactions where wallet_id = v_user_id and reference = v_reference) then
    select * into v_transaction from public.transactions where wallet_id = v_user_id and reference = v_reference limit 1;
    select * into v_payout from public.payout_intents where transaction_id = v_transaction.id limit 1;
    return jsonb_build_object('transaction', to_jsonb(v_transaction), 'payout', to_jsonb(v_payout), 'idempotent', true);
  end if;

  v_provider := public.active_payout_provider();
  if v_provider is null then raise exception 'Withdrawals are not available yet.'; end if;

  select * into v_method from public.withdrawal_methods where id = p_withdrawal_method_id and user_id = v_user_id;
  if not found then raise exception 'Withdrawal method not found.'; end if;
  if v_method.kind <> 'momo' then raise exception 'This withdrawal route is not enabled yet.'; end if;

  v_snapshot := jsonb_build_object(
    'kind', v_method.kind,
    'rail', v_method.rail,
    'msisdn', v_method.msisdn,
    'bank_code', v_method.bank_code,
    'account_number', v_method.account_number,
    'account_name', v_method.account_name,
    'country', v_method.country
  );

  insert into public.transactions(wallet_id, type, amount, currency, description, status, reference, provider)
  values (v_user_id, 'Withdrawal', p_amount, 'GHS', 'GHS withdrawal to local payment method', 'Pending', v_reference, v_provider)
  returning * into v_transaction;

  perform public.ledger_move(
    'payout_reserve',
    v_reference,
    v_transaction.id,
    public.ledger_wallet_account(v_user_id, 'GHS'),
    public.ledger_system_account('payouts_in_flight', 'GHS'),
    p_amount,
    'Withdrawal reserved'
  );

  insert into public.payout_intents(wallet_id, transaction_id, withdrawal_method_id, reference, amount, currency, destination_kind, destination_snapshot, status, provider)
  values (v_user_id, v_transaction.id, v_method.id, v_reference, p_amount, 'GHS', v_method.kind, v_snapshot, 'Pending', v_provider)
  returning * into v_payout;

  return jsonb_build_object('transaction', to_jsonb(v_transaction), 'payout', to_jsonb(v_payout), 'idempotent', false);
end;
$function$;

create or replace function public.create_ghana_payout_from_payment_method(
  p_amount numeric,
  p_reference text,
  p_payment_method_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_method public.payment_methods%rowtype;
  v_transaction public.transactions%rowtype;
  v_payout public.payout_intents%rowtype;
  v_reference text := upper(trim(p_reference));
  v_snapshot jsonb;
  v_provider text;
begin
  if v_user_id is null then raise exception 'Not authenticated.'; end if;
  if p_amount is null or p_amount <= 0 then raise exception 'Withdrawal amount must be greater than zero.'; end if;
  if p_amount <> round(p_amount, 2) then raise exception 'Withdrawal amount can have at most two decimal places.'; end if;
  if v_reference !~ '^KWP-TXN-[A-Z0-9-]{1,80}$' then raise exception 'Invalid withdrawal reference.'; end if;

  if exists (select 1 from public.transactions where wallet_id = v_user_id and reference = v_reference) then
    select * into v_transaction from public.transactions where wallet_id = v_user_id and reference = v_reference limit 1;
    select * into v_payout from public.payout_intents where transaction_id = v_transaction.id limit 1;
    return jsonb_build_object('transaction', to_jsonb(v_transaction), 'payout', to_jsonb(v_payout), 'idempotent', true);
  end if;

  v_provider := public.active_payout_provider();
  if v_provider is null then raise exception 'Withdrawals are not available yet.'; end if;

  select * into v_method from public.payment_methods where id = p_payment_method_id and user_id = v_user_id;
  if not found or v_method.kind <> 'momo' then raise exception 'A Ghana Mobile Money payment method is required for this withdrawal.'; end if;

  v_snapshot := jsonb_build_object('kind', v_method.kind, 'rail', v_method.rail, 'msisdn', v_method.msisdn, 'country', 'GH');

  insert into public.transactions(wallet_id, type, amount, currency, description, status, reference, provider)
  values (v_user_id, 'Withdrawal', p_amount, 'GHS', 'GHS withdrawal to saved Mobile Money', 'Pending', v_reference, v_provider)
  returning * into v_transaction;

  perform public.ledger_move(
    'payout_reserve',
    v_reference,
    v_transaction.id,
    public.ledger_wallet_account(v_user_id, 'GHS'),
    public.ledger_system_account('payouts_in_flight', 'GHS'),
    p_amount,
    'Withdrawal reserved'
  );

  insert into public.payout_intents(wallet_id, transaction_id, withdrawal_method_id, reference, amount, currency, destination_kind, destination_snapshot, status, provider)
  values (v_user_id, v_transaction.id, null, v_reference, p_amount, 'GHS', 'momo', v_snapshot, 'Pending', v_provider)
  returning * into v_payout;

  return jsonb_build_object('transaction', to_jsonb(v_transaction), 'payout', to_jsonb(v_payout), 'idempotent', false);
end;
$function$;

-- 9f. Payout settlement.
--   Completed: payouts_in_flight -> payouts:<provider> (money has left KwanPay).
--   Failed/Cancelled: payouts_in_flight -> wallet (reserved funds returned).
create or replace function public.settle_ghana_payout(
  p_reference text,
  p_status text,
  p_provider_reference text default null,
  p_provider_status text default null,
  p_failure_reason text default null
)
returns public.payout_intents
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_payout public.payout_intents%rowtype;
  v_final_status text := initcap(lower(trim(p_status)));
  v_transaction_status text;
begin
  if v_final_status not in ('Completed','Failed','Cancelled','Processing','Pending') then
    raise exception 'Invalid payout status.';
  end if;

  select * into v_payout
  from public.payout_intents
  where reference = upper(trim(p_reference))
  for update;

  if not found then
    raise exception 'Payout intent not found.';
  end if;

  if p_provider_reference is not null and length(trim(p_provider_reference)) > 0 then
    if v_payout.provider_reference is not null
       and v_payout.provider_reference <> trim(p_provider_reference) then
      raise exception 'Provider reference mismatch.';
    end if;
    v_payout.provider_reference := trim(p_provider_reference);
  end if;

  if v_payout.status in ('Completed','Failed','Cancelled') then
    return v_payout;
  end if;

  if v_final_status = 'Completed' then
    perform public.ledger_move(
      'payout_settled',
      v_payout.reference,
      v_payout.transaction_id,
      public.ledger_system_account('payouts_in_flight', v_payout.currency),
      public.ledger_system_account('payouts:' || v_payout.provider, v_payout.currency),
      v_payout.amount,
      'Withdrawal paid out'
    );
  elsif v_final_status in ('Failed','Cancelled') then
    perform public.ledger_move(
      'payout_reversal',
      v_payout.reference,
      v_payout.transaction_id,
      public.ledger_system_account('payouts_in_flight', v_payout.currency),
      public.ledger_wallet_account(v_payout.wallet_id, v_payout.currency),
      v_payout.amount,
      'Withdrawal ' || lower(v_final_status) || '; funds returned'
    );
  end if;

  update public.payout_intents
  set status = v_final_status,
      provider_reference = v_payout.provider_reference,
      provider_status = nullif(trim(coalesce(p_provider_status,'')), ''),
      failure_reason = case
        when v_final_status in ('Failed','Cancelled')
          then nullif(trim(coalesce(p_failure_reason,'')), '')
        else null
      end,
      completed_at = case
        when v_final_status in ('Completed','Failed','Cancelled')
          then timezone('utc', now())
        else completed_at
      end,
      updated_at = timezone('utc', now())
  where id = v_payout.id
  returning * into v_payout;

  v_transaction_status := case
    when v_final_status = 'Processing' then 'Pending'
    else v_final_status
  end;

  update public.transactions
  set status = v_transaction_status,
      provider_reference = v_payout.provider_reference
  where id = v_payout.transaction_id;

  return v_payout;
end;
$function$;
