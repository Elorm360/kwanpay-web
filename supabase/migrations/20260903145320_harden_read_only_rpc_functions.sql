-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create or replace function public.get_fx_quote(
  p_from_currency text,
  p_to_currency text,
  p_from_amount numeric
)
returns table(
  from_currency text,
  to_currency text,
  from_amount numeric,
  to_amount numeric,
  rate numeric,
  source text,
  is_test boolean,
  as_of timestamptz
)
language plpgsql
security invoker
set search_path = ''
as $$
declare
  caller uuid := auth.uid();
  from_code text := upper(trim(p_from_currency));
  to_code text := upper(trim(p_to_currency));
  quoted_rate numeric;
  quoted_source text;
  quoted_as_of timestamptz;
  from_usd numeric;
  usd_to numeric;
  amount numeric := coalesce(p_from_amount, 0);
begin
  if caller is null then raise exception 'Not authenticated'; end if;
  if from_code not in ('USD','GHS','NGN','KES','ZAR') or to_code not in ('USD','GHS','NGN','KES','ZAR') then
    raise exception 'Unsupported currency';
  end if;
  if amount < 0 then raise exception 'Invalid amount'; end if;
  if from_code = to_code then
    return query select from_code, to_code, amount, round(amount, 2), 1::numeric, 'identity'::text, false, timezone('utc', now());
    return;
  end if;
  select r.rate, r.source, r.as_of into quoted_rate, quoted_source, quoted_as_of
  from public.fx_rates r where r.base_currency = from_code and r.quote_currency = to_code;
  if not found then
    select r.rate, r.source, r.as_of into from_usd, quoted_source, quoted_as_of
    from public.fx_rates r where r.base_currency = from_code and r.quote_currency = 'USD';
    select r.rate into usd_to from public.fx_rates r where r.base_currency = 'USD' and r.quote_currency = to_code;
    if from_usd is null or usd_to is null then raise exception 'No rate available for this pair'; end if;
    quoted_rate := from_usd * usd_to;
  end if;
  return query select from_code, to_code, amount, round(amount * quoted_rate, 2), quoted_rate, quoted_source, false, quoted_as_of;
end;
$$;

create or replace function public.reconcile_wallet()
returns table(currency text, ledger_available numeric, expected_available numeric, pending_amount numeric, matched boolean)
language plpgsql
security invoker
set search_path = ''
as $$
declare caller uuid := auth.uid();
begin
  if caller is null then raise exception 'Not authenticated'; end if;
  return query
  with movements as (
    select upper(t.currency) as currency,
      coalesce(sum(t.amount) filter (where t.status='Completed' and t.type in ('Top Up','Receive','Convert In')),0) as credits,
      coalesce(sum(t.amount) filter (where t.status='Completed' and t.type in ('Send','Payment','Convert Out')),0) as debits,
      coalesce(sum(t.amount) filter (where t.status='Pending' and t.type in ('Top Up','Send','Payment')),0) as pending
    from public.transactions t where t.wallet_id = caller group by 1
  ),
  ledger as (
    select upper(b.currency) as currency, b.available from public.wallet_balances b where b.wallet_id = caller
  ),
  usd_wallet as (
    select round(coalesce(w.balance,0),2) as balance from public.wallets w where w.id = caller
  ),
  currencies as (
    select m.currency from movements m union select l.currency from ledger l
  )
  select c.currency, coalesce(l.available,0), coalesce(m.credits,0)-coalesce(m.debits,0), coalesce(m.pending,0),
    (round(coalesce(l.available,0),2)=round(coalesce(m.credits,0)-coalesce(m.debits,0),2)
      and (c.currency <> 'USD' or round(coalesce(l.available,0),2)=coalesce((select uw.balance from usd_wallet uw),0)))
  from currencies c left join movements m on m.currency=c.currency left join ledger l on l.currency=c.currency order by c.currency;
end;
$$;
