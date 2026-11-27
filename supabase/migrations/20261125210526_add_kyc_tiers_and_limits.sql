-- Phase 2, milestone 2: KYC tiers and transaction limits.
--
-- Every user has a KYC tier (0 when nothing is on record). Each tier caps
-- outgoing money (Send, Payment, Withdrawal) per transaction, per UTC day and
-- per UTC calendar month, counted in Ghana cedis. The cap is enforced by a
-- trigger on public.transactions, so every money function is covered without
-- each one repeating the check, and a client cannot route around it.
--
-- The limit figures below are placeholders for testing. They must be set
-- against the Bank of Ghana e-money rules before launch; changing them is an
-- UPDATE on public.kyc_tiers, no code change.

-- ── Tiers ────────────────────────────────────────────────────────────────
create table public.kyc_tiers (
  tier smallint primary key check (tier between 0 and 3),
  name text not null,
  requirement text not null,
  per_transaction_limit numeric(14, 2) not null check (per_transaction_limit > 0),
  daily_limit numeric(14, 2) not null check (daily_limit > 0),
  monthly_limit numeric(14, 2) not null check (monthly_limit > 0),
  limit_currency text not null default 'GHS' check (limit_currency = 'GHS'),
  check (per_transaction_limit <= daily_limit and daily_limit <= monthly_limit)
);

insert into public.kyc_tiers (tier, name, requirement, per_transaction_limit, daily_limit, monthly_limit) values
  (0, 'Basic', 'Verified email', 500, 1000, 3000),
  (1, 'Phone verified', 'Verified phone number', 2000, 5000, 20000),
  (2, 'ID verified', 'Ghana Card or passport, reviewed by KwanPay', 10000, 20000, 100000),
  (3, 'Full', 'ID plus proof of address, reviewed by KwanPay', 50000, 100000, 500000);

alter table public.kyc_tiers enable row level security;
create policy "Anyone signed in can read tiers" on public.kyc_tiers
  for select to authenticated using (true);
revoke insert, update, delete on public.kyc_tiers from anon, authenticated;

-- ── Each user's tier ─────────────────────────────────────────────────────
-- Kept apart from profiles, which users may update themselves.
create table public.user_kyc (
  user_id uuid primary key references auth.users (id) on delete cascade,
  tier smallint not null default 0 references public.kyc_tiers (tier),
  updated_at timestamptz not null default now()
);

alter table public.user_kyc enable row level security;
create policy "Users can view own tier" on public.user_kyc
  for select to authenticated using (user_id = (select auth.uid()));
revoke insert, update, delete on public.user_kyc from anon, authenticated;

create function public.kyc_tier_of(p_user_id uuid)
returns smallint
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select tier from public.user_kyc where user_id = p_user_id), 0::smallint);
$$;
revoke execute on function public.kyc_tier_of(uuid) from public, anon, authenticated;

-- ── Document submissions ─────────────────────────────────────────────────
create table public.kyc_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  target_tier smallint not null references public.kyc_tiers (tier),
  document_type text not null check (document_type in ('ghana_card', 'passport')),
  document_number text not null check (length(document_number) between 5 and 32),
  front_path text not null,
  back_path text,
  selfie_path text not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  rejection_reason text,
  reviewed_by uuid references public.admin_users (id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  check (status <> 'rejected' or rejection_reason is not null)
);

create index kyc_submissions_user_idx on public.kyc_submissions (user_id, created_at desc);
create index kyc_submissions_queue_idx on public.kyc_submissions (created_at) where status = 'pending';
create unique index kyc_submissions_one_pending on public.kyc_submissions (user_id) where status = 'pending';

alter table public.kyc_submissions enable row level security;
create policy "Users can view own submissions" on public.kyc_submissions
  for select to authenticated using (user_id = (select auth.uid()));
revoke insert, update, delete on public.kyc_submissions from anon, authenticated;

-- ── Private storage for ID images ────────────────────────────────────────
-- Files live under <user id>/..., users can add and read only their own,
-- and nobody but the service role can change or remove them.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('kyc-documents', 'kyc-documents', false, 5242880, array['image/jpeg', 'image/png'])
on conflict (id) do nothing;

create policy "Users upload own KYC files" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'kyc-documents'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "Users read own KYC files" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'kyc-documents'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- ── Submit documents (app) ───────────────────────────────────────────────
create function public.submit_kyc_documents(
  p_document_type text,
  p_document_number text,
  p_front_path text,
  p_back_path text,
  p_selfie_path text
)
returns public.kyc_submissions
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := auth.uid();
  prefix text;
  doc_type text := lower(trim(p_document_type));
  doc_number text := upper(regexp_replace(coalesce(p_document_number, ''), '\s', '', 'g'));
  path text;
  result public.kyc_submissions;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;
  prefix := caller::text || '/';

  if doc_type not in ('ghana_card', 'passport') then
    raise exception 'Choose Ghana Card or passport';
  end if;
  if doc_type = 'ghana_card' and doc_number !~ '^GHA-?[0-9]{9}-?[0-9]$' then
    raise exception 'Enter the Ghana Card number as shown, e.g. GHA-123456789-0';
  end if;
  if doc_type = 'passport' and doc_number !~ '^[A-Z0-9]{6,12}$' then
    raise exception 'Enter a valid passport number';
  end if;
  if doc_type = 'ghana_card' and coalesce(p_back_path, '') = '' then
    raise exception 'Add a photo of the back of the card';
  end if;

  foreach path in array array_remove(array[p_front_path, p_back_path, p_selfie_path], null) loop
    if left(path, length(prefix)) <> prefix
      or not exists (select 1 from storage.objects o where o.bucket_id = 'kyc-documents' and o.name = path) then
      raise exception 'A photo is missing. Upload it again.';
    end if;
  end loop;

  if public.kyc_tier_of(caller) >= 2 then
    raise exception 'Your ID is already verified';
  end if;
  if exists (select 1 from public.kyc_submissions where user_id = caller and status = 'pending') then
    raise exception 'Your documents are already being reviewed';
  end if;

  insert into public.kyc_submissions (
    user_id, target_tier, document_type, document_number, front_path, back_path, selfie_path
  ) values (
    caller, 2, doc_type, doc_number, p_front_path, nullif(p_back_path, ''), p_selfie_path
  )
  returning * into result;

  return result;
end;
$$;
revoke execute on function public.submit_kyc_documents(text, text, text, text, text) from public, anon;
grant execute on function public.submit_kyc_documents(text, text, text, text, text) to authenticated;

-- ── Review (web admin, server side only) ─────────────────────────────────
create function public.admin_review_kyc(
  p_admin_id uuid,
  p_submission_id uuid,
  p_approve boolean,
  p_reason text default null
)
returns public.kyc_submissions
language plpgsql
security definer
set search_path = ''
as $$
declare
  submission public.kyc_submissions;
begin
  if not exists (
    select 1 from public.admin_users
    where id = p_admin_id and is_active and role in ('operator', 'admin', 'owner')
  ) then
    raise exception 'Not allowed to review KYC';
  end if;

  select * into submission from public.kyc_submissions where id = p_submission_id for update;
  if not found then
    raise exception 'Submission not found';
  end if;
  if submission.status <> 'pending' then
    raise exception 'This submission was already reviewed';
  end if;
  if not p_approve and coalesce(trim(p_reason), '') = '' then
    raise exception 'Give the user a reason for the rejection';
  end if;

  update public.kyc_submissions
  set status = case when p_approve then 'approved' else 'rejected' end,
      rejection_reason = case when p_approve then null else trim(p_reason) end,
      reviewed_by = p_admin_id,
      reviewed_at = now()
  where id = p_submission_id
  returning * into submission;

  if p_approve then
    insert into public.user_kyc (user_id, tier, updated_at)
    values (submission.user_id, submission.target_tier, now())
    on conflict (user_id) do update
      set tier = greatest(public.user_kyc.tier, excluded.tier), updated_at = now();
  end if;

  return submission;
end;
$$;
revoke execute on function public.admin_review_kyc(uuid, uuid, boolean, text) from public, anon, authenticated;
grant execute on function public.admin_review_kyc(uuid, uuid, boolean, text) to service_role;

-- ── Limit enforcement ────────────────────────────────────────────────────
create function public.kyc_amount_in_ghs(p_amount numeric, p_currency text)
returns numeric
language plpgsql
stable
set search_path = ''
as $$
declare
  code text := upper(p_currency);
  direct numeric;
  via_usd numeric;
begin
  if code = 'GHS' then
    return p_amount;
  end if;
  select rate into direct from public.fx_rates where base_currency = code and quote_currency = 'GHS';
  if direct is not null then
    return round(p_amount * direct, 2);
  end if;
  select a.rate * b.rate into via_usd
  from public.fx_rates a
  join public.fx_rates b on b.base_currency = 'USD' and b.quote_currency = 'GHS'
  where a.base_currency = code and a.quote_currency = 'USD';
  if via_usd is null then
    raise exception 'No exchange rate for % to check your limit', code;
  end if;
  return round(p_amount * via_usd, 2);
end;
$$;

create function public.kyc_outgoing_usage(p_user_id uuid, p_since timestamptz)
returns numeric
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(sum(public.kyc_amount_in_ghs(t.amount, t.currency)), 0)
  from public.transactions t
  where t.wallet_id = p_user_id
    and t.type in ('Send', 'Payment', 'Withdrawal')
    and t.status in ('Pending', 'Completed')
    and t.created_at >= p_since;
$$;
revoke execute on function public.kyc_outgoing_usage(uuid, timestamptz) from public, anon, authenticated;

create function public.kyc_enforce_limits()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  limits public.kyc_tiers;
  amount_ghs numeric;
  day_start timestamptz := date_trunc('day', now() at time zone 'utc') at time zone 'utc';
  month_start timestamptz := date_trunc('month', now() at time zone 'utc') at time zone 'utc';
begin
  if new.type not in ('Send', 'Payment', 'Withdrawal') then
    return new;
  end if;

  -- One check at a time per user, so two parallel sends cannot both fit
  -- under the same remaining allowance.
  perform pg_advisory_xact_lock(hashtextextended('kyc-limit:' || new.wallet_id::text, 0));

  select * into limits from public.kyc_tiers where tier = public.kyc_tier_of(new.wallet_id);
  amount_ghs := public.kyc_amount_in_ghs(new.amount, new.currency);

  if amount_ghs > limits.per_transaction_limit then
    raise exception 'This is over your limit of GHS % per transaction. Verify your ID to raise it.',
      to_char(limits.per_transaction_limit, 'FM999G999G990D00')
      using errcode = 'P0001', hint = 'kyc_limit_transaction';
  end if;
  if public.kyc_outgoing_usage(new.wallet_id, day_start) + amount_ghs > limits.daily_limit then
    raise exception 'This would take you over your daily limit of GHS %. Try a smaller amount or verify your ID.',
      to_char(limits.daily_limit, 'FM999G999G990D00')
      using errcode = 'P0001', hint = 'kyc_limit_daily';
  end if;
  if public.kyc_outgoing_usage(new.wallet_id, month_start) + amount_ghs > limits.monthly_limit then
    raise exception 'This would take you over your monthly limit of GHS %. Verify your ID to raise it.',
      to_char(limits.monthly_limit, 'FM999G999G990D00')
      using errcode = 'P0001', hint = 'kyc_limit_monthly';
  end if;

  return new;
end;
$$;
revoke execute on function public.kyc_enforce_limits() from public, anon, authenticated;

create trigger transactions_kyc_limits
  before insert on public.transactions
  for each row execute function public.kyc_enforce_limits();

-- ── What the app shows ───────────────────────────────────────────────────
create function public.get_my_kyc_status()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  caller uuid := auth.uid();
  limits public.kyc_tiers;
  latest public.kyc_submissions;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  select * into limits from public.kyc_tiers where tier = public.kyc_tier_of(caller);
  select * into latest from public.kyc_submissions
  where user_id = caller order by created_at desc limit 1;

  return jsonb_build_object(
    'tier', limits.tier,
    'tier_name', limits.name,
    'currency', limits.limit_currency,
    'per_transaction_limit', limits.per_transaction_limit,
    'daily_limit', limits.daily_limit,
    'monthly_limit', limits.monthly_limit,
    'used_today', public.kyc_outgoing_usage(caller, date_trunc('day', now() at time zone 'utc') at time zone 'utc'),
    'used_this_month', public.kyc_outgoing_usage(caller, date_trunc('month', now() at time zone 'utc') at time zone 'utc'),
    'submission_status', latest.status,
    'rejection_reason', latest.rejection_reason,
    'submitted_at', latest.created_at
  );
end;
$$;
revoke execute on function public.get_my_kyc_status() from public, anon;
grant execute on function public.get_my_kyc_status() to authenticated;
