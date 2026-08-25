create or replace function public.kwanpay_transaction_reference()
returns text
language sql
volatile
set search_path = public
as $$
  select 'KWP-TXN-'
    || upper(to_hex((extract(epoch from clock_timestamp()) * 1000000)::bigint))
    || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));
$$;

revoke all on function public.kwanpay_transaction_reference() from public;
revoke all on function public.kwanpay_transaction_reference() from anon;
revoke all on function public.kwanpay_transaction_reference() from authenticated;

create or replace function public.transfer_funds(
  sender_id uuid,
  receiver_wallet_id text,
  transfer_amount numeric
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  receiver_uuid uuid;
  send_reference text := public.kwanpay_transaction_reference();
  receive_reference text := public.kwanpay_transaction_reference();
begin
  if caller is null or caller <> sender_id then
    raise exception 'Not allowed';
  end if;

  if transfer_amount is null or transfer_amount <= 0 then
    raise exception 'Invalid amount';
  end if;

  select id
  into receiver_uuid
  from public.wallets
  where wallet_id = receiver_wallet_id;

  if receiver_uuid is null then
    raise exception 'Recipient wallet not found';
  end if;

  if receiver_uuid = sender_id then
    raise exception 'Cannot send to yourself';
  end if;

  perform public.adjust_wallet_balance(sender_id, 'USD', -transfer_amount);
  perform public.adjust_wallet_balance(receiver_uuid, 'USD', transfer_amount);

  insert into public.transactions (
    wallet_id,
    type,
    amount,
    currency,
    status,
    description,
    reference,
    provider
  )
  values (
    sender_id,
    'Send',
    transfer_amount,
    'USD',
    'Completed',
    'Transfer Sent',
    send_reference,
    'kwanpay_transfer'
  );

  insert into public.transactions (
    wallet_id,
    type,
    amount,
    currency,
    status,
    description,
    reference,
    provider
  )
  values (
    receiver_uuid,
    'Receive',
    transfer_amount,
    'USD',
    'Completed',
    'Transfer Received',
    receive_reference,
    'kwanpay_transfer'
  );
end;
$$;

revoke all on function public.transfer_funds(uuid, text, numeric) from public;
revoke all on function public.transfer_funds(uuid, text, numeric) from anon;
grant execute on function public.transfer_funds(uuid, text, numeric) to authenticated;
