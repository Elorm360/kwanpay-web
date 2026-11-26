-- get_my_kyc_status also returns what ID verification unlocks, so the app
-- shows it from the one call it already makes instead of a second query.
create or replace function public.get_my_kyc_status()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  caller uuid := auth.uid();
  limits public.kyc_tiers;
  next_tier public.kyc_tiers;
  latest public.kyc_submissions;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  select * into limits from public.kyc_tiers where tier = public.kyc_tier_of(caller);
  if limits.tier < 2 then
    select * into next_tier from public.kyc_tiers where tier = 2;
  end if;
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
    'next_tier_name', next_tier.name,
    'next_daily_limit', next_tier.daily_limit,
    'next_monthly_limit', next_tier.monthly_limit,
    'submission_status', latest.status,
    'rejection_reason', latest.rejection_reason,
    'submitted_at', latest.created_at
  );
end;
$$;
