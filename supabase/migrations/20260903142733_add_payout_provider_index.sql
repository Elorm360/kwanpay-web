-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create index if not exists payout_intents_withdrawal_method_idx on public.payout_intents(withdrawal_method_id);
