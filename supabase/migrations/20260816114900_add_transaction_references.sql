alter table public.transactions
add column if not exists reference text;

alter table public.transactions
add column if not exists provider text;

alter table public.transactions
add column if not exists provider_reference text;

create unique index if not exists transactions_reference_unique_idx
on public.transactions(reference)
where reference is not null;
