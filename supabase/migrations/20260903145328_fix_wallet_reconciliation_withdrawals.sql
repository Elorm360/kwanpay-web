-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

create or replace function public.reconcile_wallet()
returns table(currency text, ledger_available numeric, expected_available numeric, pending_amount numeric, matched boolean)
language plpgsql
security invoker
set search_path = ''
as $$
declare caller uuid := auth.uid();
begin
  if caller is null then raise exception 'Not authenticated'; end if;
  return query
  with movements as (
    select upper(t.currency) as currency,
      coalesce(sum(t.amount) filter (where t.status='Completed' and t.type in ('Top Up','Receive','Convert In')),0) as credits,
      coalesce(sum(t.amount) filter (where t.status='Completed' and t.type in ('Send','Payment','Convert Out','Withdrawal')),0) as debits,
      coalesce(sum(t.amount) filter (where t.status='Pending' and t.type in ('Top Up','Send','Payment','Withdrawal')),0) as pending
    from public.transactions t where t.wallet_id = caller group by 1
  ),
  ledger as (
    select upper(b.currency) as currency, b.available from public.wallet_balances b where b.wallet_id = caller
  ),
  usd_wallet as (
    select round(coalesce(w.balance,0),2) as balance from public.wallets w where w.id = caller
  ),
  currencies as (
    select m.currency from movements m union select l.currency from ledger l
  )
  select c.currency,
    coalesce(l.available,0),
    coalesce(m.credits,0)-coalesce(m.debits,0)-coalesce(m.pending,0),
    coalesce(m.pending,0),
    (round(coalesce(l.available,0),2)=round(coalesce(m.credits,0)-coalesce(m.debits,0)-coalesce(m.pending,0),2)
      and (c.currency <> 'USD' or round(coalesce(l.available,0),2)=coalesce((select uw.balance from usd_wallet uw),0)))
  from currencies c left join movements m on m.currency=c.currency left join ledger l on l.currency=c.currency order by c.currency;
end;
$$;
