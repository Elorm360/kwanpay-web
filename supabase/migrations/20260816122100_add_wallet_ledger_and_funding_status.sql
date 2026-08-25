create table if not exists public.wallet_balances (
  wallet_id uuid not null references public.wallets(id) on delete cascade,
  currency text not null,
  available numeric not null default 0,
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (wallet_id, currency),
  constraint wallet_balances_available_nonnegative check (available >= 0)
);

alter table public.wallet_balances enable row level security;

grant select on table public.wallet_balances to authenticated;
revoke insert, update, delete on table public.wallet_balances from anon, authenticated;

drop policy if exists "Users can view own wallet balances" on public.wallet_balances;
create policy "Users can view own wallet balances"
on public.wallet_balances
for select
using (wallet_id = auth.uid());

drop policy if exists "Users can update own transactions" on public.transactions;

create or replace function public.adjust_wallet_balance(
  p_wallet_id uuid,
  p_currency text,
  p_delta numeric
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  new_available numeric;
  seed_amount numeric := 0;
begin
  if p_delta = 0 then
    return;
  end if;

  if p_currency = 'USD' then
    select coalesce(balance, 0)
    into seed_amount
    from public.wallets
    where id = p_wallet_id;
  end if;

  insert into public.wallet_balances (
    wallet_id,
    currency,
    available
  )
  values (
    p_wallet_id,
    p_currency,
    seed_amount
  )
  on conflict (wallet_id, currency) do nothing;

  update public.wallet_balances
  set
    available = available + p_delta,
    updated_at = timezone('utc', now())
  where wallet_id = p_wallet_id
    and currency = p_currency
    and available + p_delta >= 0
  returning available into new_available;

  if new_available is null then
    raise exception 'Insufficient balance';
  end if;

  if p_currency = 'USD' then
    update public.wallets
    set
      balance = new_available,
      updated_at = timezone('utc', now())
    where id = p_wallet_id;
  end if;
end;
$$;

revoke all on function public.adjust_wallet_balance(uuid, text, numeric) from public;
revoke all on function public.adjust_wallet_balance(uuid, text, numeric) from anon;
revoke all on function public.adjust_wallet_balance(uuid, text, numeric) from authenticated;

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

  if txn.provider is distinct from 'kwanpay_test' then
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
    description
  )
  values (
    sender_id,
    'Send',
    transfer_amount,
    'USD',
    'Completed',
    'Transfer Sent'
  );

  insert into public.transactions (
    wallet_id,
    type,
    amount,
    currency,
    status,
    description
  )
  values (
    receiver_uuid,
    'Receive',
    transfer_amount,
    'USD',
    'Completed',
    'Transfer Received'
  );
end;
$$;

revoke all on function public.transfer_funds(uuid, text, numeric) from public;
revoke all on function public.transfer_funds(uuid, text, numeric) from anon;
grant execute on function public.transfer_funds(uuid, text, numeric) to authenticated;
