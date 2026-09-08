create or replace function public.set_stellar_public_key(p_public_key text)
returns public.wallets
language plpgsql
security definer
set search_path to ''
as $$
declare
  caller uuid := auth.uid();
  normalized_key text := upper(trim(coalesce(p_public_key, '')));
  updated_wallet public.wallets;
begin
  if caller is null then
    raise exception 'Not authenticated';
  end if;

  if normalized_key !~ '^G[A-Z2-7]{55}$' then
    raise exception 'Invalid Stellar public key';
  end if;

  update public.wallets
  set stellar_public_key = normalized_key,
      updated_at = timezone('utc', now())
  where id = caller
  returning * into updated_wallet;

  if not found then
    raise exception 'Wallet not found';
  end if;

  return updated_wallet;
end;
$$;

revoke update on public.wallets from authenticated;
revoke update on public.wallets from anon;
revoke execute on function public.set_stellar_public_key(text) from public;
revoke execute on function public.set_stellar_public_key(text) from anon;
grant execute on function public.set_stellar_public_key(text) to authenticated;
