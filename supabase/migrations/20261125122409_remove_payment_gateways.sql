-- Remove the Fiatsend, Fincra, Flutterwave and Moolre integrations and make
-- the money-movement core gateway-neutral until a new gateway is chosen.
--
-- Live data at the time of writing (2026-11-25): only 7 Failed test top-ups
-- (6 moolre, 1 fincra); no pending collections and no payouts. Nothing needs
-- refunding. Historic rows keep their provider values, so those two ids stay
-- in the registry as retired entries.



-- 1. Provider registry --------------------------------------------------------
-- Single source of truth for which payment gateways exist. To add a gateway
-- later: insert a row, deploy its Edge Functions, then set is_active = true.
create table public.payment_providers (
  id text primary key check (id ~ '^[a-z][a-z0-9_]{1,31}$'),
  display_name text not null,
  supports_collections boolean not null default false,
  supports_payouts boolean not null default false,
  is_active boolean not null default false,
  retired_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  constraint payment_providers_retired_not_active
    check (not (is_active and retired_at is not null))
);

comment on table public.payment_providers is
  'Payment gateways KwanPay can route Mobile Money collections and payouts through.';

-- At most one active gateway per direction keeps routing unambiguous.
create unique index payment_providers_one_active_collector
  on public.payment_providers ((true)) where is_active and supports_collections;
create unique index payment_providers_one_active_payout
  on public.payment_providers ((true)) where is_active and supports_payouts;

insert into public.payment_providers
  (id, display_name, supports_collections, supports_payouts, is_active, retired_at)
values
  ('moolre', 'Moolre', true, false, false, timezone('utc', now())),
  ('fincra', 'Fincra', true, true, false, timezone('utc', now()));

alter table public.payment_providers enable row level security;
revoke all on table public.payment_providers from anon, authenticated;
grant select on table public.payment_providers to authenticated;

create policy "Signed-in users can read payment providers"
on public.payment_providers
for select
to authenticated
using (true);

-- 2. Intents reference the registry instead of hard-coded lists --------------
alter table public.collection_intents
  drop constraint collection_intents_provider_check,
  add constraint collection_intents_provider_fkey
    foreign key (provider) references public.payment_providers (id);

alter table public.payout_intents
  alter column provider drop default,
  drop constraint payout_intents_provider_check,
  add constraint payout_intents_provider_fkey
    foreign key (provider) references public.payment_providers (id);

-- 3. Drop gateway-specific functions -----------------------------------------
drop function public.assign_pending_collection_provider(text, text);
drop function public.assign_pending_payout_provider(text, text);
drop function public.attach_flutterwave_charge(text, text);
drop function public.attach_moolre_provider_reference(text, text);
drop function public.settle_moolre_transaction(text, text, text);
drop function public.settle_ghana_collection(text, text, text, uuid);
drop function public.initiate_ghana_collection(numeric, text, text, text);

-- 4. Gateway-neutral helpers and core functions -------------------------------

-- The active payout gateway, or null while withdrawals are unavailable.
create function public.active_payout_provider()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select id from public.payment_providers
  where is_active and supports_payouts
  limit 1;
$$;

revoke all on function public.active_payout_provider() from public, anon, authenticated;
grant execute on function public.active_payout_provider() to service_role;

create or replace function public.attach_provider_reference(
  p_reference text,
  p_provider text,
  p_provider_reference text
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_tx public.transactions;
begin
  if current_setting('request.jwt.claim.role', true) <> 'service_role' then
    raise exception 'Only the service role may attach provider references';
  end if;

  if not exists (
    select 1 from public.payment_providers
    where id = p_provider and is_active
  ) then
    raise exception 'Unsupported provider';
  end if;

  if nullif(trim(p_reference), '') is null or nullif(trim(p_provider_reference), '') is null then
    raise exception 'Reference and provider reference are required';
  end if;

  update public.transactions
  set provider = p_provider,
      provider_reference = trim(p_provider_reference)
  where reference = upper(trim(p_reference))
    and status = 'Pending'
    and provider is not null
    and provider = p_provider
  returning * into v_tx;

  if not found then
    raise exception 'Pending provider transaction not found';
  end if;

  update public.collection_intents
  set provider = p_provider,
      provider_event_id = trim(p_provider_reference)
  where transaction_id = v_tx.id
    and reference = v_tx.reference
    and status = 'pending';

  return v_tx;
end;
$function$;

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

  -- Lock the row so two settlements cannot credit the same transaction.
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

  -- Idempotency: already in the requested terminal state.
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

  -- Completed: only a registered collection gateway may credit a wallet. A
  -- gateway that was active when the payment started can still settle it
  -- after being deactivated, so customer money is never stranded.
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

  -- Credit first; if it fails the status update below rolls back too.
  perform public.adjust_wallet_balance(
    existing_txn.wallet_id,
    existing_txn.currency,
    existing_txn.amount
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

-- Payouts no longer hard-code a gateway: they use the active payout provider
-- and refuse cleanly while none is configured. Bodies are otherwise unchanged.
create or replace function public.create_ghana_payout(
  p_amount numeric,
  p_reference text,
  p_withdrawal_method_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path to 'pg_catalog', 'public'
as $function$
declare
  v_user_id uuid := auth.uid();
  v_method public.withdrawal_methods%rowtype;
  v_balance public.wallet_balances%rowtype;
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

  insert into public.wallet_balances(wallet_id, currency, available)
  values (v_user_id, 'GHS', 0)
  on conflict (wallet_id, currency) do nothing;

  select * into v_balance from public.wallet_balances
  where wallet_id = v_user_id and currency = 'GHS' for update;

  if v_balance.available < p_amount then raise exception 'Insufficient GHS balance.'; end if;

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
  values (v_user_id, 'Withdrawal', p_amount, 'GHS', 'GHS withdrawal to local payment method', 'Pending', v_reference, v_provider)
  returning * into v_transaction;

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
set search_path to 'pg_catalog', 'public'
as $function$
declare
  v_user_id uuid := auth.uid();
  v_method public.payment_methods%rowtype;
  v_balance public.wallet_balances%rowtype;
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

  insert into public.wallet_balances(wallet_id, currency, available)
  values (v_user_id, 'GHS', 0)
  on conflict (wallet_id, currency) do nothing;

  select * into v_balance from public.wallet_balances where wallet_id = v_user_id and currency = 'GHS' for update;
  if v_balance.available < p_amount then raise exception 'Insufficient GHS balance.'; end if;

  v_snapshot := jsonb_build_object('kind', v_method.kind, 'rail', v_method.rail, 'msisdn', v_method.msisdn, 'country', 'GH');

  update public.wallet_balances set available = available - p_amount, updated_at = timezone('utc', now()) where wallet_id = v_user_id and currency = 'GHS';

  insert into public.transactions(wallet_id, type, amount, currency, description, status, reference, provider)
  values (v_user_id, 'Withdrawal', p_amount, 'GHS', 'GHS withdrawal to saved Mobile Money', 'Pending', v_reference, v_provider)
  returning * into v_transaction;

  insert into public.payout_intents(wallet_id, transaction_id, withdrawal_method_id, reference, amount, currency, destination_kind, destination_snapshot, status, provider)
  values (v_user_id, v_transaction.id, null, v_reference, p_amount, 'GHS', 'momo', v_snapshot, 'Pending', v_provider)
  returning * into v_payout;

  return jsonb_build_object('transaction', to_jsonb(v_transaction), 'payout', to_jsonb(v_payout), 'idempotent', false);
end;
$function$;
