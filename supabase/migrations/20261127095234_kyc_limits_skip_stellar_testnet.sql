-- KYC limits govern money held in KwanPay wallets. A Stellar testnet USDC
-- payment is paid from the user's own on-chain account, not the KwanPay
-- balance, and there is no USDC rate in fx_rates, so the limit trigger was
-- refusing every one with "No exchange rate for USDC". Leave those out of
-- both the check and the usage totals.
create or replace function public.kyc_enforce_limits()
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
  if new.type not in ('Send', 'Payment', 'Withdrawal')
    or new.status not in ('Pending', 'Completed')
    or new.provider is not distinct from 'stellar_testnet' then
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

create or replace function public.kyc_outgoing_usage(p_user_id uuid, p_since timestamptz)
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
    and t.provider is distinct from 'stellar_testnet'
    and t.created_at >= p_since;
$$;
revoke execute on function public.kyc_outgoing_usage(uuid, timestamptz) from public, anon, authenticated;
