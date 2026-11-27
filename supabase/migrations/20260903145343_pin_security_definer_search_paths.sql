-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

alter function public.attach_flutterwave_charge(text,text) set search_path = '';
alter function public.attach_provider_reference(text,text,text) set search_path = '';
alter function public.confirm_stellar_usdc_payment(text,text) set search_path = '';
alter function public.resolve_wallet_recipient(text) set search_path = '';
alter function public.upsert_live_fx_rates(text,timestamptz,jsonb) set search_path = '';
