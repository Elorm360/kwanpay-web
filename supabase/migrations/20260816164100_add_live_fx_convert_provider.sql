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
  fx_provider text;
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
  into quote_row
  from public.get_fx_quote(from_code, to_code, p_from_amount);

  if quote_row.to_amount is null or quote_row.to_amount <= 0 then
    raise exception 'No rate available for this pair';
  end if;

  to_amount := quote_row.to_amount;
  fx_provider := case
    when quote_row.is_test then 'kwanpay_fx_test'
    else 'kwanpay_fx'
  end;

  select *
  into existing_txn
  from public.transactions
  where reference = normalized_reference;

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
    fx_provider,
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
    fx_provider,
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
      and existing_txn.provider in ('kwanpay_fx', 'kwanpay_fx_test')
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
end;
$$;

revoke all on function public.convert_wallet_funds(text, text, numeric, text) from public;
revoke all on function public.convert_wallet_funds(text, text, numeric, text) from anon;
grant execute on function public.convert_wallet_funds(text, text, numeric, text)
to authenticated;
