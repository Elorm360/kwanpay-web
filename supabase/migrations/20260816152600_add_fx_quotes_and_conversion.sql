create table if not exists public.fx_rates (
  base_currency text not null,
  quote_currency text not null,
  rate numeric not null,
  source text not null default 'kwanpay_test',
  is_test boolean not null default true,
  as_of timestamptz not null default timezone('utc', now()),
  primary key (base_currency, quote_currency),
  constraint fx_rates_rate_positive check (rate > 0),
  constraint fx_rates_currencies_differ check (base_currency <> quote_currency)
);

alter table public.fx_rates enable row level security;

grant select on table public.fx_rates to authenticated;
revoke insert, update, delete on table public.fx_rates from anon, authenticated;

drop policy if exists "Authenticated users can view fx rates" on public.fx_rates;
create policy "Authenticated users can view fx rates"
on public.fx_rates
for select
to authenticated
using (true);

insert into public.fx_rates (
  base_currency,
  quote_currency,
  rate,
  source,
  is_test
)
values
  ('USD', 'GHS', 15.20, 'kwanpay_test', true),
  ('GHS', 'USD', 0.06578947, 'kwanpay_test', true),
  ('USD', 'NGN', 1600.00, 'kwanpay_test', true),
  ('NGN', 'USD', 0.00062500, 'kwanpay_test', true),
  ('GHS', 'NGN', 105.26315789, 'kwanpay_test', true),
  ('NGN', 'GHS', 0.00950000, 'kwanpay_test', true)
on conflict (base_currency, quote_currency) do nothing;

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
  amount numeric := coalesce(p_from_amount, 0);
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if from_code not in ('USD', 'GHS', 'NGN')
    or to_code not in ('USD', 'GHS', 'NGN') then
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
    raise exception 'No rate available for this pair';
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

create or replace function public.convert_wallet_funds(
  p_from_currency text,
  p_to_currency text,
  p_from_amount numeric,
  p_reference text
)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  from_code text := upper(trim(p_from_currency));
  to_code text := upper(trim(p_to_currency));
  normalized_reference text := upper(trim(p_reference));
  quote_row record;
  existing_txn public.transactions;
  debit_txn public.transactions;
  to_amount numeric;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if p_from_amount is null or p_from_amount <= 0 then
    raise exception 'Invalid amount';
  end if;

  if from_code = to_code then
    raise exception 'Choose two different currencies';
  end if;

  if normalized_reference = ''
    or normalized_reference not like 'KWP-TXN-%'
    or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  select *
  into existing_txn
  from public.transactions
  where reference = normalized_reference;

  if found then
    if existing_txn.wallet_id = caller
      and existing_txn.type = 'Convert Out'
      and existing_txn.amount = p_from_amount
      and existing_txn.currency = from_code
      and existing_txn.provider = 'kwanpay_fx_test'
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
  end if;

  select *
  into quote_row
  from public.get_fx_quote(from_code, to_code, p_from_amount);

  if quote_row.to_amount is null or quote_row.to_amount <= 0 then
    raise exception 'No rate available for this pair';
  end if;

  to_amount := quote_row.to_amount;

  perform public.adjust_wallet_balance(caller, from_code, -p_from_amount);
  perform public.adjust_wallet_balance(caller, to_code, to_amount);

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
    'Convert Out',
    p_from_amount,
    from_code,
    'Completed',
    'Converted to ' || to_code,
    normalized_reference,
    'kwanpay_fx_test',
    to_code || ':' || to_amount::text
  )
  returning * into debit_txn;

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
    'Convert In',
    to_amount,
    to_code,
    'Completed',
    'Converted from ' || from_code,
    normalized_reference || '-C',
    'kwanpay_fx_test',
    from_code || ':' || p_from_amount::text
  );

  return debit_txn;
exception
  when unique_violation then
    select *
    into existing_txn
    from public.transactions
    where reference = normalized_reference;

    if found
      and existing_txn.wallet_id = caller
      and existing_txn.type = 'Convert Out'
      and existing_txn.amount = p_from_amount
      and existing_txn.currency = from_code
      and existing_txn.provider = 'kwanpay_fx_test'
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
end;
$$;

revoke all on function public.convert_wallet_funds(text, text, numeric, text) from public;
revoke all on function public.convert_wallet_funds(text, text, numeric, text) from anon;
grant execute on function public.convert_wallet_funds(text, text, numeric, text) to authenticated;

create or replace function public.reconcile_wallet()
returns table (
  currency text,
  ledger_available numeric,
  expected_available numeric,
  pending_amount numeric,
  matched boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  return query
  with movements as (
    select
      upper(t.currency) as currency,
      coalesce(sum(t.amount) filter (
        where t.status = 'Completed'
          and t.type in ('Top Up', 'Receive', 'Convert In')
      ), 0) as credits,
      coalesce(sum(t.amount) filter (
        where t.status = 'Completed'
          and t.type in ('Send', 'Payment', 'Convert Out')
      ), 0) as debits,
      coalesce(sum(t.amount) filter (
        where t.status = 'Pending'
          and t.type in ('Top Up', 'Send', 'Payment')
      ), 0) as pending
    from public.transactions t
    where t.wallet_id = caller
    group by 1
  ),
  ledger as (
    select
      upper(b.currency) as currency,
      b.available
    from public.wallet_balances b
    where b.wallet_id = caller
  ),
  usd_wallet as (
    select round(coalesce(w.balance, 0), 2) as balance
    from public.wallets w
    where w.id = caller
  ),
  currencies as (
    select m.currency from movements m
    union
    select l.currency from ledger l
  )
  select
    c.currency,
    coalesce(l.available, 0) as ledger_available,
    coalesce(m.credits, 0) - coalesce(m.debits, 0) as expected_available,
    coalesce(m.pending, 0) as pending_amount,
    (
      round(coalesce(l.available, 0), 2)
        = round(coalesce(m.credits, 0) - coalesce(m.debits, 0), 2)
      and (
        c.currency <> 'USD'
        or round(coalesce(l.available, 0), 2)
          = coalesce((select uw.balance from usd_wallet uw), 0)
      )
    ) as matched
  from currencies c
  left join movements m on m.currency = c.currency
  left join ledger l on l.currency = c.currency
  order by c.currency;
end;
$$;
