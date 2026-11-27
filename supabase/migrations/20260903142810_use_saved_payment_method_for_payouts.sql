-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create or replace function public.create_ghana_payout_from_payment_method(
  p_amount numeric,
  p_reference text,
  p_payment_method_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_user_id uuid := auth.uid();
  v_method public.payment_methods%rowtype;
  v_balance public.wallet_balances%rowtype;
  v_transaction public.transactions%rowtype;
  v_payout public.payout_intents%rowtype;
  v_reference text := upper(trim(p_reference));
  v_snapshot jsonb;
begin
  if v_user_id is null then raise exception 'Not authenticated.'; end if;
  if p_amount is null or p_amount <= 0 then raise exception 'Withdrawal amount must be greater than zero.'; end if;
  if p_amount <> round(p_amount, 2) then raise exception 'Withdrawal amount can have at most two decimal places.'; end if;
  if v_reference !~ '^KWP-TXN-[A-Z0-9-]{1,80}$' then raise exception 'Invalid withdrawal reference.'; end if;

  if exists (select 1 from public.transactions where wallet_id = v_user_id and reference = v_reference) then
    select * into v_transaction from public.transactions where wallet_id = v_user_id and reference = v_reference limit 1;
    select * into v_payout from public.payout_intents where transaction_id = v_transaction.id limit 1;
    return jsonb_build_object('transaction', to_jsonb(v_transaction), 'payout', to_jsonb(v_payout), 'idempotent', true);
  end if;

  select * into v_method from public.payment_methods where id = p_payment_method_id and user_id = v_user_id;
  if not found or v_method.kind <> 'momo' then raise exception 'A Ghana Mobile Money payment method is required for this withdrawal.'; end if;

  insert into public.wallet_balances(wallet_id, currency, available)
  values (v_user_id, 'GHS', 0)
  on conflict (wallet_id, currency) do nothing;

  select * into v_balance from public.wallet_balances where wallet_id = v_user_id and currency = 'GHS' for update;
  if v_balance.available < p_amount then raise exception 'Insufficient GHS balance.'; end if;

  v_snapshot := jsonb_build_object('kind', v_method.kind, 'rail', v_method.rail, 'msisdn', v_method.msisdn, 'country', 'GH');

  update public.wallet_balances set available = available - p_amount, updated_at = timezone('utc', now()) where wallet_id = v_user_id and currency = 'GHS';

  insert into public.transactions(wallet_id, type, amount, currency, description, status, reference, provider)
  values (v_user_id, 'Withdrawal', p_amount, 'GHS', 'GHS withdrawal to saved Mobile Money', 'Pending', v_reference, 'fincra')
  returning * into v_transaction;

  insert into public.payout_intents(wallet_id, transaction_id, withdrawal_method_id, reference, amount, currency, destination_kind, destination_snapshot, status)
  values (v_user_id, v_transaction.id, null, v_reference, p_amount, 'GHS', 'momo', v_snapshot, 'Pending')
  returning * into v_payout;

  return jsonb_build_object('transaction', to_jsonb(v_transaction), 'payout', to_jsonb(v_payout), 'idempotent', false);
end;
$$;

revoke all on function public.create_ghana_payout_from_payment_method(numeric, text, uuid) from public, anon;
grant execute on function public.create_ghana_payout_from_payment_method(numeric, text, uuid) to authenticated;
