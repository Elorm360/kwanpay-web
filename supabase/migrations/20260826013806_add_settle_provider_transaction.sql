-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create or replace function public.settle_provider_transaction(
  p_reference text,
  p_status text,
  p_provider_reference text default null
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $function$
declare
  normalized_reference text := upper(trim(coalesce(p_reference, '')));
  normalized_status text := initcap(lower(trim(coalesce(p_status, ''))));

  existing_txn public.transactions;
  updated_txn public.transactions;
begin
  if normalized_reference = ''
     or normalized_reference not like 'KWP-TXN-%'
     or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  if normalized_status not in ('Completed', 'Failed', 'Cancelled') then
    raise exception 'Invalid settlement status';
  end if;

  select *
  into existing_txn
  from public.transactions
  where reference = normalized_reference
  for update;

  if not found then
    raise exception 'Transaction not found';
  end if;

  if existing_txn.provider is null then
    raise exception 'Transaction has no provider';
  end if;

  if existing_txn.status = normalized_status then
    if p_provider_reference is not null
       and (
         existing_txn.provider_reference is null
         or existing_txn.provider_reference <> p_provider_reference
       ) then
      update public.transactions
      set provider_reference = p_provider_reference
      where id = existing_txn.id
      returning * into updated_txn;
      return updated_txn;
    end if;
    return existing_txn;
  end if;

  if existing_txn.status in ('Completed', 'Failed', 'Cancelled') then
    raise exception 'Transaction is already finalized';
  end if;

  if existing_txn.status <> 'Pending' then
    raise exception 'Transaction is not pending';
  end if;

  if normalized_status in ('Failed', 'Cancelled') then
    update public.transactions
    set
      status = normalized_status,
      provider_reference =
        coalesce(p_provider_reference, provider_reference)
    where id = existing_txn.id
    returning * into updated_txn;
    return updated_txn;
  end if;

  if normalized_status = 'Completed' then
    if existing_txn.type <> 'Top Up' then
      raise exception 'Provider settlement is not supported for this transaction type';
    end if;

    if existing_txn.provider <> 'flutterwave' then
      raise exception 'Unsupported settlement provider';
    end if;

    if existing_txn.currency <> 'GHS' then
      raise exception 'Unsupported funding currency';
    end if;

    perform public.adjust_wallet_balance(
      existing_txn.wallet_id,
      existing_txn.currency,
      existing_txn.amount
    );

    update public.transactions
    set
      status = 'Completed',
      provider_reference =
        coalesce(p_provider_reference, provider_reference)
    where id = existing_txn.id
    returning * into updated_txn;

    update public.collection_intents
    set
      status = 'settled',
      provider_event_id =
        coalesce(p_provider_reference, provider_event_id),
      settled_at = timezone('utc', now())
    where transaction_id = existing_txn.id;

    return updated_txn;
  end if;

  raise exception 'Unable to settle transaction';
end;
$function$;

revoke execute on function public.settle_provider_transaction(text, text, text) from public;
revoke execute on function public.settle_provider_transaction(text, text, text) from anon;
revoke execute on function public.settle_provider_transaction(text, text, text) from authenticated;
revoke execute on function public.settle_provider_transaction(text, text, text) from service_role;
