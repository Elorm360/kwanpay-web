-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

drop index if exists public.collection_intents_provider_event_id_idx;
create unique index collection_intents_provider_event_id_idx
  on public.collection_intents (provider, provider_event_id)
  where provider_event_id is not null and btrim(provider_event_id) <> '';

create or replace function public.settle_ghana_collection(
  p_reference text,
  p_status text,
  p_provider_event_id text,
  p_actor_wallet_id uuid default null
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $$
declare
  normalized_reference text := upper(trim(p_reference));
  normalized_status text := initcap(trim(p_status));
  normalized_event_id text := trim(p_provider_event_id);
  intent public.collection_intents;
  txn public.transactions;
  intent_status text;
  existing_event_intent public.collection_intents;
begin
  if normalized_status not in ('Completed', 'Failed', 'Cancelled') then
    raise exception 'Invalid status';
  end if;

  if normalized_event_id = '' then
    raise exception 'Missing provider event';
  end if;

  select * into intent
  from public.collection_intents
  where reference = normalized_reference
  for update;

  if not found then
    raise exception 'Collection not found';
  end if;

  if intent.provider <> 'flutterwave' then
    raise exception 'Collection provider is not Flutterwave';
  end if;

  select * into txn
  from public.transactions
  where id = intent.transaction_id
  for update;

  if not found then
    raise exception 'Transaction not found';
  end if;

  if txn.provider <> 'flutterwave' then
    raise exception 'Transaction provider is not Flutterwave';
  end if;

  if intent.provider_event_id = normalized_event_id and txn.status = normalized_status then
    return txn;
  end if;

  select * into existing_event_intent
  from public.collection_intents
  where provider = intent.provider
    and provider_event_id = normalized_event_id
    and id <> intent.id
  for update;

  if found then
    raise exception 'Provider event has already been assigned to another collection';
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
  set status = intent_status,
      provider_event_id = normalized_event_id,
      settled_at = timezone('utc', now())
  where id = intent.id;

  update public.transactions
  set status = normalized_status,
      provider_reference = normalized_event_id
  where id = txn.id
  returning * into txn;

  if normalized_status = 'Completed' then
    perform public.adjust_wallet_balance(txn.wallet_id, txn.currency, txn.amount);
  end if;

  return txn;
end;
$$;

revoke execute on function public.settle_ghana_collection(text, text, text, uuid) from public, anon, authenticated;
grant execute on function public.settle_ghana_collection(text, text, text, uuid) to service_role;
