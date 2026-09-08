import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

const record = (value: unknown): Record<string, unknown> | null =>
  value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : null;

const amount = (value: unknown) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const apiKey = Deno.env.get("FINCRA_API_SECRET_KEY");

  if (!supabaseUrl || !anonKey || !serviceKey) {
    return json({ error: "Supabase server configuration is incomplete." }, 500);
  }
  if (!apiKey) return json({ error: "Withdrawal service is not configured." }, 503);

  const authorization = req.headers.get("Authorization");
  if (!authorization) return json({ error: "Missing authorization." }, 401);

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  });
  const {
    data: { user },
    error: userError,
  } = await userClient.auth.getUser();
  if (userError || !user) return json({ error: "Not authenticated." }, 401);

  let body: { reference?: unknown };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON request body." }, 400);
  }

  const reference = String(body.reference ?? "").trim().toUpperCase();
  if (!/^KWP-TXN-[A-Z0-9-]{1,80}$/.test(reference)) {
    return json({ error: "Invalid withdrawal reference." }, 400);
  }

  const admin = createClient(supabaseUrl, serviceKey);
  const { data: payout, error: payoutError } = await admin
    .from("payout_intents")
    .select("*")
    .eq("reference", reference)
    .maybeSingle();

  if (payoutError) return json({ error: "Could not load the withdrawal request." }, 500);
  if (!payout || payout.wallet_id !== user.id) return json({ error: "Withdrawal request not found." }, 404);
  if (payout.provider !== "fincra" || payout.currency !== "GHS" || payout.destination_kind !== "momo") {
    return json({ error: "Withdrawal request is not eligible for verification." }, 409);
  }

  if (["Completed", "Failed", "Cancelled"].includes(String(payout.status))) {
    const { data: transaction } = await admin
      .from("transactions")
      .select("*")
      .eq("id", payout.transaction_id)
      .maybeSingle();
    return json({ success: true, status: payout.status, transaction, payout });
  }

  const response = await fetch(
    `https://api.fincra.com/disbursements/payouts/customer-reference/${encodeURIComponent(reference)}`,
    { headers: { accept: "application/json", "api-key": apiKey } },
  );

  let payload: unknown;
  try {
    payload = await response.json();
  } catch {
    return json({
      success: true,
      status: payout.status,
      transaction: null,
      payout,
      message: "The withdrawal is still being checked. Your reserved funds remain protected.",
    }, 202);
  }

  const responsePayload = record(payload);
  if (!response.ok || responsePayload?.success !== true) {
    if (response.status === 404) {
      return json({
        success: true,
        status: payout.status,
        transaction: null,
        payout,
        message: "The withdrawal is still being processed. Your reserved funds remain protected.",
      }, 202);
    }
    if (response.status >= 400 && response.status < 500) {
      return json({ error: "The withdrawal could not be verified. Please try again." }, 422);
    }
    return json({
      success: true,
      status: payout.status,
      transaction: null,
      payout,
      message: "The withdrawal is still being checked. Your reserved funds remain protected.",
    }, 202);
  }

  const verified = record(responsePayload?.data);
  if (!verified) {
    return json({
      success: true,
      status: payout.status,
      transaction: null,
      payout,
      message: "The withdrawal is still being checked. Your reserved funds remain protected.",
    }, 202);
  }

  const providerReference = String(verified.reference ?? "").trim();
  const customerReference = String(verified.customerReference ?? "").trim().toUpperCase();
  const status = String(verified.status ?? "").trim().toLowerCase();
  const verifiedCurrency = String(verified.destinationCurrency ?? verified.currency ?? "").trim().toUpperCase();
  const verifiedAmount = amount(verified.amount);

  if (!providerReference || customerReference !== reference) {
    return json({ error: "Withdrawal verification returned an unexpected reference." }, 502);
  }
  if (verifiedCurrency && verifiedCurrency !== "GHS") {
    return json({ error: "Withdrawal verification returned an unexpected currency." }, 502);
  }
  if (verifiedAmount != null && Math.abs(verifiedAmount - Number(payout.amount)) > 0.005) {
    return json({ error: "Withdrawal verification returned an unexpected amount." }, 502);
  }
  if (!["successful", "processing", "failed"].includes(status)) {
    return json({
      success: true,
      status: payout.status,
      transaction: null,
      payout,
      message: "The withdrawal is still being processed. Your reserved funds remain protected.",
    }, 202);
  }

  const attach = await admin.rpc("attach_ghana_payout_provider_reference", {
    p_reference: reference,
    p_provider_reference: providerReference,
    p_provider_status: status,
  });
  if (attach.error) return json({ error: "Withdrawal verification could not be recorded safely." }, 500);

  const finalStatus = status === "successful"
    ? "Completed"
    : status === "failed"
      ? "Failed"
      : "Processing";

  const settled = await admin.rpc("settle_ghana_payout", {
    p_reference: reference,
    p_status: finalStatus,
    p_provider_reference: providerReference,
    p_provider_status: status,
    p_failure_reason: status === "failed"
      ? String(verified.reason ?? "Withdrawal failed.")
      : null,
  });

  if (settled.error) return json({ error: "Withdrawal verification could not complete settlement." }, 500);

  const { data: transaction } = await admin
    .from("transactions")
    .select("*")
    .eq("id", payout.transaction_id)
    .maybeSingle();

  return json({
    success: true,
    status: finalStatus,
    transaction,
    payout: settled.data ?? attach.data,
  });
});
