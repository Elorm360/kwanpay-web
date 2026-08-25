import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type JsonRecord = Record<string, unknown>;

function jsonResponse(body: JsonRecord, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function asRecord(value: unknown): JsonRecord | null {
  if (value && typeof value === "object" && !Array.isArray(value)) {
    return value as JsonRecord;
  }
  return null;
}

function flutterwaveNetwork(rail: string) {
  if (rail === "mtn") return "MTN";
  if (rail === "telecel") return "VODAFONE";
  return "TIGO";
}

function localGhanaMsisdn(msisdn: string) {
  if (msisdn.startsWith("233") && msisdn.length === 12) {
    return `0${msisdn.slice(3)}`;
  }
  return msisdn;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const flutterwaveSecret = Deno.env.get("FLW_SECRET_KEY") ?? "";
  if (!flutterwaveSecret) {
    return jsonResponse({ configured: false });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");

  if (!supabaseUrl || !serviceRoleKey || !anonKey) {
    return jsonResponse({ error: "Flutterwave collector is not configured" }, 500);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonResponse({ error: "Not authenticated" }, 401);
  }

  let payload: JsonRecord;
  try {
    payload = asRecord(await req.json()) ?? {};
  } catch (_) {
    return jsonResponse({ error: "Invalid JSON body" }, 400);
  }

  const reference = String(payload.reference ?? "").trim().toUpperCase();
  if (!reference) {
    return jsonResponse({ error: "Missing collection reference" }, 400);
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const {
    data: { user },
    error: userError,
  } = await userClient.auth.getUser();

  if (userError || !user) {
    return jsonResponse({ error: "Not authenticated" }, 401);
  }

  const admin = createClient(supabaseUrl, serviceRoleKey);
  const { data: intent, error: intentError } = await admin
    .from("collection_intents")
    .select("reference, amount, currency, rail, msisdn, provider, status, wallet_id")
    .eq("reference", reference)
    .eq("wallet_id", user.id)
    .maybeSingle();

  if (intentError || !intent) {
    return jsonResponse({ error: "Collection not found" }, 404);
  }

  if (intent.status !== "pending") {
    return jsonResponse({
      configured: true,
      already_initiated: true,
      reference,
    });
  }

  if (intent.provider === "flutterwave") {
    const { data: existingTxn } = await admin
      .from("transactions")
      .select("*")
      .eq("reference", reference)
      .eq("wallet_id", user.id)
      .maybeSingle();

    return jsonResponse({
      configured: true,
      already_initiated: true,
      reference,
      flw_id: existingTxn?.provider_reference ?? null,
      transaction: existingTxn,
    });
  }

  const { data: profile } = await admin
    .from("profiles")
    .select("email, full_name")
    .eq("id", user.id)
    .maybeSingle();

  const email = String(profile?.email ?? user.email ?? "").trim();
  if (!email) {
    return jsonResponse({ error: "Add an email to your profile before funding." }, 400);
  }

  const fullname = String(profile?.full_name ?? "").trim() || "KwanPay traveler";
  const chargeBody = {
    phone_number: localGhanaMsisdn(String(intent.msisdn)),
    amount: Number(intent.amount),
    currency: "GHS",
    country: "GH",
    network: flutterwaveNetwork(String(intent.rail)),
    email,
    fullname,
    tx_ref: String(intent.reference),
  };

  const chargeResponse = await fetch(
    "https://api.flutterwave.com/v3/charges?type=mobile_money_ghana",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${flutterwaveSecret}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(chargeBody),
    },
  );

  const chargePayload = asRecord(await chargeResponse.json()) ?? {};
  if (!chargeResponse.ok || String(chargePayload.status ?? "") !== "success") {
    const message = String(
      chargePayload.message ?? "Flutterwave did not start the Mobile Money charge.",
    );
    return jsonResponse({
      configured: true,
      error: message,
    }, 400);
  }

  const chargeData = asRecord(chargePayload.data) ?? {};
  const meta = asRecord(chargePayload.meta);
  const authorization = asRecord(meta?.authorization);
  const flwId = String(chargeData.id ?? chargeData.flw_ref ?? "").trim();
  const redirectUrl = String(
    authorization?.redirect ?? chargeData.link ?? "",
  ).trim();

  if (!flwId) {
    return jsonResponse({ error: "Flutterwave did not return a charge id" }, 502);
  }

  const { data: transaction, error: attachError } = await admin.rpc(
    "attach_flutterwave_charge",
    {
      p_reference: reference,
      p_flw_id: flwId,
    },
  );

  if (attachError) {
    return jsonResponse({ error: attachError.message }, 400);
  }

  return jsonResponse({
    configured: true,
    redirect_url: redirectUrl || null,
    flw_id: flwId,
    transaction,
  });
});
