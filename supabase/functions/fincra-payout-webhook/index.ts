import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const json = (body: Record<string, unknown>, status = 200) => new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });
const record = (v: unknown): Record<string, unknown> | null => v && typeof v === "object" && !Array.isArray(v) ? v as Record<string, unknown> : null;
const hex = (b: ArrayBuffer) => Array.from(new Uint8Array(b)).map((x) => x.toString(16).padStart(2, "0")).join("");
async function hmac(secret: string, body: string) { const key = await crypto.subtle.importKey("raw", new TextEncoder().encode(secret), { name: "HMAC", hash: "SHA-512" }, false, ["sign"]); return hex(await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(body))); }
const equal = (a: string, b: string) => { if (!a || !b || a.length !== b.length) return false; let d = 0; for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i); return d === 0; };
const amount = (v: unknown) => { const n = Number(v); return Number.isFinite(n) ? n : null; };

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);
  const supabaseUrl = Deno.env.get("SUPABASE_URL"), serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"), apiKey = Deno.env.get("FINCRA_API_SECRET_KEY"), webhookSecret = Deno.env.get("FINCRA_WEBHOOK_SECRET");
  if (!supabaseUrl || !serviceKey || !apiKey || !webhookSecret) return json({ error: "Webhook configuration is incomplete." }, 500);
  const rawBody = await req.text();
  const signature = req.headers.get("signature") ?? "";
  const expected = await hmac(webhookSecret, rawBody);
  if (!equal(signature.toLowerCase(), expected.toLowerCase())) return json({ error: "Invalid webhook signature." }, 401);
  let parsed: unknown; try { parsed = JSON.parse(rawBody); } catch { return json({ error: "Invalid JSON payload." }, 400); }
  const payload = record(parsed);
  const event = String(payload?.event ?? "").toLowerCase();
  const data = record(payload?.data);
  if (!data) return json({ received: true, processed: false });
  const customerReference = String(data.customerReference ?? "").trim().toUpperCase();
  const providerReference = String(data.reference ?? "").trim();
  if (!customerReference.startsWith("KWP-TXN-") || !providerReference) return json({ received: true, processed: false, reason: "unknown_reference" });
  const admin = createClient(supabaseUrl, serviceKey);
  const { data: payout, error } = await admin.from("payout_intents").select("*").eq("reference", customerReference).maybeSingle();
  if (error) return json({ error: error.message }, 500);
  if (!payout) return json({ received: true, processed: false, reason: "payout_not_found" });
  if (payout.provider !== "fincra" || payout.currency !== "GHS" || payout.destination_kind !== "momo") return json({ received: true, processed: false, reason: "payout_mismatch" });
  if (payout.provider_reference && String(payout.provider_reference).trim() !== providerReference) return json({ received: true, processed: false, reason: "provider_reference_mismatch" });
  const verification = await fetch(`https://api.fincra.com/disbursements/payouts/customer-reference/${encodeURIComponent(customerReference)}`, { headers: { accept: "application/json", "api-key": apiKey } });
  let verifiedParsed: unknown; try { verifiedParsed = await verification.json(); } catch { return json({ error: "Invalid Fincra payout verification response." }, 502); }
  const verifiedPayload = record(verifiedParsed);
  const verified = record(verifiedPayload?.data);
  if (!verification.ok || verifiedPayload?.success !== true || !verified) return json({ received: true, processed: false, reason: "provider_verification_failed" });
  const verifiedReference = String(verified.reference ?? "").trim();
  const verifiedCustomerReference = String(verified.customerReference ?? "").trim().toUpperCase();
  const verifiedStatus = String(verified.status ?? "").trim().toLowerCase();
  const verifiedAmount = amount(verified.amount);
  if (verifiedReference !== providerReference || verifiedCustomerReference !== customerReference) return json({ received: true, processed: false, reason: "reference_mismatch" });
  if (verifiedAmount == null || Math.abs(verifiedAmount - Number(payout.amount)) > 0.005) return json({ received: true, processed: false, reason: "amount_mismatch" });
  let finalStatus: string | null = null;
  if (event === "payout.successful" && verifiedStatus === "successful") finalStatus = "Completed";
  if (event === "payout.failed" && verifiedStatus === "failed") finalStatus = "Failed";
  if (!finalStatus) return json({ received: true, processed: false, reason: "not_terminal", provider_status: verifiedStatus });
  const settled = await admin.rpc("settle_ghana_payout", { p_reference: customerReference, p_status: finalStatus, p_provider_reference: verifiedReference, p_provider_status: verifiedStatus, p_failure_reason: finalStatus === "Failed" ? String(verified.reason ?? "Withdrawal failed.") : null });
  if (settled.error) return json({ error: "Provider verified but KwanPay settlement failed." }, 500);
  return json({ received: true, processed: true, status: finalStatus, payout: settled.data });
});
