-- Direct table UPDATEs from service_role were revoked. Switching a Ghana
-- collection from the initiate_ghana_collection default (moolre) onto
-- Fincra, and failing an unpaid pending after a provider error, must go
-- through SECURITY DEFINER RPCs.

create or replace function public.assign_pending_collection_provider(
  p_reference text,
  p_provider text
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $$
declare
  txn public.transactions;
  normalized_reference text := upper(trim(coalesce(p_reference, '')));
  normalized_provider text := lower(trim(coalesce(p_provider, '')));
  label text;
begin
  if normalized_reference = ''
     or normalized_reference not like 'KWP-TXN-%'
     or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  if normalized_provider not in ('moolre', 'fincra', 'flutterwave') then
    raise exception 'Unsupported provider';
  end if;

  select *
  into txn
  from public.transactions
  where reference = normalized_reference
  for update;

  if not found then
    raise exception 'Transaction not found';
  end if;

  if txn.status <> 'Pending' then
    raise exception 'Transaction is not pending';
  end if;

  if txn.provider_reference is not null
     and txn.provider is not null
     and txn.provider <> normalized_provider then
    raise exception 'This reference belongs to another payment provider';
  end if;

  label := case normalized_provider
    when 'fincra' then 'Fincra'
    when 'flutterwave' then 'Flutterwave'
    else 'Moolre'
  end;

  update public.transactions
  set
    provider = normalized_provider,
    description = regexp_replace(
      coalesce(description, ''),
      ' · (Moolre|Fincra|Flutterwave)$',
      ' · ' || label
    )
  where id = txn.id
  returning * into txn;

  update public.collection_intents
  set provider = normalized_provider
  where transaction_id = txn.id
    and reference = txn.reference
    and status = 'pending';

  return txn;
end;
$$;

revoke all on function public.assign_pending_collection_provider(text, text) from public;
revoke all on function public.assign_pending_collection_provider(text, text) from anon;
revoke all on function public.assign_pending_collection_provider(text, text) from authenticated;
grant execute on function public.assign_pending_collection_provider(text, text) to service_role;

create or replace function public.fail_pending_collection(
  p_reference text
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $$
begin
  return public.settle_provider_transaction(p_reference, 'Failed', null);
end;
$$;

revoke all on function public.fail_pending_collection(text) from public;
revoke all on function public.fail_pending_collection(text) from anon;
revoke all on function public.fail_pending_collection(text) from authenticated;
grant execute on function public.fail_pending_collection(text) to service_role;
