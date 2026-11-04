-- Prevent concurrent requests from creating multiple Fiatsend checkout sessions
-- for the same KwanPay funding reference.
--
-- Review-only migration. Do not apply to the live project without separate approval.

alter table public.collection_intents
  add column if not exists checkout_creation_started_at timestamptz;

comment on column public.collection_intents.checkout_creation_started_at is
  'Server-side claim timestamp for the one permitted Fiatsend checkout-session creation attempt. A non-null value blocks a second create request; ambiguous outcomes require reconciliation.';

create or replace function public.claim_fiatsend_checkout(p_reference text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  normalized_reference text := upper(trim(coalesce(p_reference, '')));
  v_tx public.transactions;
  v_intent public.collection_intents;
begin
  if current_setting('request.jwt.claim.role', true) is distinct from 'service_role' then
    raise exception 'Only the service role may claim Fiatsend checkout creation';
  end if;

  if normalized_reference !~ '^KWP-TXN-[A-Z0-9-]{1,80}$' then
    raise exception 'Invalid transaction reference';
  end if;

  select * into v_tx
  from public.transactions
  where reference = normalized_reference
  for update;

  if not found then
    raise exception 'Funding transaction not found';
  end if;

  if v_tx.type is distinct from 'Top Up'
     or v_tx.provider is distinct from 'fiatsend'
     or v_tx.currency is distinct from 'GHS'
     or v_tx.status is distinct from 'Pending' then
    raise exception 'Funding transaction is not eligible for Fiatsend checkout';
  end if;

  select * into v_intent
  from public.collection_intents
  where transaction_id = v_tx.id
    and reference = normalized_reference
  for update;

  if not found
     or v_intent.status is distinct from 'pending'
     or v_intent.provider is distinct from 'fiatsend' then
    raise exception 'Pending Fiatsend collection intent not found';
  end if;

  -- A provider session already attached means there is nothing to create.
  if v_tx.provider_reference is not null or v_intent.provider_event_id is not null then
    return false;
  end if;

  -- The claim is intentionally one-way. A timeout may occur after Fiatsend
  -- accepted the request, so a second POST must not be attempted blindly.
  if v_intent.checkout_creation_started_at is not null then
    return false;
  end if;

  update public.collection_intents
  set checkout_creation_started_at = now()
  where id = v_intent.id;

  return true;
end;
$$;

revoke all on function public.claim_fiatsend_checkout(text)
  from public, anon, authenticated;

grant execute on function public.claim_fiatsend_checkout(text)
  to service_role;

-- Post-apply verification (run manually after a separately approved deployment):
-- select has_function_privilege('service_role',
--   'public.claim_fiatsend_checkout(text)', 'EXECUTE') as service_role_can_execute,
--   has_function_privilege('authenticated',
--   'public.claim_fiatsend_checkout(text)', 'EXECUTE') as authenticated_can_execute;
