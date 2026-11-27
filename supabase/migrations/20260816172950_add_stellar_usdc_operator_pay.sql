-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create table if not exists public.tourism_stellar_accounts (
  code text primary key,
  name text not null,
  stellar_public_key text not null,
  created_at timestamptz not null default timezone('utc', now()),
  constraint tourism_stellar_accounts_key_format
    check (stellar_public_key ~ '^G[A-Z2-7]{55}$')
);

create unique index if not exists tourism_stellar_accounts_public_key_idx
  on public.tourism_stellar_accounts (stellar_public_key);

alter table public.tourism_stellar_accounts enable row level security;

grant select on table public.tourism_stellar_accounts to authenticated;
revoke insert, update, delete on table public.tourism_stellar_accounts
from anon, authenticated;

drop policy if exists "Authenticated users can view tourism Stellar accounts"
  on public.tourism_stellar_accounts;
create policy "Authenticated users can view tourism Stellar accounts"
on public.tourism_stellar_accounts
for select
to authenticated
using (true);

insert into public.tourism_stellar_accounts (code, name, stellar_public_key)
values
  ('vip_jeoun', 'VIP Jeoun', 'GDSAMVMKUSSFNM3B4SM7FLASIMCHZD3VH462MUJJGNMZ6G5UWCM36VMH'),
  ('stc', 'STC', 'GC6XRZCJAIOXPXCNWIKZG7OU7UGU76BARQYQFNLOFLD7LUCX6ADBG7DM'),
  ('airport_shuttle', 'Airport Shuttle', 'GBDOC6RS4ZS25OP7EXTZ4XFB5MZ2I4APD54TFZR53CKK3BGWRRPKYH2N'),
  ('savannah_trails', 'Savannah Trails', 'GCIMWSMY7YCQCTVMSQ4VUYVQGXRXDHKMU57KKGTDXL5YRJR4OQFLAMTZ'),
  ('cape_coast_tours', 'Cape Coast Tours', 'GDVBOPN3QGTH4ASDHPOW2WF2D3E55AREL7UCYBFMNNBBPEFD2DUFACX2'),
  ('labadi_beach_hotel', 'Labadi Beach Hotel', 'GCOYWCSJ3KWGNBVHXCXEBNRWV3WTHESN36GB7QFVNYYATITOB5F4MBZL')
on conflict (code) do update
set
  name = excluded.name,
  stellar_public_key = excluded.stellar_public_key;
