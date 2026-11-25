-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

revoke execute on function public.set_stellar_public_key(text) from public;
revoke execute on function public.set_stellar_public_key(text) from anon;
grant execute on function public.set_stellar_public_key(text) to authenticated;
