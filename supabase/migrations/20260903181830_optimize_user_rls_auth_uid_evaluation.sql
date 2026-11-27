-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile" on public.profiles for select to authenticated using ((select auth.uid()) = id);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile" on public.profiles for insert to authenticated with check ((select auth.uid()) = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

drop policy if exists "Users can view own wallet" on public.wallets;
create policy "Users can view own wallet" on public.wallets for select to authenticated using ((select auth.uid()) = id);

drop policy if exists "Users can create own wallet" on public.wallets;
create policy "Users can create own wallet" on public.wallets for insert to authenticated with check ((select auth.uid()) = id);

drop policy if exists "Users can update own stellar public key" on public.wallets;
create policy "Users can update own stellar public key" on public.wallets for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

drop policy if exists "Users can view own transactions" on public.transactions;
create policy "Users can view own transactions" on public.transactions for select to authenticated using ((select auth.uid()) = wallet_id);

drop policy if exists "Users can view own wallet balances" on public.wallet_balances;
create policy "Users can view own wallet balances" on public.wallet_balances for select to authenticated using ((select auth.uid()) = wallet_id);

drop policy if exists "Users can view own collection intents" on public.collection_intents;
create policy "Users can view own collection intents" on public.collection_intents for select to authenticated using ((select auth.uid()) = wallet_id);

drop policy if exists "Users can view own payment methods" on public.payment_methods;
create policy "Users can view own payment methods" on public.payment_methods for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert own payment methods" on public.payment_methods;
create policy "Users can insert own payment methods" on public.payment_methods for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update own payment methods" on public.payment_methods;
create policy "Users can update own payment methods" on public.payment_methods for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete own payment methods" on public.payment_methods;
create policy "Users can delete own payment methods" on public.payment_methods for delete to authenticated using ((select auth.uid()) = user_id);
