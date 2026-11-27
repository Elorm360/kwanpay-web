-- Exported from live schema_migrations (kwanpay - db) on 2026-11-25.

CREATE OR REPLACE FUNCTION public.attach_provider_reference(
  p_reference text,
  p_provider text,
  p_provider_reference text
)
RETURNS public.transactions
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tx public.transactions;
BEGIN
  IF current_setting('request.jwt.claim.role', true) <> 'service_role' THEN
    RAISE EXCEPTION 'Only the service role may attach provider references';
  END IF;

  IF p_provider NOT IN ('moolre','fincra','flutterwave') THEN
    RAISE EXCEPTION 'Unsupported provider';
  END IF;

  IF nullif(trim(p_reference), '') IS NULL OR nullif(trim(p_provider_reference), '') IS NULL THEN
    RAISE EXCEPTION 'Reference and provider reference are required';
  END IF;

  UPDATE public.transactions
  SET provider = p_provider,
      provider_reference = trim(p_provider_reference)
  WHERE reference = upper(trim(p_reference))
    AND status = 'Pending'
    AND provider IS NOT NULL
    AND provider = p_provider
  RETURNING * INTO v_tx;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Pending provider transaction not found';
  END IF;

  UPDATE public.collection_intents
  SET provider = p_provider,
      provider_event_id = trim(p_provider_reference)
  WHERE transaction_id = v_tx.id
    AND reference = v_tx.reference
    AND status = 'pending';

  RETURN v_tx;
END;
$$;
REVOKE ALL ON FUNCTION public.attach_provider_reference(text,text,text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.attach_provider_reference(text,text,text) TO service_role;
