-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

comment on function public.create_ghana_payout_from_payment_method(numeric, text, uuid) is 'Atomically reserves GHS wallet funds and creates an idempotent Fincra payout intent using an existing user-owned Ghana Mobile Money payment method.';
