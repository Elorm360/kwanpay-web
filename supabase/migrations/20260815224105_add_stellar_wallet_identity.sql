alter table public.wallets
add column if not exists stellar_public_key text;

create index if not exists wallets_stellar_public_key_idx
on public.wallets (stellar_public_key);
