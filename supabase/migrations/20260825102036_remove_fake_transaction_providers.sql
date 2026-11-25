-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create or replace function public.get_fx_quote(p_from_currency text, p_to_currency text, p_from_amount numeric)
returns table(from_currency text, to_currency text, from_amount numeric, to_amount numeric, rate numeric, source text, is_test boolean, as_of timestamptz)
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
    select from_code, to_code, amount, round(amount, 2), 1::numeric,
           'identity'::text, false, timezone('utc', now());
    return;
  end if;

  select r.rate, r.source, r.as_of
  into quoted_rate, quoted_source, quoted_as_of
  from public.fx_rates r
  where r.base_currency = from_code
    and r.quote_currency = to_code;

  if not found then
    select r.rate, r.source, r.as_of
    into from_usd, quoted_source, quoted_as_of
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
  select from_code, to_code, amount, round(amount * quoted_rate, 2),
         quoted_rate, quoted_source, false, quoted_as_of;
end;
$$;

create or replace function public.convert_wallet_funds(p_from_currency text, p_to_currency text, p_from_amount numeric, p_reference text)
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
  fx_provider text := 'kwanpay_fx';
begin
  if caller is null then raise exception 'Not authenticated'; end if;
  if p_from_amount is null or p_from_amount <= 0 then raise exception 'Invalid amount'; end if;
  if from_code = to_code then raise exception 'Choose two different currencies'; end if;
  if normalized_reference = '' or normalized_reference not like 'KWP-TXN-%' or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  select * into quote_row from public.get_fx_quote(from_code, to_code, p_from_amount);
  if quote_row.to_amount is null or quote_row.to_amount <= 0 then raise exception 'No rate available for this pair'; end if;

  to_amount := quote_row.to_amount;

  select * into existing_txn from public.transactions where reference = normalized_reference;
  if found then
    if existing_txn.wallet_id = caller
      and existing_txn.type = 'Convert Out'
      and existing_txn.amount = p_from_amount
      and existing_txn.currency = from_code
      and existing_txn.provider = fx_provider
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;
    raise exception 'Transaction reference is already in use';
  end if;

  perform public.adjust_wallet_balance(caller, from_code, -p_from_amount);
  perform public.adjust_wallet_balance(caller, to_code, to_amount);

  insert into public.transactions (wallet_id, type, amount, currency, status, description, reference, provider, provider_reference)
  values (caller, 'Convert Out', p_from_amount, from_code, 'Completed', 'Converted to ' || to_code, normalized_reference, fx_provider, to_code || ':' || to_amount::text)
  returning * into debit_txn;

  insert into public.transactions (wallet_id, type, amount, currency, status, description, reference, provider, provider_reference)
  values (caller, 'Convert In', to_amount, to_code, 'Completed', 'Converted from ' || from_code, normalized_reference || '-C', fx_provider, from_code || ':' || p_from_amount::text);

  return debit_txn;
exception
  when unique_violation then
    select * into existing_txn from public.transactions where reference = normalized_reference;
    if found
      and existing_txn.wallet_id = caller
      and existing_txn.type = 'Convert Out'
      and existing_txn.amount = p_from_amount
      and existing_txn.currency = from_code
      and existing_txn.provider = fx_provider
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;
    raise exception 'Transaction reference is already in use';
end;
$$;

create or replace function public.settle_provider_transaction(p_reference text, p_status text, p_provider text, p_provider_reference text default null)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized_reference text := upper(trim(p_reference));
  normalized_status text := trim(p_status);
  normalized_provider text := lower(trim(p_provider));
  txn public.transactions;
begin
  if normalized_reference = '' or normalized_reference not like 'KWP-TXN-%' or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  if normalized_status not in ('Completed', 'Failed', 'Cancelled') then
    raise exception 'Invalid transaction status';
  end if;

  if normalized_provider = '' then
    raise exception 'Provider is required';
  end if;

  if normalized_provider = 'stellar_testnet' then
    raise exception 'Stellar Testnet transactions must be verified through the Stellar verification flow';
  end if;

  select * into txn from public.transactions where reference = normalized_reference for update;

  if not found then raise exception 'Transaction not found'; end if;
  if txn.provider <> normalized_provider then raise exception 'Provider does not match transaction'; end if;
  if txn.status = normalized_status then return txn; end if;
  if txn.status <> 'Pending' then raise exception 'Transaction can no longer be settled'; end if;

  if p_provider_reference is not null and trim(p_provider_reference) <> '' then
    update public.transactions
    set status = normalized_status, provider_reference = trim(p_provider_reference)
    where id = txn.id
    returning * into txn;
  else
    update public.transactions
    set status = normalized_status
    where id = txn.id
    returning * into txn;
  end if;

  if normalized_status = 'Completed' and txn.type = 'Top Up' then
    perform public.adjust_wallet_balance(txn.wallet_id, txn.currency, txn.amount);
  end if;

  return txn;
end;
$$;
