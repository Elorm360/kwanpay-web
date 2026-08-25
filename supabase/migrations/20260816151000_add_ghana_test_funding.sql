create or replace function public.apply_funding_status(
  p_transaction_id uuid,
  p_status text
)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  txn public.transactions;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if p_status not in ('Completed', 'Failed', 'Cancelled') then
    raise exception 'Invalid status';
  end if;

  select *
  into txn
  from public.transactions
  where id = p_transaction_id
  for update;

  if not found then
    raise exception 'Transaction not found';
  end if;

  if txn.wallet_id <> caller then
    raise exception 'Not allowed';
  end if;

  if txn.provider not in ('kwanpay_test', 'ghana_momo_test') then
    raise exception 'Only test funding can be resolved this way';
  end if;

  if txn.status = p_status then
    return txn;
  end if;

  if txn.status <> 'Pending' then
    raise exception 'Transaction can no longer be updated';
  end if;

  update public.transactions
  set
    status = p_status,
    provider_reference = coalesce(provider_reference, 'TEST-' || p_status)
  where id = txn.id
  returning * into txn;

  if p_status = 'Completed' then
    perform public.adjust_wallet_balance(
      txn.wallet_id,
      txn.currency,
      txn.amount
    );
  end if;

  return txn;
end;
$$;

revoke all on function public.apply_funding_status(uuid, text) from public;
revoke all on function public.apply_funding_status(uuid, text) from anon;
grant execute on function public.apply_funding_status(uuid, text) to authenticated;

create or replace function public.initiate_test_funding(
  p_amount numeric,
  p_currency text,
  p_reference text,
  p_provider text,
  p_provider_reference text default null,
  p_description text default null
)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  normalized_currency text := upper(trim(p_currency));
  normalized_reference text := upper(trim(p_reference));
  normalized_provider text := lower(trim(p_provider));
  normalized_msisdn text := regexp_replace(
    coalesce(p_provider_reference, ''),
    '[^0-9]',
    '',
    'g'
  );
  existing_txn public.transactions;
  funding_txn public.transactions;
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

  if normalized_provider not in ('kwanpay_test', 'ghana_momo_test') then
    raise exception 'Unsupported funding provider';
  end if;

  if normalized_provider = 'ghana_momo_test' then
    if normalized_currency <> 'GHS' then
      raise exception 'Ghana Mobile Money test funding must be in GHS';
    end if;

    if length(normalized_msisdn) = 10 and left(normalized_msisdn, 1) = '0' then
      normalized_msisdn := '233' || substring(normalized_msisdn from 2);
    elsif length(normalized_msisdn) = 9 then
      normalized_msisdn := '233' || normalized_msisdn;
    end if;

    if length(normalized_msisdn) <> 12 or left(normalized_msisdn, 3) <> '233' then
      raise exception 'Enter a valid Ghana Mobile Money number';
    end if;
  else
    normalized_msisdn := nullif(trim(coalesce(p_provider_reference, '')), '');
  end if;

  select *
  into existing_txn
  from public.transactions
  where reference = normalized_reference;

  if found then
    if existing_txn.wallet_id = caller
      and existing_txn.type = 'Top Up'
      and existing_txn.amount = p_amount
      and existing_txn.currency = normalized_currency
      and existing_txn.provider = normalized_provider then
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
    'Top Up',
    p_amount,
    normalized_currency,
    'Pending',
    coalesce(nullif(trim(p_description), ''), 'Test funding'),
    normalized_reference,
    normalized_provider,
    normalized_msisdn
  )
  returning * into funding_txn;

  return funding_txn;
exception
  when unique_violation then
    select *
    into existing_txn
    from public.transactions
    where reference = normalized_reference;

    if found
      and existing_txn.wallet_id = caller
      and existing_txn.type = 'Top Up'
      and existing_txn.amount = p_amount
      and existing_txn.currency = normalized_currency
      and existing_txn.provider = normalized_provider then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
end;
$$;

revoke all on function public.initiate_test_funding(numeric, text, text, text, text, text) from public;
revoke all on function public.initiate_test_funding(numeric, text, text, text, text, text) from anon;
grant execute on function public.initiate_test_funding(numeric, text, text, text, text, text) to authenticated;
