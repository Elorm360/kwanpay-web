-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create or replace function public.attach_moolre_provider_reference(
  p_reference text,
  p_provider_reference text
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $$
declare
  txn public.transactions;
begin
  if p_provider_reference is null or length(trim(p_provider_reference)) = 0 then
    raise exception 'Provider reference is required';
  end if;

  update public.transactions
  set provider_reference = trim(p_provider_reference)
  where reference = upper(trim(p_reference))
    and provider = 'moolre'
    and status = 'Pending'
  returning * into txn;

  if not found then
    raise exception 'Pending Moolre transaction not found';
  end if;

  update public.collection_intents
  set provider_event_id = trim(p_provider_reference)
  where transaction_id = txn.id
    and reference = txn.reference;

  return txn;
end;
$$;

revoke all on function public.attach_moolre_provider_reference(text, text) from public;
revoke all on function public.attach_moolre_provider_reference(text, text) from anon;
revoke all on function public.attach_moolre_provider_reference(text, text) from authenticated;
grant execute on function public.attach_moolre_provider_reference(text, text) to service_role;
