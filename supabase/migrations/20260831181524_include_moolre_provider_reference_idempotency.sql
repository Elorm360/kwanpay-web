-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

drop index if exists public.transactions_external_provider_reference_unique_idx;

create unique index transactions_external_provider_reference_unique_idx
on public.transactions using btree (provider, provider_reference)
where (
  provider = any (
    array[
      'flutterwave'::text,
      'moolre'::text,
      'stellar'::text,
      'stellar_testnet'::text,
      'ghana_collector'::text
    ]
  )
  and provider_reference is not null
  and btrim(provider_reference) <> ''::text
);
