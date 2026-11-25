-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

drop policy if exists "Users can create own transactions" on public.transactions;
alter table public.transactions alter column status set default 'Pending';
alter table public.transactions alter column reference set not null;
create unique index if not exists transactions_reference_unique_idx on public.transactions (reference);
