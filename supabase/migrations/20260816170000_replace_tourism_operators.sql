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
  operator_name text;
  existing_txn public.transactions;
  payment_txn public.transactions;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if p_amount is null or p_amount <= 0 then
    raise exception 'Invalid amount';
  end if;

  if normalized_currency not in ('USD', 'GHS', 'NGN') then
    raise exception 'Unsupported currency';
  end if;

  if normalized_reference = ''
    or normalized_reference not like 'KWP-TXN-%'
    or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  case normalized_code
    when 'vip_jeoun' then
      operator_name := 'VIP Jeoun';
    when 'stc' then
      operator_name := 'STC';
    when 'airport_shuttle' then
      operator_name := 'Airport Shuttle';
    when 'savannah_trails' then
      operator_name := 'Savannah Trails';
    when 'cape_coast_tours' then
      operator_name := 'Cape Coast Tours';
    when 'labadi_beach_hotel' then
      operator_name := 'Labadi Beach Hotel';
    else
      raise exception 'Unknown operator';
  end case;

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
      and existing_txn.currency = normalized_currency
      and existing_txn.provider = 'kwanpay_operator_test'
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
    normalized_currency,
    'Pending',
    operator_name || ' · test',
    normalized_reference,
    'kwanpay_operator_test',
    normalized_code || ':' || normalized_account
  )
  returning * into payment_txn;

  perform public.adjust_wallet_balance(
    caller,
    normalized_currency,
    -p_amount
  );

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
      and existing_txn.currency = normalized_currency
      and existing_txn.provider = 'kwanpay_operator_test'
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
