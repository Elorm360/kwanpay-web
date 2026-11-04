// Starts a GHS wallet top-up through a Fiatsend hosted checkout session.
// The wallet is credited ONLY after verify-fiatsend-collection or
// fiatsend-webhook confirms the session is "complete".
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
  record,
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

  // Do not treat a failed lookup as "no transaction": doing so could create
  // a second funding intent after a transient database error.
  const { data: existing, error: lookupError } = await admin
    .from("transactions")
    .select("*")
    .eq("reference", reference)
    .eq("wallet_id", user.id)
    .maybeSingle();

  if (lookupError) {
    console.error("Could not look up Fiatsend funding reference", reference, lookupError.message);
    return json({ error: "Could not check the existing payment. Please retry shortly." }, 503);
  }

  if (existing && existing.status !== "Pending") {
    return json({ error: "This funding reference is no longer pending.", transaction: existing }, 409);
  }

  const existingSessionId = String(existing?.provider_reference ?? "").trim();
  const hasCheckoutSession = /^cs_[a-f0-9]{48}$/.test(existingSessionId);

  if (existing?.provider === "fiatsend" && hasCheckoutSession) {
    try {
      const session = await fiatsend(
        CHECKOUT_BASE_URL,
        `/checkout/sessions/${encodeURIComponent(existingSessionId)}`,
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

  // A previous request may have reached Fiatsend but timed out before the
  // session ID was saved. Search the provider's recent sessions by our stable
  // client_reference_id before considering another create request. If no
  // session is visible, fail closed: never create a second checkout blindly.
  if (existing?.provider === "fiatsend" && !hasCheckoutSession) {
    try {
      const list = await fiatsend(CHECKOUT_BASE_URL, "/checkout/sessions?limit=100");
      const sessions = Array.isArray(list.data)
        ? list.data.map(record).filter((item): item is Record<string, unknown> => item !== null)
        : [];
      const recovered = sessions.find((session) => session?.client_reference_id === reference);

      if (recovered) {
        const sessionId = String(recovered.id ?? "").trim();
        const checkoutUrl = String(recovered.url ?? "").trim();
        if (sessionId) {
          const { data: attached, error: attachError } = await admin.rpc("attach_provider_reference", {
            p_reference: reference,
            p_provider: "fiatsend",
            p_provider_reference: sessionId,
          });
          if (attachError) {
            console.error("Could not attach recovered Fiatsend session", reference, attachError.message);
            return json({
              success: true,
              status: "Pending",
              reconciliation_required: true,
              transaction: existing,
              message: "A payment session was found but could not be linked safely. Do not start another payment; contact support.",
            }, 202);
          }
          return json({
            success: true,
            already_initiated: true,
            checkout_url: checkoutUrl || null,
            transaction: first(attached),
          });
        }
      }
    } catch (error) {
      console.error("Could not recover Fiatsend checkout session", reference,
        error instanceof FiatsendError ? error.code : "provider_lookup_failed");
    }

    return json({
      success: true,
      status: "Pending",
      reconciliation_required: true,
      transaction: existing,
      message: "We are checking the status of your earlier payment request. Do not start another payment. Refresh status again shortly or contact support.",
    }, 202);
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
    console.error("Could not assign Fiatsend provider", reference, assignError?.message);
    return json({ error: "Could not prepare this payment. Please retry or contact support." }, 500);
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
    const message = error instanceof FiatsendError ? error.message : "Fiatsend is temporarily unavailable.";
    const ambiguous = !(error instanceof FiatsendError) || error.retryable || error.status === 408;
    console.error("Fiatsend checkout failed", reference,
      error instanceof FiatsendError ? error.code : "network_or_unknown_error");

    // A timeout/5xx can happen after Fiatsend has created the session. Keep
    // the KwanPay transaction Pending so a later reconciliation can recover
    // and settle it. Only definitive provider rejections are marked Failed.
    if (ambiguous) {
      return json({
        success: true,
        status: "Pending",
        reconciliation_required: true,
        transaction: first(assigned),
        message: "We could not confirm whether the payment page was created. Do not start another payment. Refresh status shortly or contact support.",
      }, 202);
    }

    const { data: failed, error: failError } = await admin.rpc("fail_pending_collection", {
      p_reference: reference,
    });
    if (failError) {
      console.error("Could not mark definitively rejected Fiatsend request failed", reference, failError.message);
    }
    return json({ error: message, transaction: first(failed) ?? first(assigned) }, 400);
  }

  const sessionId = String(session.id ?? "").trim();
  const checkoutUrl = String(session.url ?? "").trim();
  if (!sessionId || !checkoutUrl) {
    // A 2xx response with an incomplete body is still ambiguous: the provider
    // may have created a session. Leave the transaction pending for recovery.
    return json({
      success: true,
      status: "Pending",
      reconciliation_required: true,
      transaction: first(assigned),
      message: "The payment page response could not be verified. Do not start another payment; refresh status or contact support.",
    }, 202);
  }

  const { data: attached, error: attachError } = await admin.rpc("attach_provider_reference", {
    p_reference: reference,
    p_provider: "fiatsend",
    p_provider_reference: sessionId,
  });
  if (attachError) {
    console.error("Fiatsend checkout created but session reference could not be saved", reference, attachError.message);
    return json({
      success: true,
      status: "Pending",
      reconciliation_required: true,
      transaction: first(assigned),
      message: "The payment page was created but could not be linked yet. Do not open another payment; refresh status or contact support.",
    }, 202);
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
