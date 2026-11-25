-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create unique index if not exists transactions_reference_unique_idx on public.transactions (reference) where reference is not null;

create index if not exists transactions_wallet_created_at_idx on public.transactions (wallet_id, created_at desc);

create index if not exists transactions_provider_reference_idx on public.transactions (provider, provider_reference) where provider_reference is not null;

alter table public.transactions drop constraint if exists transactions_amount_positive;
alter table public.transactions add constraint transactions_amount_positive check (amount > 0);

alter table public.transactions drop constraint if exists transactions_status_valid;
alter table public.transactions add constraint transactions_status_valid check (status in ('Pending', 'Completed', 'Failed', 'Cancelled'));

alter table public.transactions drop constraint if exists transactions_reference_not_blank;
alter table public.transactions add constraint transactions_reference_not_blank check (reference is null or length(trim(reference)) > 0);
