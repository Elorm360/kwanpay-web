-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

drop index if exists public.transactions_external_provider_reference_unique_idx;
create unique index transactions_external_provider_reference_unique_idx
on public.transactions using btree (provider, provider_reference)
where provider in ('flutterwave','moolre','fincra','stellar','stellar_testnet','ghana_collector')
  and provider_reference is not null
  and btrim(provider_reference) <> '';

create or replace function public.settle_ghana_payout(
  p_reference text,
  p_status text,
  p_provider_reference text default null,
  p_provider_status text default null,
  p_failure_reason text default null
)
returns public.payout_intents
language plpgsql
security definer
set search_path = 'pg_catalog, public'
as $$
declare
  v_payout public.payout_intents%rowtype;
  v_final_status text := initcap(lower(trim(p_status)));
  v_transaction_status text;
begin
  if v_final_status not in ('Completed','Failed','Cancelled','Processing','Pending') then
    raise exception 'Invalid payout status.';
  end if;

  select * into v_payout
  from public.payout_intents
  where reference = upper(trim(p_reference))
  for update;

  if not found then
    raise exception 'Payout intent not found.';
  end if;

  if p_provider_reference is not null and length(trim(p_provider_reference)) > 0 then
    if v_payout.provider_reference is not null
       and v_payout.provider_reference <> trim(p_provider_reference) then
      raise exception 'Provider reference mismatch.';
    end if;
    v_payout.provider_reference := trim(p_provider_reference);
  end if;

  if v_payout.status in ('Completed','Failed','Cancelled') then
    return v_payout;
  end if;

  if v_final_status in ('Failed','Cancelled') then
    update public.wallet_balances
    set available = available + v_payout.amount,
        updated_at = timezone('utc', now())
    where wallet_id = v_payout.wallet_id
      and currency = 'GHS';
  end if;

  update public.payout_intents
  set status = v_final_status,
      provider_reference = v_payout.provider_reference,
      provider_status = nullif(trim(coalesce(p_provider_status,'')), ''),
      failure_reason = case
        when v_final_status in ('Failed','Cancelled')
          then nullif(trim(coalesce(p_failure_reason,'')), '')
        else null
      end,
      completed_at = case
        when v_final_status in ('Failed','Cancelled')
          then timezone('utc', now())
        else completed_at
      end,
      updated_at = timezone('utc', now())
  where id = v_payout.id
  returning * into v_payout;

  v_transaction_status := case
    when v_final_status = 'Processing' then 'Pending'
    else v_final_status
  end;

  update public.transactions
  set status = v_transaction_status,
      provider_reference = v_payout.provider_reference
  where id = v_payout.transaction_id;

  return v_payout;
end;
$$;

revoke all on table public.profiles from anon;
revoke all on table public.withdrawal_methods from anon;
revoke all on table public.tourism_stellar_accounts from anon;
