create table if not exists public.tourism_stellar_accounts (
  code text primary key,
  name text not null,
  stellar_public_key text not null,
  created_at timestamptz not null default timezone('utc', now()),
  constraint tourism_stellar_accounts_key_format
    check (stellar_public_key ~ '^G[A-Z2-7]{55}$')
);

create unique index if not exists tourism_stellar_accounts_public_key_idx
  on public.tourism_stellar_accounts (stellar_public_key);

alter table public.tourism_stellar_accounts enable row level security;

grant select on table public.tourism_stellar_accounts to authenticated;
revoke insert, update, delete on table public.tourism_stellar_accounts
from anon, authenticated;

drop policy if exists "Authenticated users can view tourism Stellar accounts"
  on public.tourism_stellar_accounts;
create policy "Authenticated users can view tourism Stellar accounts"
on public.tourism_stellar_accounts
for select
to authenticated
using (true);

insert into public.tourism_stellar_accounts (code, name, stellar_public_key)
values
  ('vip_jeoun', 'VIP Jeoun', 'GDSAMVMKUSSFNM3B4SM7FLASIMCHZD3VH462MUJJGNMZ6G5UWCM36VMH'),
  ('stc', 'STC', 'GC6XRZCJAIOXPXCNWIKZG7OU7UGU76BARQYQFNLOFLD7LUCX6ADBG7DM'),
  ('airport_shuttle', 'Airport Shuttle', 'GBDOC6RS4ZS25OP7EXTZ4XFB5MZ2I4APD54TFZR53CKK3BGWRRPKYH2N'),
  ('savannah_trails', 'Savannah Trails', 'GCIMWSMY7YCQCTVMSQ4VUYVQGXRXDHKMU57KKGTDXL5YRJR4OQFLAMTZ'),
  ('cape_coast_tours', 'Cape Coast Tours', 'GDVBOPN3QGTH4ASDHPOW2WF2D3E55AREL7UCYBFMNNBBPEFD2DUFACX2'),
  ('labadi_beach_hotel', 'Labadi Beach Hotel', 'GCOYWCSJ3KWGNBVHXCXEBNRWV3WTHESN36GB7QFVNYYATITOB5F4MBZL')
on conflict (code) do update
set
  name = excluded.name,
  stellar_public_key = excluded.stellar_public_key;

create or replace function public.initiate_stellar_usdc_payment(
  p_operator_code text,
  p_booking_reference text,
  p_amount numeric,
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
  normalized_reference text := upper(trim(p_reference));
  normalized_booking text := upper(regexp_replace(
    coalesce(p_booking_reference, ''),
    '[^A-Za-z0-9]',
    '',
    'g'
  ));
  merchant public.tourism_stellar_accounts;
  existing_txn public.transactions;
  payment_txn public.transactions;
  sender_key text;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if p_amount is null or p_amount <= 0 then
    raise exception 'Invalid amount';
  end if;

  if normalized_reference = ''
    or normalized_reference not like 'KWP-TXN-%'
    or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  if length(normalized_booking) < 6 or length(normalized_booking) > 24 then
    raise exception 'Enter a valid booking reference';
  end if;

  select stellar_public_key
  into sender_key
  from public.wallets
  where id = caller;

  if sender_key is null or sender_key = '' then
    raise exception 'Prepare the Stellar Testnet wallet first';
  end if;

  select *
  into merchant
  from public.tourism_stellar_accounts
  where code = normalized_code;

  if not found then
    raise exception 'Unknown operator';
  end if;

  select *
  into existing_txn
  from public.transactions
  where reference = normalized_reference;

  if found then
    if existing_txn.wallet_id = caller
      and existing_txn.type = 'Payment'
      and existing_txn.amount = p_amount
      and existing_txn.currency = 'USDC'
      and existing_txn.provider = 'stellar_testnet' then
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
    'USDC',
    'Pending',
    merchant.name || ' · ' || normalized_booking,
    normalized_reference,
    'stellar_testnet',
    merchant.stellar_public_key
  )
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
      and existing_txn.currency = 'USDC'
      and existing_txn.provider = 'stellar_testnet' then
      return existing_txn;
    end if;

    raise exception 'Transaction reference is already in use';
end;
$$;

revoke all on function public.initiate_stellar_usdc_payment(text, text, numeric, text) from public;
revoke all on function public.initiate_stellar_usdc_payment(text, text, numeric, text) from anon;
grant execute on function public.initiate_stellar_usdc_payment(text, text, numeric, text)
to authenticated;

create or replace function public.confirm_stellar_usdc_payment(
  p_reference text,
  p_tx_hash text
)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized_reference text := upper(trim(p_reference));
  normalized_hash text := lower(trim(p_tx_hash));
  txn public.transactions;
begin
  if normalized_reference = '' or normalized_hash = '' then
    raise exception 'Missing Stellar payment';
  end if;

  select *
  into txn
  from public.transactions
  where reference = normalized_reference
  for update;

  if not found then
    raise exception 'Payment not found';
  end if;

  if txn.type <> 'Payment' or txn.provider <> 'stellar_testnet' then
    raise exception 'Not a Stellar USDC payment';
  end if;

  if txn.status = 'Completed' and txn.provider_reference = normalized_hash then
    return txn;
  end if;

  if txn.status <> 'Pending' then
    raise exception 'Payment can no longer be updated';
  end if;

  update public.transactions
  set
    status = 'Completed',
    provider_reference = normalized_hash
  where id = txn.id
  returning * into txn;

  return txn;
end;
$$;

revoke all on function public.confirm_stellar_usdc_payment(text, text) from public;
revoke all on function public.confirm_stellar_usdc_payment(text, text) from anon;
revoke all on function public.confirm_stellar_usdc_payment(text, text) from authenticated;
grant execute on function public.confirm_stellar_usdc_payment(text, text)
to service_role;
