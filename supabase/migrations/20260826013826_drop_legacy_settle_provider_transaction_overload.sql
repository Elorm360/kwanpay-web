-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

drop function if exists public.settle_provider_transaction(text, text, text, text);

revoke execute on function public.settle_provider_transaction(text, text, text) from public;
revoke execute on function public.settle_provider_transaction(text, text, text) from anon;
revoke execute on function public.settle_provider_transaction(text, text, text) from authenticated;
revoke execute on function public.settle_provider_transaction(text, text, text) from service_role;
