create or replace function public.attach_flutterwave_charge(
  p_reference text,
  p_flw_id text
)
returns public.transactions
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized_reference text := upper(trim(p_reference));
  normalized_flw_id text := trim(p_flw_id);
  intent public.collection_intents;
  txn public.transactions;
  rail_label text;
begin
  if normalized_reference = '' or normalized_flw_id = '' then
    raise exception 'Missing Flutterwave charge';
  end if;

  select *
  into intent
  from public.collection_intents
  where reference = normalized_reference
  for update;

  if not found then
    raise exception 'Collection not found';
  end if;

  select *
  into txn
  from public.transactions
  where id = intent.transaction_id
  for update;

  if not found then
    raise exception 'Transaction not found';
  end if;

  if intent.status <> 'pending' or txn.status <> 'Pending' then
    if txn.provider = 'flutterwave'
      and txn.provider_reference = normalized_flw_id then
      return txn;
    end if;
    raise exception 'Collection can no longer be updated';
  end if;

  if txn.provider = 'flutterwave'
    and txn.provider_reference = normalized_flw_id then
    return txn;
  end if;

  if intent.provider not in ('ghana_collector_test', 'flutterwave') then
    raise exception 'Collection is not a Flutterwave charge';
  end if;

  rail_label := case intent.rail
    when 'mtn' then 'MTN MoMo'
    when 'telecel' then 'Telecel Cash'
    else 'AirtelTigo Money'
  end;

  update public.collection_intents
  set provider = 'flutterwave'
  where id = intent.id;

  update public.transactions
  set
    provider = 'flutterwave',
    provider_reference = normalized_flw_id,
    description = rail_label || ' · Flutterwave'
  where id = txn.id
  returning * into txn;

  return txn;
end;
$$;

revoke all on function public.attach_flutterwave_charge(text, text) from public;
revoke all on function public.attach_flutterwave_charge(text, text) from anon;
revoke all on function public.attach_flutterwave_charge(text, text) from authenticated;
grant execute on function public.attach_flutterwave_charge(text, text)
to service_role;
