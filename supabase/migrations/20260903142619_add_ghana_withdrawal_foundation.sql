-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create table if not exists public.withdrawal_methods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null default 'momo' check (kind in ('momo','bank')),
  rail text check (rail in ('mtn','telecel','airteltigo')),
  msisdn text,
  bank_code text,
  account_number text,
  account_name text,
  country text not null default 'GH' check (country = 'GH'),
  is_default boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  check (
    (kind = 'momo' and rail is not null and msisdn is not null and msisdn ~ '^233[0-9]{9}$')
    or
    (kind = 'bank' and bank_code is not null and account_number is not null)
  )
);

create index if not exists withdrawal_methods_user_idx on public.withdrawal_methods(user_id, created_at desc);
create unique index if not exists withdrawal_methods_one_default_idx on public.withdrawal_methods(user_id) where is_default;

alter table public.withdrawal_methods enable row level security;

drop policy if exists "Users can view own withdrawal methods" on public.withdrawal_methods;
drop policy if exists "Users can insert own withdrawal methods" on public.withdrawal_methods;
drop policy if exists "Users can update own withdrawal methods" on public.withdrawal_methods;
drop policy if exists "Users can delete own withdrawal methods" on public.withdrawal_methods;
create policy "Users can view own withdrawal methods" on public.withdrawal_methods for select to authenticated using ((select auth.uid()) = user_id);
create policy "Users can insert own withdrawal methods" on public.withdrawal_methods for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Users can update own withdrawal methods" on public.withdrawal_methods for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users can delete own withdrawal methods" on public.withdrawal_methods for delete to authenticated using ((select auth.uid()) = user_id);

create table if not exists public.payout_intents (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets(id),
  transaction_id uuid not null unique references public.transactions(id),
  withdrawal_method_id uuid references public.withdrawal_methods(id),
  reference text not null unique,
  provider text not null default 'fincra' check (provider = 'fincra'),
  provider_reference text,
  provider_status text,
  amount numeric not null check (amount > 0),
  fee_amount numeric not null default 0 check (fee_amount >= 0),
  currency text not null default 'GHS' check (currency = 'GHS'),
  destination_kind text not null check (destination_kind in ('momo','bank')),
  destination_snapshot jsonb not null default '{}'::jsonb,
  status text not null default 'Pending' check (status in ('Pending','Processing','Completed','Failed','Cancelled')),
  failure_reason text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  completed_at timestamptz
);

create index if not exists payout_intents_wallet_created_idx on public.payout_intents(wallet_id, created_at desc);
create unique index if not exists payout_intents_provider_reference_idx on public.payout_intents(provider, provider_reference) where provider_reference is not null;

alter table public.payout_intents enable row level security;
drop policy if exists "Users can view own payout intents" on public.payout_intents;
create policy "Users can view own payout intents" on public.payout_intents for select to authenticated using ((select auth.uid()) = wallet_id);

create or replace function public.create_ghana_payout(
  p_amount numeric,
  p_reference text,
  p_withdrawal_method_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_user_id uuid := auth.uid();
  v_method public.withdrawal_methods%rowtype;
  v_balance public.wallet_balances%rowtype;
  v_transaction public.transactions%rowtype;
  v_payout public.payout_intents%rowtype;
  v_reference text := upper(trim(p_reference));
  v_snapshot jsonb;
begin
  if v_user_id is null then raise exception 'Not authenticated.'; end if;
  if p_amount is null or p_amount <= 0 then raise exception 'Withdrawal amount must be greater than zero.'; end if;
  if p_amount <> round(p_amount, 2) then raise exception 'Withdrawal amount can have at most two decimal places.'; end if;
  if v_reference !~ '^KWP-TXN-[A-Z0-9-]{1,80}$' then raise exception 'Invalid withdrawal reference.'; end if;

  select * into v_method from public.withdrawal_methods where id = p_withdrawal_method_id and user_id = v_user_id;
  if not found then raise exception 'Withdrawal method not found.'; end if;
  if v_method.kind <> 'momo' then raise exception 'This withdrawal route is not enabled yet.'; end if;

  insert into public.wallet_balances(wallet_id, currency, available)
  values (v_user_id, 'GHS', 0)
  on conflict (wallet_id, currency) do nothing;

  select * into v_balance from public.wallet_balances
  where wallet_id = v_user_id and currency = 'GHS' for update;

  if v_balance.available < p_amount then raise exception 'Insufficient GHS balance.'; end if;

  if exists (select 1 from public.transactions where reference = v_reference) then
    select * into v_transaction from public.transactions where reference = v_reference limit 1;
    select * into v_payout from public.payout_intents where transaction_id = v_transaction.id limit 1;
    return jsonb_build_object('transaction', to_jsonb(v_transaction), 'payout', to_jsonb(v_payout), 'idempotent', true);
  end if;

  v_snapshot := jsonb_build_object(
    'kind', v_method.kind,
    'rail', v_method.rail,
    'msisdn', v_method.msisdn,
    'bank_code', v_method.bank_code,
    'account_number', v_method.account_number,
    'account_name', v_method.account_name,
    'country', v_method.country
  );

  update public.wallet_balances
  set available = available - p_amount, updated_at = timezone('utc', now())
  where wallet_id = v_user_id and currency = 'GHS';

  insert into public.transactions(wallet_id, type, amount, currency, description, status, reference, provider)
  values (v_user_id, 'Withdrawal', p_amount, 'GHS', 'GHS withdrawal to local payment method', 'Pending', v_reference, 'fincra')
  returning * into v_transaction;

  insert into public.payout_intents(wallet_id, transaction_id, withdrawal_method_id, reference, amount, currency, destination_kind, destination_snapshot, status)
  values (v_user_id, v_transaction.id, v_method.id, v_reference, p_amount, 'GHS', v_method.kind, v_snapshot, 'Pending')
  returning * into v_payout;

  return jsonb_build_object('transaction', to_jsonb(v_transaction), 'payout', to_jsonb(v_payout), 'idempotent', false);
end;
$$;

create or replace function public.attach_ghana_payout_provider_reference(
  p_reference text,
  p_provider_reference text,
  p_provider_status text default null
)
returns public.payout_intents
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare v_payout public.payout_intents%rowtype;
begin
  if p_provider_reference is null or length(trim(p_provider_reference)) = 0 then raise exception 'Provider reference is required.'; end if;
  update public.payout_intents
  set provider_reference = trim(p_provider_reference), provider_status = nullif(trim(coalesce(p_provider_status,'')), ''), status = case when lower(coalesce(p_provider_status,'')) = 'successful' then 'Completed' when lower(coalesce(p_provider_status,'')) = 'failed' then 'Failed' when lower(coalesce(p_provider_status,'')) = 'processing' then 'Processing' else status end, updated_at = timezone('utc', now())
  where reference = upper(trim(p_reference))
  returning * into v_payout;
  if not found then raise exception 'Payout intent not found.'; end if;
  return v_payout;
end;
$$;

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
set search_path = pg_catalog, public
as $$
declare
  v_payout public.payout_intents%rowtype;
  v_final_status text := initcap(lower(trim(p_status)));
  v_should_refund boolean := false;
begin
  if v_final_status not in ('Completed','Failed','Cancelled','Processing','Pending') then raise exception 'Invalid payout status.'; end if;

  select * into v_payout from public.payout_intents where reference = upper(trim(p_reference)) for update;
  if not found then raise exception 'Payout intent not found.'; end if;

  if p_provider_reference is not null and length(trim(p_provider_reference)) > 0 then
    if v_payout.provider_reference is not null and v_payout.provider_reference <> trim(p_provider_reference) then raise exception 'Provider reference mismatch.'; end if;
    v_payout.provider_reference := trim(p_provider_reference);
  end if;

  if v_payout.status in ('Completed','Failed','Cancelled') then
    return v_payout;
  end if;

  v_should_refund := v_final_status in ('Failed','Cancelled');

  if v_should_refund then
    update public.wallet_balances
    set available = available + v_payout.amount, updated_at = timezone('utc', now())
    where wallet_id = v_payout.wallet_id and currency = 'GHS';
  end if;

  update public.payout_intents
  set status = v_final_status,
      provider_reference = v_payout.provider_reference,
      provider_status = nullif(trim(coalesce(p_provider_status,'')), ''),
      failure_reason = case when v_final_status in ('Failed','Cancelled') then nullif(trim(coalesce(p_failure_reason,'')), '') else null end,
      completed_at = case when v_final_status in ('Completed','Failed','Cancelled') then timezone('utc', now()) else completed_at end,
      updated_at = timezone('utc', now())
  where id = v_payout.id
  returning * into v_payout;

  update public.transactions
  set status = v_final_status,
      provider_reference = v_payout.provider_reference
  where id = v_payout.transaction_id;

  return v_payout;
end;
$$;

revoke all on function public.create_ghana_payout(numeric, text, uuid) from public, anon;
grant execute on function public.create_ghana_payout(numeric, text, uuid) to authenticated;
revoke all on function public.attach_ghana_payout_provider_reference(text, text, text) from public, anon, authenticated;
grant execute on function public.attach_ghana_payout_provider_reference(text, text, text) to service_role;
revoke all on function public.settle_ghana_payout(text, text, text, text, text) from public, anon, authenticated;
grant execute on function public.settle_ghana_payout(text, text, text, text, text) to service_role;

comment on table public.withdrawal_methods is 'User-owned payout destinations. MVP enables Ghana mobile money; bank routes are reserved for the next payout phase.';
comment on table public.payout_intents is 'Financial payout intents. Funds are reserved atomically at creation and returned only on verified terminal failure/cancellation.';
