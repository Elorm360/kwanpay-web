-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

ALTER TABLE public.collection_intents DROP CONSTRAINT IF EXISTS collection_intents_provider_check;
ALTER TABLE public.collection_intents ADD CONSTRAINT collection_intents_provider_check CHECK (provider = ANY (ARRAY['flutterwave'::text, 'moolre'::text, 'fincra'::text]));
