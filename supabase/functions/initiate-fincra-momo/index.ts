import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const FINCRA_URL = "https://api.fincra.com/checkout/charges";

const OPERATORS: Record<string, string> = {
  mtn: "MTN",
  telecel: "VODAFONE",
  airteltigo: "AIRTEL_TIGO",
};

type Body = {
  amount?: number;
  reference?: string;
  rail?: string;
  msisdn?: string;
};

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : null;
}

function phone(value: unknown) {
  let payer = String(value ?? "").replace(/\D/g, "");
  if (payer.startsWith("233") && payer.length === 12) {
    payer = `0${payer.slice(3)}`;
  }
  return payer;
}

function fincraUserMessage(status: number, payload: unknown): string {
  const record = asRecord(payload);
  const raw = String(record?.message ?? record?.error ?? "").trim();
  const unauthorized =
    status === 401 ||
    status === 403 ||
    /^unauthorized$/i.test(raw) ||
    /invalid authentication credentials/i.test(raw) ||
    /no api key/i.test(raw);

  if (unauthorized) {
    return "The payment service is not authorized. Fincra merchant credentials on the server need checking (secret key, business ID, and live vs sandbox).";
  }

  if (raw) return raw;
  return "Fincra could not start the Mobile Money payment.";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed." }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const apiKey = Deno.env.get("FINCRA_API_SECRET_KEY");
  const businessId = Deno.env.get("FINCRA_BUSINESS_ID");

  if (!supabaseUrl || !anonKey || !serviceKey) {
    return json({ error: "Supabase server configuration is incomplete." }, 500);
  }
  if (!apiKey || !businessId) {
    return json({ error: "Fincra production credentials are not configured." }, 503);
  }

  const authorization = req.headers.get("Authorization");
  if (!authorization) return json({ error: "Missing authorization." }, 401);

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  });
  const { data: { user }, error: userError } = await userClient.auth.getUser();
  if (userError || !user) return json({ error: "Not authenticated." }, 401);

  let body: Body;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON request body." }, 400);
  }

  const amount = Number(body.amount);
  const reference = String(body.reference ?? "").trim().toUpperCase();
  const rail = String(body.rail ?? "").trim().toLowerCase();
  const payer = phone(body.msisdn);
  const operator = OPERATORS[rail];

  if (!Number.isFinite(amount) || amount <= 0 || Math.round(amount * 100) !== amount * 100) {
    return json({ error: "Enter a valid amount with at most two decimal places." }, 400);
  }
  if (!reference.startsWith("KWP-TXN-") || reference.length > 96) {
    return json({ error: "Invalid KwanPay transaction reference." }, 400);
  }
  if (!operator) {
    return json({ error: "Unsupported Ghana Mobile Money network." }, 400);
  }
  if (!/^0\d{9}$/.test(payer)) {
    return json({ error: "Enter a valid Ghana Mobile Money number." }, 400);
  }

  const admin = createClient(supabaseUrl, serviceKey);
  const { data: existing } = await admin
    .from("transactions")
    .select("*")
    .eq("reference", reference)
    .eq("wallet_id", user.id)
    .maybeSingle();

  if (existing && existing.status !== "Pending") {
    return json({
      error: "This funding reference is no longer pending.",
      transaction: existing,
    }, 409);
  }
  if (existing?.provider === "fincra" && existing?.provider_reference) {
    return json({
      success: true,
      already_initiated: true,
      status: existing.status,
      transaction: existing,
      provider_reference: existing.provider_reference,
    });
  }
  if (
    existing &&
    existing.provider &&
    existing.provider !== "fincra" &&
    existing.provider_reference
  ) {
    return json({ error: "This reference belongs to another payment provider." }, 409);
  }

  const { data: transactionData, error: rpcError } = await userClient.rpc(
    "initiate_ghana_collection",
    {
      p_amount: amount,
      p_reference: reference,
      p_rail: rail,
      p_msisdn: payer,
    },
  );
  if (rpcError) {
    return json({
      error: rpcError.message || "Could not create the KwanPay funding transaction.",
    }, 400);
  }

  const created = Array.isArray(transactionData) ? transactionData[0] : transactionData;
  if (!created) {
    return json({ error: "KwanPay did not return the funding transaction." }, 500);
  }

  const { data: assigned, error: assignError } = await admin.rpc(
    "assign_pending_collection_provider",
    {
      p_reference: reference,
      p_provider: "fincra",
    },
  );
  if (assignError || !assigned) {
    await admin.rpc("settle_moolre_transaction", {
      p_reference: reference,
      p_status: "Failed",
      p_provider_reference: null,
    });
    return json({
      error: "Could not switch this payment to Fincra. Start a new Add Funds request.",
    }, 500);
  }

  const transaction = Array.isArray(assigned) ? assigned[0] : assigned;

  const { data: profile } = await admin
    .from("profiles")
    .select("full_name, email")
    .eq("id", user.id)
    .maybeSingle();

  const customerName = String(profile?.full_name ?? "KwanPay traveler").trim() ||
    "KwanPay traveler";
  const customerEmail = String(profile?.email ?? user.email ?? "").trim();
  if (!customerEmail) {
    await admin.rpc("fail_pending_collection", { p_reference: reference });
    return json({ error: "Add an email to your KwanPay profile before funding." }, 400);
  }

  const webhookUrl = `${supabaseUrl}/functions/v1/fincra-payment-webhook`;
  const providerResponse = await fetch(FINCRA_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "accept": "application/json",
      "api-key": apiKey,
      "x-business-id": businessId,
    },
    body: JSON.stringify({
      type: "mobile_money",
      amount,
      reference,
      currency: "GHS",
      phone: payer,
      operator,
      customer: { name: customerName, email: customerEmail, phoneNumber: payer },
      settlementDestination: "wallet",
      webhookUrl,
    }),
  });

  let payload: unknown;
  try {
    payload = await providerResponse.json();
  } catch {
    await admin.rpc("fail_pending_collection", { p_reference: reference });
    return json({ error: "Fincra returned an invalid response." }, 502);
  }

  const data = asRecord(asRecord(payload)?.data);
  if (!providerResponse.ok || asRecord(payload)?.status !== true || !data) {
    console.error("Fincra charge failed", providerResponse.status);
    const { data: failed } = await admin.rpc("fail_pending_collection", {
      p_reference: reference,
    });
    return json({
      error: fincraUserMessage(providerResponse.status, payload),
      transaction: Array.isArray(failed) ? failed[0] : failed ?? transaction,
    }, 400);
  }

  const chargeId = String(data.id ?? "").trim();
  if (!chargeId) {
    await admin.rpc("fail_pending_collection", { p_reference: reference });
    return json({ error: "Fincra did not return a charge ID." }, 502);
  }

  const { data: attached, error: attachError } = await admin.rpc(
    "attach_provider_reference",
    {
      p_reference: reference,
      p_provider: "fincra",
      p_provider_reference: chargeId,
    },
  );
  if (attachError) {
    return json({
      error: "Fincra charge was created, but KwanPay could not attach the provider reference.",
    }, 500);
  }

  return json({
    success: true,
    status: "Pending",
    provider: "fincra",
    provider_reference: chargeId,
    auth_model: data.auth_model ?? null,
    verification_required: String(data.auth_model ?? "").toUpperCase() === "OTP",
    message: String(
      data.message ??
        "A Mobile Money prompt has been sent to your phone. Approve it with your Mobile Money PIN.",
    ),
    transaction: Array.isArray(attached) ? attached[0] : attached,
  });
});
