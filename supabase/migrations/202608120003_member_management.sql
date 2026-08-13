alter table public.leads
  add column if not exists archived_at timestamptz,
  add column if not exists archived_by_admin_id uuid
    references public.admin_users (id) on delete set null;

create index if not exists leads_archived_at_idx
  on public.leads (archived_at);

create table if not exists public.member_deletion_events (
  id bigint generated always as identity primary key,
  entity_type text not null check (entity_type in ('lead', 'admin_user')),
  entity_id uuid not null,
  actor_admin_id uuid references public.admin_users (id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.member_deletion_events enable row level security;
revoke all on public.member_deletion_events from anon, authenticated;
