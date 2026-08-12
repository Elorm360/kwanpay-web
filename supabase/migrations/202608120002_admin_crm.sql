create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null unique,
  display_name text not null,
  role text not null default 'operator'
    check (role in ('viewer', 'operator', 'admin', 'owner')),
  is_active boolean not null default true,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  full_name text not null,
  country text not null,
  audience_role text not null,
  sources text[] not null default '{}'
    check (sources <@ array['waitlist', 'demo']::text[]),
  company text,
  message text,
  status text not null default 'new'
    check (status in ('new', 'contacted', 'qualified', 'nurture', 'converted', 'closed_lost')),
  priority text not null default 'normal'
    check (priority in ('low', 'normal', 'high')),
  assigned_admin_id uuid references public.admin_users (id) on delete set null,
  internal_notes text,
  follow_up_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Preserve legacy audience labels such as "Platform Owner". New submissions
-- are still restricted to current values by application validation.
alter table public.leads
  drop constraint if exists leads_audience_role_check;

create unique index if not exists leads_email_unique_idx
  on public.leads (email);
create index if not exists leads_created_at_idx on public.leads (created_at desc);
create index if not exists leads_status_idx on public.leads (status);
create index if not exists leads_owner_idx on public.leads (assigned_admin_id);
create index if not exists leads_follow_up_idx on public.leads (follow_up_at);

create table if not exists public.lead_audit_events (
  id bigint generated always as identity primary key,
  lead_id uuid not null references public.leads (id) on delete cascade,
  actor_admin_id uuid references public.admin_users (id) on delete set null,
  action text not null,
  changes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists lead_audit_lead_created_idx
  on public.lead_audit_events (lead_id, created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists leads_set_updated_at on public.leads;
create trigger leads_set_updated_at
  before update on public.leads
  for each row execute function public.set_updated_at();

drop trigger if exists admin_users_set_updated_at on public.admin_users;
create trigger admin_users_set_updated_at
  before update on public.admin_users
  for each row execute function public.set_updated_at();

alter table public.leads enable row level security;
alter table public.admin_users enable row level security;
alter table public.lead_audit_events enable row level security;

revoke all on table public.leads from anon, authenticated;
revoke all on table public.admin_users from anon, authenticated;
revoke all on table public.lead_audit_events from anon, authenticated;

insert into public.leads (
  email,
  full_name,
  country,
  audience_role,
  sources,
  created_at,
  updated_at
)
select
  lower(ea.email),
  ea.full_name,
  ea.country,
  ea.role,
  array['waitlist']::text[],
  coalesce(ea.created_at, now()),
  coalesce(ea.created_at, now())
from public.early_access ea
on conflict (email) do update set
  sources = array(
    select distinct unnest(public.leads.sources || array['waitlist']::text[])
  ),
  updated_at = now();

do $$
begin
  if to_regclass('public.demo_requests') is not null then
    execute $migration$
      insert into public.leads (
        email,
        full_name,
        country,
        audience_role,
        sources,
        company,
        message,
        created_at,
        updated_at
      )
      select
        lower(dr.email),
        dr.full_name,
        dr.country,
        case
          when dr.user_type in ('Traveler', 'Tourism Business', 'Investor', 'Partner', 'Developer')
            then dr.user_type
          else 'Traveler'
        end,
        array['demo']::text[],
        dr.company,
        dr.message,
        coalesce(dr.created_at, now()),
        coalesce(dr.created_at, now())
      from public.demo_requests dr
      on conflict (email) do update set
        sources = array(
          select distinct unnest(public.leads.sources || array['demo']::text[])
        ),
        company = coalesce(public.leads.company, excluded.company),
        message = coalesce(public.leads.message, excluded.message),
        updated_at = now()
    $migration$;
  end if;
end
$$;
