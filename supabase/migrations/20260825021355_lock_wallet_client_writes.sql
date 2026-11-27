-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

-- Clients may create a zero-balance wallet and attach a Stellar public key.
-- They must not update wallets.balance, debit/credit ledger rows, or truncate.

revoke all on table public.wallets from anon, authenticated;
grant select, insert on table public.wallets to authenticated;
grant update (stellar_public_key) on table public.wallets to authenticated;

revoke insert, update, delete, truncate on table public.wallet_balances
  from anon, authenticated;
grant select on table public.wallet_balances to authenticated;

drop policy if exists "Users can create own wallet" on public.wallets;
create policy "Users can create own wallet"
on public.wallets
for insert
to authenticated
with check (
  auth.uid() = id
  and balance = 0
  and status = 'Active'
);

drop policy if exists "Users can update own wallet" on public.wallets;
create policy "Users can update own stellar public key"
on public.wallets
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

create or replace function public.prevent_client_wallet_financial_update()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if current_user in ('authenticated', 'anon') then
    if tg_op = 'INSERT' and new.balance <> 0 then
      raise exception 'Wallet balance cannot be set by the client';
    end if;

    if tg_op = 'UPDATE' and (
      new.balance is distinct from old.balance
      or new.currency is distinct from old.currency
      or new.wallet_id is distinct from old.wallet_id
      or new.status is distinct from old.status
      or new.id is distinct from old.id
    ) then
      raise exception 'Wallet financial fields cannot be changed by the client';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists prevent_client_wallet_financial_update on public.wallets;
create trigger prevent_client_wallet_financial_update
before insert or update on public.wallets
for each row
execute function public.prevent_client_wallet_financial_update();

revoke all on function public.prevent_client_wallet_financial_update() from public;
revoke all on function public.prevent_client_wallet_financial_update() from anon;
revoke all on function public.prevent_client_wallet_financial_update() from authenticated;

revoke all on function public.adjust_wallet_balance(uuid, text, numeric) from public;
revoke all on function public.adjust_wallet_balance(uuid, text, numeric) from anon;
revoke all on function public.adjust_wallet_balance(uuid, text, numeric) from authenticated;

revoke all on function public.apply_funding_status(uuid, text) from public;
revoke all on function public.apply_funding_status(uuid, text) from anon;
revoke all on function public.apply_funding_status(uuid, text) from authenticated;
