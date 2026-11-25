-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

alter function public.adjust_wallet_balance(uuid, text, numeric) set search_path = '';
alter function public.transfer_funds(text, numeric, text, text) set search_path = '';
alter function public.convert_wallet_funds(text, text, numeric, text) set search_path = '';
alter function public.pay_operator_bill(text, text, numeric, text, text) set search_path = '';
alter function public.settle_ghana_collection(text, text, text, uuid) set search_path = '';

revoke execute on function public.adjust_wallet_balance(uuid, text, numeric) from public, anon, authenticated, service_role;
revoke execute on function public.transfer_funds(text, numeric, text, text) from public, anon;
revoke execute on function public.convert_wallet_funds(text, text, numeric, text) from public, anon;
revoke execute on function public.pay_operator_bill(text, text, numeric, text, text) from public, anon;
revoke execute on function public.settle_ghana_collection(text, text, text, uuid) from public, anon, authenticated;

grant execute on function public.transfer_funds(text, numeric, text, text) to authenticated, service_role;
grant execute on function public.convert_wallet_funds(text, text, numeric, text) to authenticated, service_role;
grant execute on function public.pay_operator_bill(text, text, numeric, text, text) to authenticated, service_role;
grant execute on function public.settle_ghana_collection(text, text, text, uuid) to service_role;
