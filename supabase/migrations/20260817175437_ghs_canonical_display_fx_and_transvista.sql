-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create table if not exists public.tourism_merchants (
  code text primary key,
  name text not null,
  category text not null,
  location text not null,
  country text not null default 'Ghana',
  currency text not null default 'GHS',
  available numeric not null default 0,
  status text not null default 'live',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint tourism_merchants_available_nonnegative check (available >= 0),
  constraint tourism_merchants_currency_ghs check (currency = 'GHS'),
  constraint tourism_merchants_status_check
    check (status in ('live', 'coming_soon'))
);

alter table public.tourism_merchants enable row level security;

revoke all on table public.tourism_merchants from anon, authenticated;
grant select on table public.tourism_merchants to authenticated;

drop policy if exists "Authenticated users can view live tourism merchants"
  on public.tourism_merchants;
create policy "Authenticated users can view live tourism merchants"
on public.tourism_merchants
for select
to authenticated
using (status = 'live');

insert into public.tourism_merchants (
  code, name, category, location, country, currency, status
)
values (
  'transvista_africa',
  'TransVista Africa Ltd',
  'Transport',
  'Accra',
  'Ghana',
  'GHS',
  'live'
)
on conflict (code) do update
set
  name = excluded.name,
  category = excluded.category,
  location = excluded.location,
  country = excluded.country,
  status = excluded.status,
  updated_at = timezone('utc', now());
