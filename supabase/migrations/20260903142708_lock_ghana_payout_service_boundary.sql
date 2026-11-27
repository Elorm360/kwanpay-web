-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

revoke all on table public.payout_intents from anon, authenticated;
revoke all on table public.wallet_balances from anon, authenticated;
revoke all on table public.transactions from anon, authenticated;
