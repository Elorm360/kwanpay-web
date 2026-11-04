-- Allow trusted server-side Edge Functions to settle provider collections.
-- The function remains SECURITY DEFINER and is not exposed to client roles.
-- Verified against the live function signature and current ACL on 2026-11-04.
--
-- This migration is prepared for review only. It has NOT been applied to Supabase.

do $$
begin
  if to_regprocedure('public.settle_provider_transaction(text,text,text)') is null then
    raise exception 'Expected public.settle_provider_transaction(text,text,text) to exist';
  end if;
end;
$$;

revoke all on function public.settle_provider_transaction(text, text, text)
  from public, anon, authenticated;

grant execute on function public.settle_provider_transaction(text, text, text)
  to service_role;

-- Post-apply verification (run manually after a separately approved deployment):
-- select
--   has_function_privilege('service_role',
--     'public.settle_provider_transaction(text,text,text)', 'EXECUTE')
--       as service_role_can_execute,
--   has_function_privilege('anon',
--     'public.settle_provider_transaction(text,text,text)', 'EXECUTE')
--       as anon_can_execute,
--   has_function_privilege('authenticated',
--     'public.settle_provider_transaction(text,text,text)', 'EXECUTE')
--       as authenticated_can_execute;
