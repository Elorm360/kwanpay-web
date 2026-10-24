// Starts a GHS wallet top-up through a Fiatsend hosted checkout session.
// The wallet is credited ONLY after verify-fiatsend-collection or
// fiatsend-webhook confirms the session is "complete" server-side.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  CHECKOUT_BASE_URL,
  corsHeaders,
  fiatsend,
  FiatsendError,
  first,
  json,
  NETWORKS,
  toE164,
} from "../_shared/fiatsend.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceKey) {
    return json({ error: "Supabase server configuration is incomplete." }, 500);
  }
  if (!Deno.env.get("FIATSEND_API_KEY")) {
    return json({ error: "Mobile Money top-ups are not configured yet." }, 503);
  }

  const authorization = req.headers.get("Authorization");
  if (!authorization) return json({ error: "Missing authorization." }, 401);
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  });
  const { data: { user }, error: userError } = await userClient.auth.getUser();
  if (userError || !user) return json({ error: "Not authenticated." }, 401);

  let body: { amount?: unknown; reference?: unknown; rail?: unknown; msisdn?: unknown };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON request body." }, 400);
  }

  const amount = Number(body.amount);
  const reference = String(body.reference ?? "").trim().toUpperCase();
  const rail = String(body.rail ?? "").trim().toLowerCase();
  const phone = toE164(body.msisdn);

  if (!Number.isFinite(amount) || amount <= 0 || Math.round(amount * 100) !== amount * 100) {
    return json({ error: "Enter a valid amount with at most two decimal places." }, 400);
  }
  if (!/^KWP-TXN-[A-Z0-9-]{1,80}$/.test(reference)) {
    return json({ error: "Invalid KwanPay transaction reference." }, 400);
  }
  if (!NETWORKS[rail]) return json({ error: "Unsupported Ghana Mobile Money network." }, 400);
  if (!phone) return json({ error: "Enter a valid Ghana Mobile Money number." }, 400);

  const admin = createClient(supabaseUrl, serviceKey);

  // Idempotent re-entry: same reference already has a checkout session.
  const { data: existing } = await admin
    .from("transactions")
    .select("*")
    .eq("reference", reference)
    .eq("wallet_id", user.id)
    .maybeSingle();

  if (existing && existing.status !== "Pending") {
    return json({ error: "This funding reference is no longer pending.", transaction: existing }, 409);
  }
  if (existing?.provider === "fiatsend" && existing?.provider_reference) {
    try {
      const session = await fiatsend(
        CHECKOUT_BASE_URL,
        `/checkout/sessions/${encodeURIComponent(existing.provider_reference)}`,
      );
      return json({
        success: true,
        already_initiated: true,
        checkout_url: session.url ?? null,
        transaction: existing,
      });
    } catch {
      return json({ success: true, already_initiated: true, checkout_url: null, transaction: existing });
    }
  }
  if (existing?.provider && existing.provider !== "fiatsend" && existing.provider_reference) {
    return json({ error: "This reference belongs to another payment provider." }, 409);
  }

  // 1. Pending KwanPay transaction (no balance change yet).
  if (!existing) {
    const { error: rpcError } = await userClient.rpc("initiate_ghana_collection", {
      p_amount: amount,
      p_reference: reference,
      p_rail: rail,
      p_msisdn: phone.replace("+233", "0"),
    });
    if (rpcError) {
      return json({ error: rpcError.message || "Could not create the funding transaction." }, 400);
    }
  }

  const { data: assigned, error: assignError } = await admin.rpc(
    "assign_pending_collection_provider",
    { p_reference: reference, p_provider: "fiatsend" },
  );
  if (assignError || !assigned) {
    await admin.rpc("fail_pending_collection", { p_reference: reference });
    return json({ error: "Could not prepare this payment. Start a new Add Funds request." }, 500);
  }

  // 2. Hosted checkout session.
  let session: Record<string, unknown>;
  try {
    session = await fiatsend(CHECKOUT_BASE_URL, "/checkout/sessions", {
      method: "POST",
      body: JSON.stringify({
        amount,
        currency: "GHS",
        description: "KwanPay wallet top-up",
        client_reference_id: reference,
        customer: { phone, ...(user.email ? { email: user.email } : {}) },
        accepted_methods: ["mobile_money"],
        metadata: { wallet_id: user.id, kwanpay_reference: reference, rail },
      }),
    });
  } catch (error) {
    const { data: failed } = await admin.rpc("fail_pending_collection", { p_reference: reference });
    const message = error instanceof FiatsendError ? error.message : "Fiatsend is unavailable.";
    console.error("Fiatsend checkout failed", error instanceof FiatsendError ? error.code : error);
    return json({ error: message, transaction: first(failed) ?? first(assigned) }, 400);
  }

  const sessionId = String(session.id ?? "").trim();
  const checkoutUrl = String(session.url ?? "").trim();
  if (!sessionId || !checkoutUrl) {
    await admin.rpc("fail_pending_collection", { p_reference: reference });
    return json({ error: "Fiatsend did not return a checkout session." }, 502);
  }

  const { data: attached, error: attachError } = await admin.rpc("attach_provider_reference", {
    p_reference: reference,
    p_provider: "fiatsend",
    p_provider_reference: sessionId,
  });
  if (attachError) {
    return json({ error: "Checkout was created but could not be recorded safely." }, 500);
  }

  return json({
    success: true,
    status: "Pending",
    provider: "fiatsend",
    provider_reference: sessionId,
    checkout_url: checkoutUrl,
    message: "Complete the payment on the Fiatsend page, then come back and tap Refresh status.",
    transaction: first(attached),
  });
});
