import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-kwanpay-collector-secret, verif-hash, flutterwave-signature",
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

function hashesEqual(left: string, right: string) {
  if (left.length !== right.length) {
    return false;
  }

  let mismatch = 0;
  for (let i = 0; i < left.length; i += 1) {
    mismatch |= left.charCodeAt(i) ^ right.charCodeAt(i);
  }
  return mismatch === 0;
}

function asRecord(value: unknown): JsonRecord | null {
  if (value && typeof value === "object" && !Array.isArray(value)) {
    return value as JsonRecord;
  }
  return null;
}

function amountsMatch(left: number, right: number) {
  return Math.round(left * 100) === Math.round(right * 100);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const collectorSecret = Deno.env.get("KWANPAY_COLLECTOR_SECRET");
  const flutterwaveHash = Deno.env.get("FLW_SECRET_HASH") ?? "";
  const flutterwaveSecret = Deno.env.get("FLW_SECRET_KEY") ?? "";

  if (!supabaseUrl || !serviceRoleKey || !anonKey) {
    return jsonResponse({ error: "Collector is not configured" }, 500);
  }

  let payload: JsonRecord;
  try {
    payload = asRecord(await req.json()) ?? {};
  } catch (_) {
    return jsonResponse({ error: "Invalid JSON body" }, 400);
  }

  const admin = createClient(supabaseUrl, serviceRoleKey);
  const verifHash = req.headers.get("verif-hash") ?? "";

  if (verifHash.length > 0) {
    if (!flutterwaveHash || !hashesEqual(verifHash, flutterwaveHash)) {
      return jsonResponse({ error: "Invalid Flutterwave signature" }, 401);
    }

    if (!flutterwaveSecret) {
      return jsonResponse({ error: "Flutterwave is not configured" }, 500);
    }

    const event = String(payload.event ?? payload.type ?? "");
    const data = asRecord(payload.data) ?? {};
    const flwId = String(data.id ?? "");
    const txRef = String(data.tx_ref ?? "").trim().toUpperCase();

    if (event !== "charge.completed" || !flwId || !txRef) {
      return jsonResponse({ ignored: true, reason: "unsupported_event" });
    }

    const verifyResponse = await fetch(
      `https://api.flutterwave.com/v3/transactions/${encodeURIComponent(flwId)}/verify`,
      {
        headers: {
          Authorization: `Bearer ${flutterwaveSecret}`,
        },
      },
    );

    if (!verifyResponse.ok) {
      return jsonResponse({ error: "Could not verify Flutterwave charge" }, 502);
    }

    const verifiedPayload = asRecord(await verifyResponse.json()) ?? {};
    const verified = asRecord(verifiedPayload.data) ?? {};
    const verifiedStatus = String(verified.status ?? "").toLowerCase();
    const verifiedRef = String(verified.tx_ref ?? "").trim().toUpperCase();
    const verifiedCurrency = String(verified.currency ?? "").toUpperCase();
    const verifiedAmount = Number(verified.amount);
    const verifiedId = String(verified.id ?? flwId);

    if (verifiedRef !== txRef) {
      return jsonResponse({ ignored: true, reason: "reference_mismatch" });
    }

    const { data: intent, error: intentError } = await admin
      .from("collection_intents")
      .select("amount, currency, status")
      .eq("reference", txRef)
      .maybeSingle();

    if (intentError || !intent) {
      return jsonResponse({ ignored: true, reason: "unknown_reference" });
    }

    if (verifiedCurrency !== "GHS" || intent.currency !== "GHS") {
      return jsonResponse({ ignored: true, reason: "currency_mismatch" });
    }

    if (!Number.isFinite(verifiedAmount) || !amountsMatch(verifiedAmount, Number(intent.amount))) {
      return jsonResponse({ ignored: true, reason: "amount_mismatch" });
    }

    let settleStatus: string | null = null;
    if (verifiedStatus === "successful") {
      settleStatus = "Completed";
    } else if (verifiedStatus === "failed" || verifiedStatus === "cancelled") {
      settleStatus = verifiedStatus === "cancelled" ? "Cancelled" : "Failed";
    }

    if (!settleStatus) {
      return jsonResponse({ ignored: true, reason: "not_terminal" });
    }

    const { data: transaction, error } = await admin.rpc("settle_ghana_collection", {
      p_reference: txRef,
      p_status: settleStatus,
      p_provider_event_id: `flw:${verifiedId}`,
      p_actor_wallet_id: null,
    });

    if (error) {
      return jsonResponse({ error: error.message }, 400);
    }

    return jsonResponse({ transaction });
  }

  const reference = String(payload.reference ?? "").trim();
  const status = String(payload.status ?? "").trim();
  const providedEventId = String(payload.provider_event_id ?? "").trim();

  if (!reference || !status) {
    return jsonResponse({ error: "Missing reference or status" }, 400);
  }

  const providedSecret = req.headers.get("x-kwanpay-collector-secret") ?? "";
  const isCollector =
    Boolean(collectorSecret) &&
    providedSecret.length > 0 &&
    providedSecret === collectorSecret;

  let actorWalletId: string | null = null;

  if (!isCollector) {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Not authenticated" }, 401);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const {
      data: { user },
      error,
    } = await userClient.auth.getUser();

    if (error || !user) {
      return jsonResponse({ error: "Not authenticated" }, 401);
    }

    actorWalletId = user.id;
  }

  const providerEventId = providedEventId ||
    (isCollector
      ? `collector:${reference}:${status}`
      : `test:${actorWalletId}:${reference}:${status}`);

  const { data, error } = await admin.rpc("settle_ghana_collection", {
    p_reference: reference,
    p_status: status,
    p_provider_event_id: providerEventId,
    p_actor_wallet_id: actorWalletId,
  });

  if (error) {
    return jsonResponse({ error: error.message }, 400);
  }

  return jsonResponse({ transaction: data });
});
