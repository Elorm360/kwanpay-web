create index if not exists transactions_wallet_id_created_at_idx
on public.transactions (wallet_id, created_at desc);

create or replace function public.reconcile_wallet()
returns table (
  currency text,
  ledger_available numeric,
  expected_available numeric,
  pending_amount numeric,
  matched boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  return query
  with movements as (
    select
      upper(t.currency) as currency,
      coalesce(sum(t.amount) filter (
        where t.status = 'Completed'
          and t.type in ('Top Up', 'Receive')
      ), 0) as credits,
      coalesce(sum(t.amount) filter (
        where t.status = 'Completed'
          and t.type in ('Send', 'Payment')
      ), 0) as debits,
      coalesce(sum(t.amount) filter (
        where t.status = 'Pending'
          and t.type in ('Top Up', 'Send', 'Payment')
      ), 0) as pending
    from public.transactions t
    where t.wallet_id = caller
    group by 1
  ),
  ledger as (
    select
      upper(b.currency) as currency,
      b.available
    from public.wallet_balances b
    where b.wallet_id = caller
  ),
  usd_wallet as (
    select round(coalesce(w.balance, 0), 2) as balance
    from public.wallets w
    where w.id = caller
  ),
  currencies as (
    select m.currency from movements m
    union
    select l.currency from ledger l
  )
  select
    c.currency,
    coalesce(l.available, 0) as ledger_available,
    coalesce(m.credits, 0) - coalesce(m.debits, 0) as expected_available,
    coalesce(m.pending, 0) as pending_amount,
    (
      round(coalesce(l.available, 0), 2)
        = round(coalesce(m.credits, 0) - coalesce(m.debits, 0), 2)
      and (
        c.currency <> 'USD'
        or round(coalesce(l.available, 0), 2)
          = coalesce((select uw.balance from usd_wallet uw), 0)
      )
    ) as matched
  from currencies c
  left join movements m on m.currency = c.currency
  left join ledger l on l.currency = c.currency
  order by c.currency;
end;
$$;

revoke all on function public.reconcile_wallet() from public;
revoke all on function public.reconcile_wallet() from anon;
grant execute on function public.reconcile_wallet() to authenticated;
