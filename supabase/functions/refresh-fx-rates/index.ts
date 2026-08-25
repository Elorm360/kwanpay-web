import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const CACHE_MS = 15 * 60 * 1000;
const QUOTES = ["GHS", "NGN", "KES", "ZAR"] as const;

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function inverse(rate: number) {
  return 1 / rate;
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

  if (!supabaseUrl || !serviceRoleKey) {
    return jsonResponse({ error: "FX refresh is not configured" }, 500);
  }

  const admin = createClient(supabaseUrl, serviceRoleKey);
  const { data: latest } = await admin
    .from("fx_rates")
    .select("as_of, is_test, quote_currency")
    .eq("is_test", false)
    .eq("base_currency", "GHS");

  const quotes = new Set(
    (latest ?? []).map((row) => String(row.quote_currency ?? "").toUpperCase()),
  );
  const hasDisplayQuotes = QUOTES.every(
    (code) => code === "GHS" || quotes.has(code),
  );
  const newest = (latest ?? [])
    .map((row) => new Date(String(row.as_of)).getTime())
    .filter((value) => Number.isFinite(value))
    .sort((a, b) => b - a)[0];

  if (hasDisplayQuotes && newest && Date.now() - newest < CACHE_MS) {
    return jsonResponse({
      refreshed: false,
      as_of: new Date(newest).toISOString(),
      source: "cache",
    });
  }

  const feed = await fetch("https://open.er-api.com/v6/latest/USD");
  if (!feed.ok) {
    return jsonResponse({ error: "Live FX feed is unavailable" }, 502);
  }

  const payload = await feed.json() as {
    result?: string;
    time_last_update_utc?: string;
    rates?: Record<string, number>;
  };

  if (payload.result !== "success" || !payload.rates) {
    return jsonResponse({ error: "Live FX feed did not include rates" }, 502);
  }

  const usdRates: Record<string, number> = {};
  for (const code of QUOTES) {
    const rate = payload.rates[code];
    if (!rate || rate <= 0) {
      return jsonResponse({
        error: `Live FX feed did not include ${code}`,
      }, 502);
    }
    usdRates[code] = rate;
  }

  const asOf = payload.time_last_update_utc
    ? new Date(payload.time_last_update_utc).toISOString()
    : new Date().toISOString();

  const pairs: Array<{
    base_currency: string;
    quote_currency: string;
    rate: number;
  }> = [];

  for (const code of QUOTES) {
    pairs.push({
      base_currency: "USD",
      quote_currency: code,
      rate: usdRates[code],
    });
    pairs.push({
      base_currency: code,
      quote_currency: "USD",
      rate: inverse(usdRates[code]),
    });
  }

  const usdGhs = usdRates.GHS;
  for (const code of QUOTES) {
    if (code === "GHS") continue;
    pairs.push({
      base_currency: "GHS",
      quote_currency: code,
      rate: usdRates[code] / usdGhs,
    });
    pairs.push({
      base_currency: code,
      quote_currency: "GHS",
      rate: usdGhs / usdRates[code],
    });
  }

  const { error } = await admin.rpc("upsert_live_fx_rates", {
    p_source: "exchangerate-api.com",
    p_as_of: asOf,
    p_rates: pairs,
  });

  if (error) {
    return jsonResponse({ error: error.message }, 400);
  }

  return jsonResponse({
    refreshed: true,
    as_of: asOf,
    source: "exchangerate-api.com",
    pairs: pairs.length,
  });
});
