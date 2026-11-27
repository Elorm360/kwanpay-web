-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create unique index if not exists transactions_reference_unique_idx
  on public.transactions (reference);

create unique index if not exists transactions_external_provider_reference_unique_idx
  on public.transactions (provider, provider_reference)
  where provider in ('flutterwave', 'stellar', 'stellar_testnet', 'ghana_collector')
    and provider_reference is not null
    and btrim(provider_reference) <> '';

create or replace function public.enforce_transaction_status_transition()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.status is null or new.status not in ('Pending', 'Completed', 'Failed', 'Cancelled') then
    raise exception 'Invalid transaction status';
  end if;

  if old.status = 'Pending' then
    if new.status not in ('Pending', 'Completed', 'Failed', 'Cancelled') then
      raise exception 'Invalid transaction status transition';
    end if;
    return new;
  end if;

  if new.status <> old.status then
    raise exception 'Terminal transaction status cannot be changed';
  end if;

  return new;
end;
$$;

revoke execute on function public.enforce_transaction_status_transition() from public, anon, authenticated, service_role;

 drop trigger if exists transactions_status_transition_guard on public.transactions;

create trigger transactions_status_transition_guard
before update of status on public.transactions
for each row
execute function public.enforce_transaction_status_transition();
