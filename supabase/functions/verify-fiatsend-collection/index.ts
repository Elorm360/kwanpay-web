// Lets the app's "Refresh status" button ask Fiatsend for the real
// checkout-session state and credit the wallet if it is complete.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  CHECKOUT_BASE_URL,
  corsHeaders,
  fiatsend,
  FiatsendError,
  json,
  settleCollectionFromSession,
} from "../_shared/fiatsend.ts";

const MESSAGES: Record<string, string> = {
  completed: "Payment confirmed. Your wallet has been credited.",
  cancelled: "This payment was cancelled. Your wallet was not credited.",
  pending: "Payment is still pending. Finish the payment on the Fiatsend page, then refresh again.",
  already_final: "This payment has already been finalised.",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceKey) {
    return json({ error: "Supabase server configuration is incomplete." }, 500);
  }

  const authorization = req.headers.get("Authorization");
  if (!authorization) return json({ error: "Missing authorization." }, 401);
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  });
  const { data: { user }, error: userError } = await userClient.auth.getUser();
  if (userError || !user) return json({ error: "Not authenticated." }, 401);

  let body: { reference?: unknown };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON request body." }, 400);
  }
  const reference = String(body.reference ?? "").trim().toUpperCase();
  if (!/^KWP-TXN-[A-Z0-9-]{1,80}$/.test(reference)) {
    return json({ error: "Invalid KwanPay transaction reference." }, 400);
  }

  const admin = createClient(supabaseUrl, serviceKey);
  const { data: txn } = await admin
    .from("transactions")
    .select("*")
    .eq("reference", reference)
    .eq("wallet_id", user.id)
    .maybeSingle();

  if (!txn) return json({ error: "Payment not found." }, 404);
  if (txn.provider !== "fiatsend" || !txn.provider_reference) {
    return json({ error: "This payment is not a Fiatsend top-up." }, 409);
  }
  if (txn.status !== "Pending") {
    return json({ success: true, transaction: txn, message: MESSAGES.already_final });
  }

  try {
    const session = await fiatsend(
      CHECKOUT_BASE_URL,
      `/checkout/sessions/${encodeURIComponent(txn.provider_reference)}`,
    );
    const result = await settleCollectionFromSession(admin, session);
    if (result.outcome === "amount_mismatch" || result.outcome === "mismatch") {
      console.error("Fiatsend session mismatch", reference, result.outcome);
      return json({ error: "Payment details did not match. Please contact support." }, 409);
    }
    return json({
      success: true,
      transaction: result.transaction ?? txn,
      checkout_url: result.outcome === "pending" ? session.url ?? null : null,
      message: MESSAGES[result.outcome] ?? MESSAGES.pending,
    });
  } catch (error) {
    if (error instanceof FiatsendError && error.retryable) {
      return json({ success: true, transaction: txn, message: MESSAGES.pending }, 202);
    }
    return json({ error: error instanceof Error ? error.message : "Could not verify the payment." }, 502);
  }
});
