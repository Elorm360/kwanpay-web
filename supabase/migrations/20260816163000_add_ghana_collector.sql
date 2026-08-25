create table if not exists public.collection_intents (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets(id) on delete cascade,
  transaction_id uuid not null references public.transactions(id) on delete cascade,
  reference text not null,
  amount numeric not null,
  currency text not null,
  rail text not null,
  msisdn text not null,
  provider text not null,
  status text not null default 'pending',
  provider_event_id text,
  created_at timestamptz not null default timezone('utc', now()),
  settled_at timestamptz,
  constraint collection_intents_amount_positive check (amount > 0),
  constraint collection_intents_currency_ghs check (currency = 'GHS'),
  constraint collection_intents_status_check
    check (status in ('pending', 'settled', 'failed', 'cancelled')),
  constraint collection_intents_rail_check
    check (rail in ('mtn', 'telecel', 'airteltigo')),
  constraint collection_intents_provider_check
    check (provider in ('ghana_collector_test', 'flutterwave', 'hubtel'))
);

create unique index if not exists collection_intents_reference_idx
  on public.collection_intents (reference);

create unique index if not exists collection_intents_transaction_id_idx
  on public.collection_intents (transaction_id);

create unique index if not exists collection_intents_provider_event_id_idx
  on public.collection_intents (provider_event_id)
  where provider_event_id is not null;

create index if not exists collection_intents_wallet_id_created_at_idx
  on public.collection_intents (wallet_id, created_at desc);

alter table public.collection_intents enable row level security;

grant select on table public.collection_intents to authenticated;
revoke insert, update, delete on table public.collection_intents from anon, authenticated;

drop policy if exists "Users can view own collection intents" on public.collection_intents;
create policy "Users can view own collection intents"
on public.collection_intents
for select
to authenticated
using (wallet_id = auth.uid());

create or replace function public.initiate_ghana_collection(
  p_amount numeric,
  p_reference text,
  p_rail text,
  p_msisdn text
)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  normalized_reference text := upper(trim(p_reference));
  normalized_rail text := lower(trim(p_rail));
  normalized_msisdn text := regexp_replace(coalesce(p_msisdn, ''), '[^0-9]', '', 'g');
  local_prefix text;
  rail_name text;
  existing_txn public.transactions;
  funding_txn public.transactions;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if p_amount is null or p_amount <= 0 then
    raise exception 'Invalid amount';
  end if;

  if normalized_reference = ''
    or normalized_reference not like 'KWP-TXN-%'
    or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  if normalized_rail not in ('mtn', 'telecel', 'airteltigo') then
    raise exception 'Unsupported Mobile Money network';
  end if;

  if length(normalized_msisdn) = 10 and left(normalized_msisdn, 1) = '0' then
    normalized_msisdn := '233' || substring(normalized_msisdn from 2);
  elsif length(normalized_msisdn) = 9 then
    normalized_msisdn := '233' || normalized_msisdn;
  end if;

  if length(normalized_msisdn) <> 12 or left(normalized_msisdn, 3) <> '233' then
    raise exception 'Enter a valid Ghana Mobile Money number';
  end if;

  local_prefix := '0' || substring(normalized_msisdn from 4 for 2);

  if normalized_rail = 'mtn' then
    rail_name := 'MTN MoMo';
    if local_prefix not in ('024', '025', '053', '054', '055', '059') then
      raise exception 'That number does not look like an MTN line';
    end if;
  elsif normalized_rail = 'telecel' then
    rail_name := 'Telecel Cash';
    if local_prefix not in ('020', '050') then
      raise exception 'That number does not look like a Telecel line';
    end if;
  else
    rail_name := 'AirtelTigo Money';
    if local_prefix not in ('026', '027', '056', '057') then
      raise exception 'That number does not look like an AirtelTigo line';
    end if;
  end if;

  select *
  into existing_txn
  from public.transactions
  where reference = normalized_reference;

  if found then
    if existing_txn.wallet_id = caller
      and existing_txn.type = 'Top Up'
      and existing_txn.amount = p_amount
      and existing_txn.currency = 'GHS'
      and existing_txn.provider = 'ghana_collector_test' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
  end if;

  insert into public.transactions (
    wallet_id,
    type,
    amount,
    currency,
    status,
    description,
    reference,
    provider,
    provider_reference
  )
  values (
    caller,
    'Top Up',
    p_amount,
    'GHS',
    'Pending',
    rail_name || ' · collector test',
    normalized_reference,
    'ghana_collector_test',
    normalized_msisdn
  )
  returning * into funding_txn;

  insert into public.collection_intents (
    wallet_id,
    transaction_id,
    reference,
    amount,
    currency,
    rail,
    msisdn,
    provider,
    status
  )
  values (
    caller,
    funding_txn.id,
    normalized_reference,
    p_amount,
    'GHS',
    normalized_rail,
    normalized_msisdn,
    'ghana_collector_test',
    'pending'
  );

  return funding_txn;
exception
  when unique_violation then
    select *
    into existing_txn
    from public.transactions
    where reference = normalized_reference;

    if found
      and existing_txn.wallet_id = caller
      and existing_txn.type = 'Top Up'
      and existing_txn.amount = p_amount
      and existing_txn.currency = 'GHS'
      and existing_txn.provider = 'ghana_collector_test' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
end;
$$;

revoke all on function public.initiate_ghana_collection(numeric, text, text, text) from public;
revoke all on function public.initiate_ghana_collection(numeric, text, text, text) from anon;
grant execute on function public.initiate_ghana_collection(numeric, text, text, text)
to authenticated;

create or replace function public.settle_ghana_collection(
  p_reference text,
  p_status text,
  p_provider_event_id text,
  p_actor_wallet_id uuid default null
)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized_reference text := upper(trim(p_reference));
  normalized_status text := initcap(trim(p_status));
  intent public.collection_intents;
  txn public.transactions;
  intent_status text;
begin
  if normalized_status not in ('Completed', 'Failed', 'Cancelled') then
    raise exception 'Invalid status';
  end if;

  if nullif(trim(coalesce(p_provider_event_id, '')), '') is null then
    raise exception 'Missing collector event';
  end if;

  select *
  into intent
  from public.collection_intents
  where reference = normalized_reference
  for update;

  if not found then
    raise exception 'Collection not found';
  end if;

  if p_actor_wallet_id is not null then
    if intent.wallet_id <> p_actor_wallet_id then
      raise exception 'Not allowed';
    end if;

    if intent.provider <> 'ghana_collector_test' then
      raise exception 'Live collections cannot be settled from the app';
    end if;
  end if;

  select *
  into txn
  from public.transactions
  where id = intent.transaction_id
  for update;

  if not found then
    raise exception 'Transaction not found';
  end if;

  if intent.provider_event_id = p_provider_event_id
    and txn.status = normalized_status then
    return txn;
  end if;

  if intent.status <> 'pending' or txn.status <> 'Pending' then
    if txn.status = normalized_status then
      return txn;
    end if;
    raise exception 'Collection can no longer be updated';
  end if;

  intent_status := case normalized_status
    when 'Completed' then 'settled'
    when 'Failed' then 'failed'
    else 'cancelled'
  end;

  update public.collection_intents
  set
    status = intent_status,
    provider_event_id = p_provider_event_id,
    settled_at = timezone('utc', now())
  where id = intent.id;

  update public.transactions
  set
    status = normalized_status,
    provider_reference = coalesce(txn.provider_reference, intent.msisdn)
  where id = txn.id
  returning * into txn;

  if normalized_status = 'Completed' then
    perform public.adjust_wallet_balance(
      txn.wallet_id,
      txn.currency,
      txn.amount
    );
  end if;

  return txn;
end;
$$;

revoke all on function public.settle_ghana_collection(text, text, text, uuid) from public;
revoke all on function public.settle_ghana_collection(text, text, text, uuid) from anon;
revoke all on function public.settle_ghana_collection(text, text, text, uuid) from authenticated;
grant execute on function public.settle_ghana_collection(text, text, text, uuid)
to service_role;
