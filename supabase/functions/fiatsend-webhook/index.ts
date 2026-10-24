// Receives Fiatsend webhooks. Deploy with verify_jwt = false (Fiatsend can't
// send a Supabase JWT); authenticity comes from the HMAC signature instead.
//
// Handles:
//   checkout.session.completed      → credit a top-up
//   withdrawal.processing|completed|failed → update / refund a payout
// The webhook body is never trusted for money movement: we re-fetch the
// object from Fiatsend and settle from that. Settlement RPCs are idempotent,
// so duplicate deliveries are safe.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  CHECKOUT_BASE_URL,
  fiatsend,
  json,
  partnerBaseUrl,
  record,
  settleCollectionFromSession,
  settlePayoutFromWithdrawal,
  validSignature,
} from "../_shared/fiatsend.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const secret = Deno.env.get("FIATSEND_WEBHOOK_SECRET");
  if (!supabaseUrl || !serviceKey || !secret || !Deno.env.get("FIATSEND_API_KEY")) {
    return json({ error: "Webhook configuration is incomplete." }, 500);
  }

  const raw = await req.text(); // raw bytes — must not re-serialise before verifying
  if (!(await validSignature(raw, req.headers.get("x-fiatsend-signature"), secret))) {
    return json({ error: "Invalid signature." }, 401);
  }

  let payload: Record<string, unknown> | null;
  try {
    payload = record(JSON.parse(raw));
  } catch {
    return json({ error: "Invalid JSON payload." }, 400);
  }
  const name = String(payload?.type ?? payload?.event ?? "");
  const data = record(payload?.data);
  const admin = createClient(supabaseUrl, serviceKey);

  try {
    if (name === "checkout.session.completed") {
      const sessionId = String(record(data?.object)?.id ?? "").trim();
      if (!/^cs_[a-f0-9]{48}$/.test(sessionId)) return json({ received: true, processed: false });
      const session = await fiatsend(CHECKOUT_BASE_URL, `/checkout/sessions/${sessionId}`);
      const result = await settleCollectionFromSession(admin, session);
      return json({ received: true, processed: true, outcome: result.outcome });
    }

    if (name.startsWith("withdrawal.")) {
      const withdrawalId = String(data?.withdrawal_id ?? "").trim();
      const reference = String(data?.reference_id ?? "").trim().toUpperCase();
      if (!withdrawalId || !reference.startsWith("KWP-TXN-")) {
        return json({ received: true, processed: false, reason: "unknown_reference" });
      }
      const { data: payout } = await admin.from("payout_intents").select("id, status, provider, provider_reference")
        .eq("reference", reference).maybeSingle();
      if (!payout) return json({ received: true, processed: false, reason: "payout_not_found" });
      if (payout.provider !== "fiatsend") return json({ received: true, processed: false, reason: "provider_mismatch" });
      if (payout.provider_reference && payout.provider_reference !== withdrawalId) {
        return json({ received: true, processed: false, reason: "provider_reference_mismatch" });
      }
      if (["Completed", "Failed", "Cancelled"].includes(String(payout.status))) {
        return json({ received: true, processed: false, reason: "already_final" });
      }
      const res = await fiatsend(partnerBaseUrl(), `/withdrawals/${encodeURIComponent(withdrawalId)}`);
      const result = await settlePayoutFromWithdrawal(admin, reference, record(res.data) ?? {});
      return json({ received: true, processed: true, status: result.status });
    }

    return json({ received: true, processed: false, reason: "ignored_event" });
  } catch (error) {
    // 5xx makes Fiatsend retry later.
    console.error("Fiatsend webhook processing failed", name, error instanceof Error ? error.message : error);
    return json({ error: "Processing failed." }, 500);
  }
});
