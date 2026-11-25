-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

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
as $function$
declare
  normalized_reference text := upper(trim(coalesce(p_reference, '')));
  normalized_status text := initcap(lower(trim(coalesce(p_status, ''))));
  normalized_event_id text := trim(coalesce(p_provider_event_id, ''));
  intent public.collection_intents;
  txn public.transactions;
  existing_event_intent public.collection_intents;
  settled_txn public.transactions;
begin
  if normalized_reference = '' then
    raise exception 'Missing collection reference';
  end if;

  if normalized_status not in ('Completed', 'Failed', 'Cancelled') then
    raise exception 'Invalid status';
  end if;

  if normalized_event_id = '' then
    raise exception 'Missing provider event';
  end if;

  select *
  into intent
  from public.collection_intents
  where reference = normalized_reference
  for update;

  if not found then
    raise exception 'Collection not found';
  end if;

  if intent.provider <> 'flutterwave' then
    raise exception 'Collection provider is not Flutterwave';
  end if;

  if p_actor_wallet_id is not null and intent.wallet_id <> p_actor_wallet_id then
    raise exception 'Collection does not belong to this wallet';
  end if;

  select *
  into txn
  from public.transactions
  where id = intent.transaction_id
  for update;

  if not found then
    raise exception 'Transaction not found';
  end if;

  if txn.reference <> normalized_reference then
    raise exception 'Collection transaction reference mismatch';
  end if;

  if txn.provider <> 'flutterwave' then
    raise exception 'Transaction provider is not Flutterwave';
  end if;

  if intent.provider_event_id = normalized_event_id and txn.status = normalized_status then
    return txn;
  end if;

  select *
  into existing_event_intent
  from public.collection_intents
  where provider = 'flutterwave'
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

  settled_txn := public.settle_provider_transaction(
    normalized_reference,
    normalized_status,
    normalized_event_id
  );

  if normalized_status = 'Failed' then
    update public.collection_intents
    set
      status = 'failed',
      provider_event_id = normalized_event_id,
      settled_at = timezone('utc', now())
    where id = intent.id;
  elsif normalized_status = 'Cancelled' then
    update public.collection_intents
    set
      status = 'cancelled',
      provider_event_id = normalized_event_id,
      settled_at = timezone('utc', now())
    where id = intent.id;
  end if;

  return settled_txn;
end;
$function$;

revoke all on function public.settle_ghana_collection(text, text, text, uuid) from anon, authenticated;
grant execute on function public.settle_ghana_collection(text, text, text, uuid) to service_role;
