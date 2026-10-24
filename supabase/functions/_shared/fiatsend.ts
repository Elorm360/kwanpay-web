// Shared Fiatsend Partner API helpers (server-side only).
// Docs: https://developer.fiatsend.com  (OpenAPI v1.3.0)
//
// Secrets (Supabase → Edge Functions → Secrets):
//   FIATSEND_API_KEY         fs_test_… (sandbox) or fs_live_… (production)
//   FIATSEND_WEBHOOK_SECRET  shared secret used to sign webhooks
//   FIATSEND_BASE_URL        optional, defaults to the sandbox
//   FIATSEND_PAYOUT_CURRENCY optional, USDC (default) or USDT

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export const json = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

export const record = (value: unknown): Record<string, unknown> | null =>
  value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : null;

export const first = (value: unknown) => Array.isArray(value) ? value[0] : value;

// Withdrawals/rates use the sandbox host for fs_test_ keys.
export const partnerBaseUrl = () =>
  (Deno.env.get("FIATSEND_BASE_URL") ?? "https://sandbox.fiatsend.com/v1").replace(/\/$/, "");

// Checkout sessions always use api.fiatsend.com; the key prefix picks test vs live.
export const CHECKOUT_BASE_URL = "https://api.fiatsend.com/v1";

export const NETWORKS: Record<string, string> = {
  mtn: "MTN",
  telecel: "TELECEL",
  airteltigo: "AIRTELTIGO",
};

export class FiatsendError extends Error {
  constructor(public status: number, public code: string, message: string) {
    super(message);
  }
  get retryable() {
    return this.status === 429 || this.status >= 500;
  }
}

export async function fiatsend(
  base: string,
  path: string,
  init: RequestInit = {},
): Promise<Record<string, unknown>> {
  const apiKey = Deno.env.get("FIATSEND_API_KEY");
  if (!apiKey) throw new FiatsendError(503, "NOT_CONFIGURED", "Fiatsend is not configured.");

  const res = await fetch(`${base}${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      Accept: "application/json",
      ...(init.headers ?? {}),
    },
  });

  let body: Record<string, unknown> = {};
  if (res.status !== 204) {
    try {
      body = record(await res.json()) ?? {};
    } catch {
      throw new FiatsendError(502, "BAD_RESPONSE", "Fiatsend returned an invalid response.");
    }
  }

  if (!res.ok) {
    // Two error shapes: {code,message} and {error:{code,message}}.
    const nested = record(body.error);
    const code = String(body.code ?? nested?.code ?? res.status);
    const message = String(body.message ?? nested?.message ?? "Fiatsend request failed.");
    throw new FiatsendError(res.status, code, message);
  }
  return body;
}

// Ghana number in any common form → +233XXXXXXXXX
export function toE164(value: unknown): string | null {
  let digits = String(value ?? "").replace(/\D/g, "");
  if (digits.length === 10 && digits.startsWith("0")) digits = `233${digits.slice(1)}`;
  if (digits.length === 9) digits = `233${digits}`;
  return /^233\d{9}$/.test(digits) ? `+${digits}` : null;
}

// Constant-time HMAC-SHA256 check. Accepts "sha256=<hex>" and bare hex.
export async function validSignature(raw: string, header: string | null, secret: string) {
  if (!header) return false;
  const received = (header.startsWith("sha256=") ? header.slice(7) : header).trim().toLowerCase();
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const mac = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(raw));
  const expected = Array.from(new Uint8Array(mac)).map((b) => b.toString(16).padStart(2, "0")).join("");
  if (received.length !== expected.length) return false;
  let diff = 0;
  for (let i = 0; i < expected.length; i++) diff |= received.charCodeAt(i) ^ expected.charCodeAt(i);
  return diff === 0;
}

// Integer minor units to avoid float drift on money.
export const toCents = (v: unknown) => {
  const n = Number(v);
  return Number.isFinite(n) ? Math.round(n * 100) : null;
};
export const centsToString = (c: number) => (c / 100).toFixed(2);

// Settle a top-up from a checkout session that was fetched from Fiatsend
// server-side (never trust a webhook body or client for the final state).
// deno-lint-ignore no-explicit-any
export async function settleCollectionFromSession(admin: any, session: Record<string, unknown>) {
  const reference = String(session.client_reference_id ?? "").trim().toUpperCase();
  const sessionId = String(session.id ?? "").trim();
  const status = String(session.status ?? "").toLowerCase();

  const { data: txn, error } = await admin
    .from("transactions").select("*").eq("reference", reference).maybeSingle();
  if (error) throw new Error("Could not load the transaction.");
  if (!txn) return { outcome: "not_found" as const, transaction: null };
  if (txn.provider !== "fiatsend" || txn.provider_reference !== sessionId) {
    return { outcome: "mismatch" as const, transaction: txn };
  }
  if (txn.status !== "Pending") return { outcome: "already_final" as const, transaction: txn };

  if (status === "complete") {
    const paid = toCents(session.amount);
    const currency = String(session.currency ?? "GHS").toUpperCase();
    if (currency !== "GHS" || paid == null || paid !== toCents(txn.amount)) {
      return { outcome: "amount_mismatch" as const, transaction: txn };
    }
    const { data, error: settleError } = await admin.rpc("settle_provider_transaction", {
      p_reference: reference, p_status: "Completed", p_provider_reference: sessionId,
    });
    if (settleError) throw new Error("Payment confirmed but the wallet could not be credited.");
    return { outcome: "completed" as const, transaction: first(data) };
  }
  if (status === "cancelled") {
    const { data, error: settleError } = await admin.rpc("settle_provider_transaction", {
      p_reference: reference, p_status: "Cancelled", p_provider_reference: sessionId,
    });
    if (settleError) throw new Error("Could not close the cancelled payment.");
    return { outcome: "cancelled" as const, transaction: first(data) };
  }
  return { outcome: "pending" as const, transaction: txn };
}

// Map a withdrawal fetched from Fiatsend onto the KwanPay payout ledger.
// settle_ghana_payout refunds the reserved balance on "Failed".
// deno-lint-ignore no-explicit-any
export async function settlePayoutFromWithdrawal(admin: any, reference: string, w: Record<string, unknown>) {
  const withdrawalId = String(w.withdrawal_id ?? "").trim();
  const status = String(w.status ?? "").toLowerCase();
  if (String(w.reference_id ?? "").trim().toUpperCase() !== reference) {
    throw new Error("Withdrawal reference mismatch.");
  }

  const attach = await admin.rpc("attach_ghana_payout_provider_reference", {
    p_reference: reference, p_provider_reference: withdrawalId, p_provider_status: status || null,
  });
  if (attach.error) throw new Error("Withdrawal could not be recorded safely.");

  const finalStatus = status === "completed" ? "Completed" : status === "failed" ? "Failed" : null;
  if (!finalStatus) return { status: "Processing", payout: first(attach.data) };

  const settled = await admin.rpc("settle_ghana_payout", {
    p_reference: reference,
    p_status: finalStatus,
    p_provider_reference: withdrawalId,
    p_provider_status: status,
    p_failure_reason: finalStatus === "Failed" ? String(w.failure_reason ?? "Withdrawal failed.") : null,
  });
  if (settled.error) throw new Error("Withdrawal settlement failed.");
  return { status: finalStatus, payout: first(settled.data) };
}
