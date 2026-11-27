-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

-- Internal ledger engine: only other postgres-owned security-definer RPCs
-- may call this. Clients and service_role must not invoke it directly.

revoke all on function public.adjust_wallet_balance(uuid, text, numeric) from public;
revoke all on function public.adjust_wallet_balance(uuid, text, numeric) from anon;
revoke all on function public.adjust_wallet_balance(uuid, text, numeric) from authenticated;
revoke all on function public.adjust_wallet_balance(uuid, text, numeric) from service_role;

comment on function public.adjust_wallet_balance(uuid, text, numeric) is
  'Internal wallet ledger engine. Invoked only by financial RPCs in the same database transaction.';
