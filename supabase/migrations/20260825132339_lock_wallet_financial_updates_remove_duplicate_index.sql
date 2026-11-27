-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

begin;

drop index if exists public.transactions_wallet_created_at_idx;

drop policy if exists "Users can update own stellar public key" on public.wallets;
drop policy if exists "Users can update own wallet" on public.wallets;

create policy "Users can update own stellar public key"
on public.wallets
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

commit;
