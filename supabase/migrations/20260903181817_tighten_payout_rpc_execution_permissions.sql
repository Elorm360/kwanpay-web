-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

revoke execute on function public.create_ghana_payout(numeric, text, uuid) from public, anon, authenticated;
revoke execute on function public.create_ghana_payout_from_payment_method(numeric, text, uuid) from public, anon, authenticated;
grant execute on function public.create_ghana_payout(numeric, text, uuid) to service_role;
grant execute on function public.create_ghana_payout_from_payment_method(numeric, text, uuid) to service_role;
