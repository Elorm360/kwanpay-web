-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

do $$
declare
  r record;
begin
  for r in
    select conname
    from pg_constraint
    where conrelid = 'public.collection_intents'::regclass
      and contype = 'c'
      and pg_get_constraintdef(oid) like '%provider%'
      and pg_get_constraintdef(oid) like '%flutterwave%'
  loop
    execute format(
      'alter table public.collection_intents drop constraint %I',
      r.conname
    );
  end loop;
end
$$;

alter table public.collection_intents
  add constraint collection_intents_provider_check
  check (provider = any (array['flutterwave'::text, 'moolre'::text]));
