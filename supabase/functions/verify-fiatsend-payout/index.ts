// Refreshes a Fiatsend withdrawal's status for the signed-in user.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  corsHeaders,
  fiatsend,
  FiatsendError,
  json,
  partnerBaseUrl,
  record,
  settlePayoutFromWithdrawal,
} from "../_shared/fiatsend.ts";

const stillChecking = (transaction: unknown, payout: unknown) =>
  json({
    success: true,
    status: "Pending",
    transaction,
    payout,
    message: "The withdrawal is still being processed. Your reserved funds remain protected.",
  }, 202);

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
    return json({ error: "Invalid withdrawal reference." }, 400);
  }

  const admin = createClient(supabaseUrl, serviceKey);
  const { data: payout } = await admin.from("payout_intents").select("*").eq("reference", reference).maybeSingle();
  if (!payout || payout.wallet_id !== user.id) return json({ error: "Withdrawal request not found." }, 404);
  if (payout.provider !== "fiatsend") return json({ error: "This withdrawal is not a Fiatsend payout." }, 409);

  const { data: txn } = await admin.from("transactions").select("*").eq("id", payout.transaction_id).maybeSingle();
  if (["Completed", "Failed", "Cancelled"].includes(String(payout.status))) {
    return json({ success: true, status: payout.status, transaction: txn, payout });
  }

  const base = partnerBaseUrl();
  try {
    let withdrawal: Record<string, unknown> | null = null;
    if (payout.provider_reference) {
      const res = await fiatsend(base, `/withdrawals/${encodeURIComponent(payout.provider_reference)}`);
      withdrawal = record(res.data);
    } else {
      // Initial call timed out before we stored the withdrawal_id.
      const res = await fiatsend(base, `/transactions?reference_id=${encodeURIComponent(reference)}&per_page=5`);
      const rows = Array.isArray(res.data) ? res.data : [];
      withdrawal = rows.map(record).find((w) =>
        String(w?.reference_id ?? "").toUpperCase() === reference
      ) ?? null;
    }
    if (!withdrawal) return stillChecking(txn, payout);

    const result = await settlePayoutFromWithdrawal(admin, reference, withdrawal);
    const { data: finalTxn } = await admin.from("transactions").select("*").eq("id", payout.transaction_id).maybeSingle();
    return json({ success: true, status: result.status, transaction: finalTxn ?? txn, payout: result.payout ?? payout });
  } catch (error) {
    if (error instanceof FiatsendError && (error.retryable || error.status === 404)) {
      return stillChecking(txn, payout);
    }
    return json({ error: "The withdrawal could not be verified. Please try again." }, 422);
  }
});
