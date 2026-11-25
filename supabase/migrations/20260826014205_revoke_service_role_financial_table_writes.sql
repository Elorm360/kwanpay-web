-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

revoke insert, update, delete
on table public.transactions
from service_role;

revoke insert, update, delete
on table public.collection_intents
from service_role;

revoke insert, update, delete
on table public.wallet_balances
from service_role;
