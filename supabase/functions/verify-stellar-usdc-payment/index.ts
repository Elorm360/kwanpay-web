import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const HORIZON_URL = "https://horizon-testnet.stellar.org";
const USDC_ISSUER = "GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5";

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

function amountsMatch(left: number, right: number) {
  return Math.round(left * 100) === Math.round(right * 100);
}

function bytesToHex(bytes: Uint8Array) {
  return Array.from(bytes)
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

function normalizeMemo(value: string) {
  const trimmed = value.trim();
  try {
    const hexFromBase64 = bytesToHex(Uint8Array.from(atob(trimmed), (char) =>
      char.charCodeAt(0)
    ));
    if (hexFromBase64.length === 64) {
      return hexFromBase64.toLowerCase();
    }
  } catch (_) {
    // Not base64.
  }
  return trimmed.replace(/^0x/i, "").toLowerCase();
}

async function sha256Hex(value: string) {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return bytesToHex(new Uint8Array(digest));
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

  if (!supabaseUrl || !serviceRoleKey || !anonKey) {
    return jsonResponse({ error: "Stellar verify is not configured" }, 500);
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
  const txHash = String(payload.tx_hash ?? "").trim().toLowerCase();
  if (!reference || !txHash) {
    return jsonResponse({ error: "Missing payment reference or transaction hash" }, 400);
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
  const { data: txn, error: txnError } = await admin
    .from("transactions")
    .select("*")
    .eq("reference", reference)
    .eq("wallet_id", user.id)
    .maybeSingle();

  if (txnError || !txn) {
    return jsonResponse({ error: "Payment not found" }, 404);
  }

  if (txn.type !== "Payment" || txn.provider !== "stellar_testnet") {
    return jsonResponse({ error: "Not a Stellar USDC payment" }, 400);
  }

  if (txn.status === "Completed" &&
    String(txn.provider_reference ?? "").toLowerCase() === txHash) {
    return jsonResponse({ transaction: txn });
  }

  const { data: wallet } = await admin
    .from("wallets")
    .select("stellar_public_key")
    .eq("id", user.id)
    .maybeSingle();

  const senderKey = String(wallet?.stellar_public_key ?? "");
  const merchantKey = String(txn.provider_reference ?? "");
  if (!senderKey || !merchantKey.startsWith("G")) {
    return jsonResponse({ error: "Missing Stellar accounts for this payment" }, 400);
  }

  const txResponse = await fetch(`${HORIZON_URL}/transactions/${txHash}`);
  if (!txResponse.ok) {
    return jsonResponse({ error: "Horizon did not find that transaction" }, 400);
  }

  const horizonTx = asRecord(await txResponse.json()) ?? {};
  if (horizonTx.successful !== true) {
    return jsonResponse({ error: "Stellar transaction was not successful" }, 400);
  }

  if (String(horizonTx.memo_type ?? "") !== "hash") {
    return jsonResponse({ error: "Payment memo does not match this KwanPay reference" }, 400);
  }

  const expectedMemo = await sha256Hex(reference);
  const actualMemo = normalizeMemo(String(horizonTx.memo ?? ""));
  if (actualMemo !== expectedMemo) {
    return jsonResponse({ error: "Payment memo does not match this KwanPay reference" }, 400);
  }

  const opsResponse = await fetch(`${HORIZON_URL}/transactions/${txHash}/operations`);
  if (!opsResponse.ok) {
    return jsonResponse({ error: "Horizon did not return payment operations" }, 502);
  }

  const opsPayload = asRecord(await opsResponse.json()) ?? {};
  const embedded = asRecord(opsPayload._embedded);
  const records = Array.isArray(embedded?.records) ? embedded.records : [];
  const payment = records
    .map(asRecord)
    .find((operation) =>
      operation != null &&
      String(operation.type ?? "") === "payment" &&
      String(operation.asset_code ?? "") === "USDC" &&
      String(operation.asset_issuer ?? "") === USDC_ISSUER
    );

  if (!payment) {
    return jsonResponse({ error: "Horizon did not show a Testnet USDC payment" }, 400);
  }

  if (String(payment.from ?? "") !== senderKey) {
    return jsonResponse({ error: "Payment sender does not match this wallet" }, 400);
  }

  if (String(payment.to ?? "") !== merchantKey) {
    return jsonResponse({ error: "Payment destination does not match this operator" }, 400);
  }

  if (!amountsMatch(Number(payment.amount), Number(txn.amount))) {
    return jsonResponse({ error: "Payment amount does not match the KwanPay request" }, 400);
  }

  const { data: confirmed, error: confirmError } = await admin.rpc(
    "confirm_stellar_usdc_payment",
    {
      p_reference: reference,
      p_tx_hash: txHash,
    },
  );

  if (confirmError) {
    return jsonResponse({ error: confirmError.message }, 400);
  }

  return jsonResponse({ transaction: confirmed });
});
