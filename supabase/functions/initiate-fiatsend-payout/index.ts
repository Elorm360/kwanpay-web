// Withdraws GHS from a KwanPay wallet to Ghana Mobile Money via Fiatsend.
//
// Fiatsend payouts are funded in a stablecoin (USDC/USDT) from the KwanPay
// business balance and delivered to the recipient in GHS. We quote the
// stablecoin amount needed so the user receives at least the GHS they asked
// for. Fiatsend limits: GHS 50.00 – 15,000.00 delivered per payout.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  centsToString,
  corsHeaders,
  fiatsend,
  FiatsendError,
  first,
  json,
  NETWORKS,
  partnerBaseUrl,
  record,
  settlePayoutFromWithdrawal,
  toCents,
  toE164,
} from "../_shared/fiatsend.ts";

const MIN_GHS_CENTS = 5000;
const MAX_GHS_CENTS = 1_500_000;

async function quoteSourceAmount(base: string, coin: string, ghsCents: number): Promise<string> {
  const quote = async (amount: string) => {
    const res = await fiatsend(
      base,
      `/rates?from_currency=${coin}&to_currency=GHS&amount=${encodeURIComponent(amount)}`,
    );
    const data = record(res.data) ?? {};
    return { rate: Number(data.rate), fee: Number(data.fee), total: toCents(data.total_ghs) ?? 0 };
  };

  // total_ghs = (amount − fee) × rate  →  amount = ghs / rate + fee
  const probe = await quote("10.00");
  if (!(probe.rate > 0)) throw new FiatsendError(502, "BAD_RATE", "Fiatsend returned no rate.");
  let coinCents = Math.ceil((ghsCents / probe.rate) + (probe.fee * 100));
  for (let i = 0; i < 3; i++) {
    const q = await quote(centsToString(coinCents));
    if (q.total >= ghsCents) return centsToString(coinCents);
    coinCents += Math.max(1, Math.ceil((ghsCents - q.total) / q.rate));
  }
  throw new FiatsendError(502, "QUOTE_FAILED", "Could not get a stable withdrawal quote.");
}

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
    return json({ error: "Withdrawals are not configured yet." }, 503);
  }
  const coin = (Deno.env.get("FIATSEND_PAYOUT_CURRENCY") ?? "USDC").toUpperCase();
  const base = partnerBaseUrl();

  const authorization = req.headers.get("Authorization");
  if (!authorization) return json({ error: "Missing authorization." }, 401);
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  });
  const { data: { user }, error: userError } = await userClient.auth.getUser();
  if (userError || !user) return json({ error: "Not authenticated." }, 401);

  let body: { amount?: unknown; payment_method_id?: unknown };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON request body." }, 400);
  }

  const ghsCents = toCents(body.amount);
  const paymentMethodId = String(body.payment_method_id ?? "").trim();
  if (ghsCents == null || ghsCents <= 0 || Number(body.amount) * 100 !== ghsCents) {
    return json({ error: "Enter a valid withdrawal amount with up to two decimal places." }, 400);
  }
  if (ghsCents < MIN_GHS_CENTS || ghsCents > MAX_GHS_CENTS) {
    return json({ error: "Withdrawals must be between GHS 50.00 and GHS 15,000.00." }, 400);
  }
  if (!paymentMethodId) return json({ error: "A Mobile Money payment method is required." }, 400);

  const admin = createClient(supabaseUrl, serviceKey);
  const reference = `KWP-TXN-${Date.now().toString(36).toUpperCase()}-${
    crypto.randomUUID().replaceAll("-", "").slice(0, 10).toUpperCase()
  }`;

  // 1. Reserve the GHS balance and create the payout record.
  const { data: created, error: createError } = await userClient.rpc(
    "create_ghana_payout_from_payment_method",
    { p_amount: ghsCents / 100, p_reference: reference, p_payment_method_id: paymentMethodId },
  );
  if (createError) return json({ error: createError.message }, 400);

  const createdPayload = record(first(created));
  const transaction = record(createdPayload?.transaction);
  const payout = record(createdPayload?.payout);
  if (!transaction || !payout) return json({ error: "Withdrawal request could not be created." }, 500);

  const failAndRefund = async (reason: string, message: string) => {
    const settled = await admin.rpc("settle_ghana_payout", {
      p_reference: reference,
      p_status: "Failed",
      p_provider_reference: null,
      p_provider_status: "failed",
      p_failure_reason: reason,
    });
    if (settled.error) {
      return json({ error: "The withdrawal could not be completed safely. Please contact support." }, 500);
    }
    return json({ error: message }, 422);
  };

  // create_ghana_payout_from_payment_method defaults to 'fincra'.
  const assigned = await admin.rpc("assign_pending_payout_provider", {
    p_reference: reference,
    p_provider: "fiatsend",
  });
  if (assigned.error) {
    return failAndRefund("Could not assign payout provider.", "The withdrawal could not be started. Your funds were returned.");
  }

  const destination = record(payout.destination_snapshot) ?? {};
  const phone = toE164(destination.msisdn);
  const network = NETWORKS[String(destination.rail ?? "").toLowerCase()];
  if (!phone || !network) {
    return failAndRefund("Invalid destination.", "This Mobile Money number can't receive withdrawals. Your funds were returned.");
  }

  // 2. Quote + send the payout. reference_id = our reference (idempotent).
  let withdrawal: Record<string, unknown>;
  try {
    const sourceAmount = await quoteSourceAmount(base, coin, ghsCents);
    const res = await fiatsend(base, "/withdrawals", {
      method: "POST",
      body: JSON.stringify({
        amount: sourceAmount,
        currency: coin,
        recipient_phone: phone,
        mobile_network: network,
        reference_id: reference,
        metadata: { wallet_id: user.id, ghs_requested: centsToString(ghsCents) },
      }),
    });
    withdrawal = record(res.data) ?? {};
  } catch (error) {
    if (error instanceof FiatsendError && !error.retryable) {
      console.error("Fiatsend payout rejected", error.code);
      return failAndRefund(`${error.code}: ${error.message}`, `${error.message} Your funds were returned to your wallet.`);
    }
    // Timeout / 5xx: the payout may exist. Keep funds reserved; verify later
    // with the same reference_id (Fiatsend de-duplicates on it).
    return json({
      success: true,
      status: "Pending",
      transaction,
      payout,
      message: "Withdrawal is being checked. Your reserved funds remain protected.",
    }, 202);
  }

  try {
    const result = await settlePayoutFromWithdrawal(admin, reference, withdrawal);
    const { data: finalTxn } = await admin.from("transactions").select("*").eq("reference", reference).maybeSingle();
    return json({
      success: true,
      status: result.status,
      transaction: finalTxn ?? transaction,
      payout: result.payout ?? payout,
      ghs_amount: withdrawal.ghs_amount ?? null,
      message: result.status === "Completed"
        ? "Withdrawal completed."
        : "Withdrawal is processing. We will update your activity when it is complete.",
    }, result.status === "Completed" ? 200 : 202);
  } catch {
    return json({ error: "Withdrawal was accepted but could not be recorded safely. Please contact support." }, 500);
  }
});
