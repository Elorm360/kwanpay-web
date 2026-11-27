-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

-- Financial history is write-only through security-definer RPCs and Edge Functions.
-- Clients may read their own rows; they must not insert or mutate transactions.

revoke insert, update, delete, truncate on table public.transactions
  from anon, authenticated;

grant select on table public.transactions to authenticated;
revoke all on table public.transactions from anon;

drop policy if exists "Users can insert own transactions" on public.transactions;
drop policy if exists "Users can update own transactions" on public.transactions;
drop policy if exists "Users can delete own transactions" on public.transactions;
