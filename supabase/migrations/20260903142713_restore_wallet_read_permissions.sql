-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

grant select on public.transactions to authenticated;
grant select on public.wallet_balances to authenticated;
grant select on public.payout_intents to authenticated;
