-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

alter table public.profiles
add column if not exists preferred_currency text;
