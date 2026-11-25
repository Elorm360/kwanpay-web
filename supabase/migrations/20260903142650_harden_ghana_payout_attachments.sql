-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

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
  set provider_reference = trim(p_provider_reference),
      provider_status = nullif(trim(coalesce(p_provider_status,'')), ''),
      updated_at = timezone('utc', now())
  where reference = upper(trim(p_reference))
  returning * into v_payout;
  if not found then raise exception 'Payout intent not found.'; end if;
  return v_payout;
end;
$$;

revoke all on function public.attach_ghana_payout_provider_reference(text, text, text) from public, anon, authenticated;
grant execute on function public.attach_ghana_payout_provider_reference(text, text, text) to service_role;
