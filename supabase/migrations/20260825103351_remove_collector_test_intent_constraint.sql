-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

-- Live funding RPCs already use Flutterwave. This only removes the leftover
-- collection_intents check that still allowed ghana_collector_test.

alter table public.collection_intents
  drop constraint if exists collection_intents_provider_check;

alter table public.collection_intents
  add constraint collection_intents_provider_check
  check (provider in ('flutterwave', 'hubtel'));
