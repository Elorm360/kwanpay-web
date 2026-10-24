-- Allow Fiatsend (sandbox first) as a Ghana collection + payout provider.
-- Based on the live schema inspected 2026-10-24. Additive only: no rows,
-- columns or existing providers are removed.

-- 1. Table check constraints
alter table public.collection_intents drop constraint collection_intents_provider_check;
alter table public.collection_intents add constraint collection_intents_provider_check
  check (provider = any (array['flutterwave', 'moolre', 'fincra', 'fiatsend']));

alter table public.payout_intents drop constraint payout_intents_provider_check;
alter table public.payout_intents add constraint payout_intents_provider_check
  check (provider = any (array['fincra', 'fiatsend']));

-- 2. Add 'fiatsend' to provider allowlists in existing functions, editing the
--    live definitions in place so nothing else in them changes.
do $$
declare
  def text;
  new_def text;
begin
  def := pg_get_functiondef('public.attach_provider_reference(text, text, text)'::regprocedure);
  new_def := replace(def, $q$('moolre','fincra','flutterwave')$q$, $q$('moolre','fincra','flutterwave','fiatsend')$q$);
  if new_def = def then raise exception 'attach_provider_reference: allowlist not found'; end if;
  execute new_def;

  def := pg_get_functiondef('public.settle_provider_transaction(text, text, text)'::regprocedure);
  new_def := replace(def, $q$'flutterwave',$q$, $q$'flutterwave', 'fiatsend',$q$);
  if new_def = def then raise exception 'settle_provider_transaction: allowlist not found'; end if;
  execute new_def;
end;
$$;

-- 3. Collections: allow switching a pending top-up onto Fiatsend.
create or replace function public.assign_pending_collection_provider(
  p_reference text,
  p_provider text
)
returns public.transactions
language plpgsql
security definer
set search_path = ''
as $$
declare
  txn public.transactions;
  normalized_reference text := upper(trim(coalesce(p_reference, '')));
  normalized_provider text := lower(trim(coalesce(p_provider, '')));
  label text;
begin
  if normalized_reference = ''
     or normalized_reference not like 'KWP-TXN-%'
     or length(normalized_reference) > 96 then
    raise exception 'Invalid transaction reference';
  end if;

  if normalized_provider not in ('moolre', 'fincra', 'flutterwave', 'fiatsend') then
    raise exception 'Unsupported provider';
  end if;

  select * into txn from public.transactions
  where reference = normalized_reference
  for update;

  if not found then raise exception 'Transaction not found'; end if;
  if txn.status <> 'Pending' then raise exception 'Transaction is not pending'; end if;

  if txn.provider_reference is not null
     and txn.provider is not null
     and txn.provider <> normalized_provider then
    raise exception 'This reference belongs to another payment provider';
  end if;

  label := case normalized_provider
    when 'fincra' then 'Fincra'
    when 'flutterwave' then 'Flutterwave'
    when 'fiatsend' then 'Fiatsend'
    else 'Moolre'
  end;

  update public.transactions
  set
    provider = normalized_provider,
    description = regexp_replace(
      coalesce(description, ''),
      ' · (Moolre|Fincra|Flutterwave|Fiatsend)$',
      ' · ' || label
    )
  where id = txn.id
  returning * into txn;

  update public.collection_intents
  set provider = normalized_provider
  where transaction_id = txn.id
    and reference = txn.reference
    and status = 'pending';

  return txn;
end;
$$;

revoke all on function public.assign_pending_collection_provider(text, text) from public, anon, authenticated;
grant execute on function public.assign_pending_collection_provider(text, text) to service_role;

-- 4. Payouts: create_ghana_payout_from_payment_method hard-codes 'fincra'.
--    Rather than change its signature (the app still calls it), the server
--    re-assigns a fresh pending payout to Fiatsend before contacting Fiatsend.
create or replace function public.assign_pending_payout_provider(
  p_reference text,
  p_provider text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  normalized_reference text := upper(trim(coalesce(p_reference, '')));
  normalized_provider text := lower(trim(coalesce(p_provider, '')));
  v_payout public.payout_intents;
  v_txn public.transactions;
begin
  if normalized_reference !~ '^KWP-TXN-[A-Z0-9-]{1,80}$' then
    raise exception 'Invalid withdrawal reference';
  end if;
  if normalized_provider not in ('fincra', 'fiatsend') then
    raise exception 'Unsupported payout provider';
  end if;

  select * into v_payout from public.payout_intents
  where reference = normalized_reference
  for update;
  if not found then raise exception 'Withdrawal not found'; end if;

  if v_payout.provider = normalized_provider then
    select * into v_txn from public.transactions where id = v_payout.transaction_id;
    return jsonb_build_object('transaction', to_jsonb(v_txn), 'payout', to_jsonb(v_payout));
  end if;

  if v_payout.status <> 'Pending' or v_payout.provider_reference is not null then
    raise exception 'Withdrawal can no longer change provider';
  end if;

  update public.payout_intents set provider = normalized_provider
  where id = v_payout.id
  returning * into v_payout;

  update public.transactions set provider = normalized_provider
  where id = v_payout.transaction_id and status = 'Pending'
  returning * into v_txn;

  return jsonb_build_object('transaction', to_jsonb(v_txn), 'payout', to_jsonb(v_payout));
end;
$$;

revoke all on function public.assign_pending_payout_provider(text, text) from public, anon, authenticated;
grant execute on function public.assign_pending_payout_provider(text, text) to service_role;
