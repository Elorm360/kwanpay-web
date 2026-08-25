drop function if exists public.transfer_funds(uuid, text, numeric);

create or replace function public.resolve_wallet_recipient(
  p_wallet_id text
)
returns table (
  wallet_id text,
  full_name text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  normalized_wallet_id text := upper(trim(p_wallet_id));
  recipient_uuid uuid;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if normalized_wallet_id = '' then
    raise exception 'Wallet ID is required';
  end if;

  select w.id
  into recipient_uuid
  from public.wallets w
  where upper(w.wallet_id) = normalized_wallet_id
    and w.status = 'Active';

  if recipient_uuid is null then
    return;
  end if;

  if recipient_uuid = caller then
    raise exception 'Cannot send to yourself';
  end if;

  return query
  select
    w.wallet_id,
    coalesce(nullif(trim(p.full_name), ''), 'KwanPay user')
  from public.wallets w
  join public.profiles p on p.id = w.id
  where w.id = recipient_uuid;
end;
$$;

revoke all on function public.resolve_wallet_recipient(text) from public;
revoke all on function public.resolve_wallet_recipient(text) from anon;
grant execute on function public.resolve_wallet_recipient(text) to authenticated;

create or replace function public.transfer_funds(
  p_receiver_wallet_id text,
  p_transfer_amount numeric,
  p_reference text
)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  normalized_wallet_id text := upper(trim(p_receiver_wallet_id));
  normalized_reference text := upper(trim(p_reference));
  receiver_uuid uuid;
  existing_txn public.transactions;
  send_txn public.transactions;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if p_transfer_amount is null or p_transfer_amount <= 0 then
    raise exception 'Invalid amount';
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
      and existing_txn.type = 'Send'
      and existing_txn.amount = p_transfer_amount
      and existing_txn.currency = 'USD'
      and existing_txn.provider = 'kwanpay_transfer'
      and existing_txn.provider_reference = normalized_wallet_id
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
  end if;

  select w.id
  into receiver_uuid
  from public.wallets w
  where upper(w.wallet_id) = normalized_wallet_id
    and w.status = 'Active';

  if receiver_uuid is null then
    raise exception 'Recipient wallet not found';
  end if;

  if receiver_uuid = caller then
    raise exception 'Cannot send to yourself';
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
    'Send',
    p_transfer_amount,
    'USD',
    'Pending',
    'Transfer Sent',
    normalized_reference,
    'kwanpay_transfer',
    normalized_wallet_id
  )
  returning * into send_txn;

  perform public.adjust_wallet_balance(
    caller,
    'USD',
    -p_transfer_amount
  );

  perform public.adjust_wallet_balance(
    receiver_uuid,
    'USD',
    p_transfer_amount
  );

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
    receiver_uuid,
    'Receive',
    p_transfer_amount,
    'USD',
    'Completed',
    'Transfer Received',
    normalized_reference || '-R',
    'kwanpay_transfer',
    normalized_reference
  );

  update public.transactions
  set status = 'Completed'
  where id = send_txn.id
  returning * into send_txn;

  return send_txn;
exception
  when unique_violation then
    select *
    into existing_txn
    from public.transactions
    where reference = normalized_reference;

    if found
      and existing_txn.wallet_id = caller
      and existing_txn.type = 'Send'
      and existing_txn.amount = p_transfer_amount
      and existing_txn.currency = 'USD'
      and existing_txn.provider = 'kwanpay_transfer'
      and existing_txn.provider_reference = normalized_wallet_id
      and existing_txn.status = 'Completed' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
end;
$$;

revoke all on function public.transfer_funds(text, numeric, text) from public;
revoke all on function public.transfer_funds(text, numeric, text) from anon;
grant execute on function public.transfer_funds(text, numeric, text)
to authenticated;
