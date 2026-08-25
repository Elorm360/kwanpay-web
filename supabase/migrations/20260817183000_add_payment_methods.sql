create table if not exists public.payment_methods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null default 'momo',
  rail text not null,
  msisdn text not null,
  is_default boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  constraint payment_methods_kind_check check (kind = 'momo'),
  constraint payment_methods_rail_check
    check (rail in ('mtn', 'telecel', 'airteltigo')),
  constraint payment_methods_msisdn_check
    check (char_length(msisdn) = 12 and msisdn like '233%')
);

create unique index if not exists payment_methods_user_msisdn_idx
  on public.payment_methods (user_id, msisdn);

create unique index if not exists payment_methods_one_default_idx
  on public.payment_methods (user_id)
  where is_default;

alter table public.payment_methods enable row level security;

grant select, insert, update, delete on table public.payment_methods
to authenticated;
revoke all on table public.payment_methods from anon;

drop policy if exists "Users can view own payment methods" on public.payment_methods;
create policy "Users can view own payment methods"
on public.payment_methods for select to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can insert own payment methods" on public.payment_methods;
create policy "Users can insert own payment methods"
on public.payment_methods for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can update own payment methods" on public.payment_methods;
create policy "Users can update own payment methods"
on public.payment_methods for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "Users can delete own payment methods" on public.payment_methods;
create policy "Users can delete own payment methods"
on public.payment_methods for delete to authenticated
using (user_id = auth.uid());
