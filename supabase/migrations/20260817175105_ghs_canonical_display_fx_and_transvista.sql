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
  code,
  name,
  category,
  location,
  country,
  currency,
  status
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

create or replace function public.get_fx_quote(
  p_from_currency text,
  p_to_currency text,
  p_from_amount numeric
)
returns table (
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
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  from_code text := upper(trim(p_from_currency));
  to_code text := upper(trim(p_to_currency));
  quoted_rate numeric;
  quoted_source text;
  quoted_is_test boolean;
  quoted_as_of timestamptz;
  from_usd numeric;
  usd_to numeric;
  amount numeric := coalesce(p_from_amount, 0);
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if from_code not in ('USD', 'GHS', 'NGN', 'KES', 'ZAR')
    or to_code not in ('USD', 'GHS', 'NGN', 'KES', 'ZAR') then
    raise exception 'Unsupported currency';
  end if;

  if amount < 0 then
    raise exception 'Invalid amount';
  end if;

  if from_code = to_code then
    return query
    select
      from_code,
      to_code,
      amount,
      round(amount, 2),
      1::numeric,
      'identity'::text,
      false,
      timezone('utc', now());
    return;
  end if;

  select
    r.rate,
    r.source,
    r.is_test,
    r.as_of
  into
    quoted_rate,
    quoted_source,
    quoted_is_test,
    quoted_as_of
  from public.fx_rates r
  where r.base_currency = from_code
    and r.quote_currency = to_code;

  if not found then
    select r.rate, r.source, r.is_test, r.as_of
    into from_usd, quoted_source, quoted_is_test, quoted_as_of
    from public.fx_rates r
    where r.base_currency = from_code
      and r.quote_currency = 'USD';

    select r.rate
    into usd_to
    from public.fx_rates r
    where r.base_currency = 'USD'
      and r.quote_currency = to_code;

    if from_usd is null or usd_to is null then
      raise exception 'No rate available for this pair';
    end if;

    quoted_rate := from_usd * usd_to;
  end if;

  return query
  select
    from_code,
    to_code,
    amount,
    round(amount * quoted_rate, 2),
    quoted_rate,
    quoted_source,
    quoted_is_test,
    quoted_as_of;
end;
$$;

revoke all on function public.get_fx_quote(text, text, numeric) from public;
revoke all on function public.get_fx_quote(text, text, numeric) from anon;
grant execute on function public.get_fx_quote(text, text, numeric) to authenticated;

create or replace function public.upsert_live_fx_rates(
  p_source text,
  p_as_of timestamptz,
  p_rates jsonb
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  source_name text := nullif(trim(p_source), '');
  as_of_at timestamptz := coalesce(p_as_of, timezone('utc', now()));
  pair jsonb;
  base_code text;
  quote_code text;
  pair_rate numeric;
  upserted integer := 0;
begin
  if source_name is null then
    raise exception 'Missing FX source';
  end if;

  if p_rates is null or jsonb_typeof(p_rates) <> 'array' then
    raise exception 'Invalid FX payload';
  end if;

  for pair in
    select value
    from jsonb_array_elements(p_rates)
  loop
    base_code := upper(trim(pair ->> 'base_currency'));
    quote_code := upper(trim(pair ->> 'quote_currency'));
    pair_rate := (pair ->> 'rate')::numeric;

    if base_code not in ('USD', 'GHS', 'NGN', 'KES', 'ZAR')
      or quote_code not in ('USD', 'GHS', 'NGN', 'KES', 'ZAR')
      or base_code = quote_code then
      raise exception 'Unsupported FX pair';
    end if;

    if pair_rate is null or pair_rate <= 0 then
      raise exception 'Invalid FX rate';
    end if;

    insert into public.fx_rates (
      base_currency,
      quote_currency,
      rate,
      source,
      is_test,
      as_of
    )
    values (
      base_code,
      quote_code,
      pair_rate,
      source_name,
      false,
      as_of_at
    )
    on conflict (base_currency, quote_currency) do update
    set
      rate = excluded.rate,
      source = excluded.source,
      is_test = false,
      as_of = excluded.as_of;

    upserted := upserted + 1;
  end loop;

  if upserted < 8 then
    raise exception 'Expected at least eight FX pairs';
  end if;

  return upserted;
end;
$$;

revoke all on function public.upsert_live_fx_rates(text, timestamptz, jsonb) from public;
revoke all on function public.upsert_live_fx_rates(text, timestamptz, jsonb) from anon;
revoke all on function public.upsert_live_fx_rates(text, timestamptz, jsonb) from authenticated;
grant execute on function public.upsert_live_fx_rates(text, timestamptz, jsonb)
to service_role;

create or replace function public.pay_operator_bill(
  p_operator_code text,
  p_account_number text,
  p_amount numeric,
  p_currency text,
  p_reference text
)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  normalized_code text := lower(trim(p_operator_code));
  normalized_currency text := upper(trim(p_currency));
  normalized_reference text := upper(trim(p_reference));
  normalized_account text;
  merchant public.tourism_merchants;
  existing_txn public.transactions;
  payment_txn public.transactions;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if p_amount is null or p_amount <= 0 then
    raise exception 'Invalid amount';
  end if;

  if normalized_currency <> 'GHS' then
    raise exception 'Pay in Ghana cedis';
  end if;

  if normalized_reference = ''
    or normalized_reference not like 'KWP-TXN-%'
    or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  select *
  into merchant
  from public.tourism_merchants
  where code = normalized_code
  for update;

  if not found or merchant.status <> 'live' then
    raise exception 'Unknown operator';
  end if;

  normalized_account := upper(regexp_replace(
    coalesce(p_account_number, ''),
    '[^A-Za-z0-9]',
    '',
    'g'
  ));

  if length(normalized_account) < 6 or length(normalized_account) > 24 then
    raise exception 'Enter a valid booking reference';
  end if;

  select *
  into existing_txn
  from public.transactions
  where reference = normalized_reference;

  if found then
    if existing_txn.wallet_id = caller
      and existing_txn.type = 'Payment'
      and existing_txn.amount = p_amount
      and existing_txn.currency = 'GHS'
      and existing_txn.provider = 'kwanpay_merchant'
      and existing_txn.provider_reference = normalized_code || ':' || normalized_account
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
  end if;

  insert into public.transactions (
    wallet_id,
    type,
    amount,
    currency,
    status,
    description,
    reference,
    provider,
    provider_reference
  )
  values (
    caller,
    'Payment',
    p_amount,
    'GHS',
    'Pending',
    merchant.name,
    normalized_reference,
    'kwanpay_merchant',
    normalized_code || ':' || normalized_account
  )
  returning * into payment_txn;

  perform public.adjust_wallet_balance(
    caller,
    'GHS',
    -p_amount
  );

  update public.tourism_merchants
  set
    available = available + p_amount,
    updated_at = timezone('utc', now())
  where code = merchant.code;

  update public.transactions
  set status = 'Completed'
  where id = payment_txn.id
  returning * into payment_txn;

  return payment_txn;
exception
  when unique_violation then
    select *
    into existing_txn
    from public.transactions
    where reference = normalized_reference;

    if found
      and existing_txn.wallet_id = caller
      and existing_txn.type = 'Payment'
      and existing_txn.amount = p_amount
      and existing_txn.currency = 'GHS'
      and existing_txn.provider = 'kwanpay_merchant'
      and existing_txn.provider_reference = normalized_code || ':' || normalized_account
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
end;
$$;

revoke all on function public.pay_operator_bill(text, text, numeric, text, text) from public;
revoke all on function public.pay_operator_bill(text, text, numeric, text, text) from anon;
grant execute on function public.pay_operator_bill(text, text, numeric, text, text)
to authenticated;
