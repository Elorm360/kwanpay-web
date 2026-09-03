import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

const record = (value: unknown): Record<string, unknown> | null =>
  value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : null;

const failAndRefund = async (
  admin: ReturnType<typeof createClient>,
  reference: string,
  failureReason: string,
  userMessage: string,
) => {
  const settled = await admin.rpc("settle_ghana_payout", {
    p_reference: reference,
    p_status: "Failed",
    p_provider_reference: null,
    p_provider_status: "failed",
    p_failure_reason: failureReason,
  });

  if (settled.error) {
    return json(
      { error: "The withdrawal could not be completed safely. Please contact support." },
      500,
    );
  }

  return json({ error: userMessage }, 422);
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const apiKey = Deno.env.get("FINCRA_API_SECRET_KEY");
  const businessId = Deno.env.get("FINCRA_BUSINESS_ID");

  if (!supabaseUrl || !anonKey || !serviceKey) {
    return json({ error: "Supabase server configuration is incomplete." }, 500);
  }
  if (!apiKey || !businessId) {
    return json({ error: "Withdrawal service is not configured." }, 503);
  }

  const authorization = req.headers.get("Authorization");
  if (!authorization) return json({ error: "Missing authorization." }, 401);

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  });
  const {
    data: { user },
    error: userError,
  } = await userClient.auth.getUser();
  if (userError || !user) return json({ error: "Not authenticated." }, 401);

  let body: { amount?: unknown; payment_method_id?: unknown };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON request body." }, 400);
  }

  const amount = Number(body.amount);
  const paymentMethodId = String(body.payment_method_id ?? "").trim();
  if (!Number.isFinite(amount) || amount <= 0 || Math.round(amount * 100) !== amount * 100) {
    return json({ error: "Enter a valid withdrawal amount with up to two decimal places." }, 400);
  }
  if (!paymentMethodId) {
    return json({ error: "A Mobile Money payment method is required." }, 400);
  }

  const admin = createClient(supabaseUrl, serviceKey);
  const reference = `KWP-TXN-${Date.now().toString(36).toUpperCase()}-${crypto.randomUUID().replaceAll("-", "").slice(0, 10).toUpperCase()}`;

  const { data: created, error: createError } = await userClient.rpc(
    "create_ghana_payout_from_payment_method",
    {
      p_amount: amount,
      p_reference: reference,
      p_payment_method_id: paymentMethodId,
    },
  );
  if (createError) return json({ error: createError.message }, 400);

  const createdPayload = record(Array.isArray(created) ? created[0] : created);
  const transaction = record(createdPayload?.transaction);
  const payout = record(createdPayload?.payout);
  if (!transaction || !payout) {
    return json({ error: "Withdrawal request could not be created." }, 500);
  }

  if (String(payout.provider_reference ?? "").trim()) {
    return json({ success: true, transaction, payout, idempotent: true });
  }

  const destination = record(payout.destination_snapshot) ?? {};
  const msisdn = String(destination.msisdn ?? "").trim();
  const rail = String(destination.rail ?? "").trim().toLowerCase();

  if (!/^233[0-9]{9}$/.test(msisdn)) {
    return failAndRefund(
      admin,
      reference,
      "The saved Mobile Money number is invalid.",
      "The saved Mobile Money number is invalid. Your funds were returned to your wallet.",
    );
  }

  const providersResponse = await fetch(
    "https://api.fincra.com/core/banks?country=GH&currency=GHS&paymentDestination=mobile_money_wallet",
    { headers: { accept: "application/json", "api-key": apiKey } },
  );

  let providersPayload: any;
  try {
    providersPayload = await providersResponse.json();
  } catch {
    return json(
      {
        success: true,
        status: "Pending",
        transaction,
        payout,
        message: "Withdrawal is being checked. Your reserved funds remain protected.",
      },
      202,
    );
  }

  if (!providersResponse.ok || providersPayload?.success !== true) {
    if (providersResponse.status >= 400 && providersResponse.status < 500) {
      return failAndRefund(
        admin,
        reference,
        "The Mobile Money provider list could not be used for this withdrawal.",
        "This Mobile Money network is not currently available for withdrawal. Your funds were returned to your wallet.",
      );
    }
    return json(
      {
        success: true,
        status: "Pending",
        transaction,
        payout,
        message: "Withdrawal is being checked. Your reserved funds remain protected.",
      },
      202,
    );
  }

  const providers = Array.isArray(providersPayload?.data) ? providersPayload.data : [];
  const provider = providers.find((item: any) => {
    const name = String(item?.name ?? "").toLowerCase();
    const code = String(item?.code ?? "").toLowerCase();
    if (rail === "mtn") return code === "mtn" || name.includes("mtn");
    if (rail === "telecel") return code === "vodafone" || name.includes("vodafone") || name.includes("telecel");
    if (rail === "airteltigo") return code === "airtel" || name.includes("airtel");
    return false;
  });

  const mobileMoneyCode = String(provider?.code ?? "").trim();
  if (!mobileMoneyCode) {
    return failAndRefund(
      admin,
      reference,
      "This Mobile Money network is not currently available for withdrawal.",
      "This Mobile Money network is not currently available for withdrawal. Your funds were returned to your wallet.",
    );
  }

  const resolveResponse = await fetch("https://api.fincra.com/core/accounts/resolve", {
    method: "POST",
    headers: {
      accept: "application/json",
      "Content-Type": "application/json",
      "api-key": apiKey,
    },
    body: JSON.stringify({
      accountNumber: msisdn,
      mobileMoneyCode,
      currency: "GHS",
      type: "mobile_money",
    }),
  });

  let resolvePayload: any;
  try {
    resolvePayload = await resolveResponse.json();
  } catch {
    return json(
      {
        success: true,
        status: "Pending",
        transaction,
        payout,
        message: "Withdrawal is being checked. Your reserved funds remain protected.",
      },
      202,
    );
  }

  const resolved = record(resolvePayload?.data);
  const accountName = String(resolved?.accountName ?? "").trim();
  const resolvedNumber = String(resolved?.accountNumber ?? msisdn).trim();

  if (!resolveResponse.ok || resolvePayload?.success !== true || !resolved || !accountName || resolvedNumber !== msisdn) {
    if (resolveResponse.status >= 400 && resolveResponse.status < 500) {
      return failAndRefund(
        admin,
        reference,
        "The Mobile Money destination could not be verified.",
        "We could not verify the Mobile Money destination. Your funds were returned to your wallet.",
      );
    }
    return json(
      {
        success: true,
        status: "Pending",
        transaction,
        payout,
        message: "Withdrawal is being checked. Your reserved funds remain protected.",
      },
      202,
    );
  }

  const nameParts = accountName.split(/\s+/).filter(Boolean);
  const firstName = nameParts[0] ?? "KwanPay";
  const lastName = nameParts.slice(1).join(" ") || "User";

  const providerResponse = await fetch("https://api.fincra.com/disbursements/payouts", {
    method: "POST",
    headers: {
      accept: "application/json",
      "Content-Type": "application/json",
      "api-key": apiKey,
    },
    body: JSON.stringify({
      business: businessId,
      sourceCurrency: "GHS",
      destinationCurrency: "GHS",
      amount,
      description: "KwanPay wallet withdrawal",
      paymentDestination: "mobile_money_wallet",
      customerReference: reference,
      beneficiary: {
        firstName,
        lastName,
        type: "individual",
        country: "GH",
        accountNumber: msisdn,
        mobileMoneyCode,
      },
    }),
  });

  let providerPayload: any;
  try {
    providerPayload = await providerResponse.json();
  } catch {
    return json(
      {
        success: true,
        status: "Pending",
        transaction,
        payout,
        message: "Withdrawal is being checked. Your reserved funds remain protected.",
      },
      202,
    );
  }

  const providerData = record(providerPayload?.data);
  const providerReference = String(providerData?.reference ?? "").trim();
  const providerStatus = String(providerData?.status ?? "").trim().toLowerCase();

  if (!providerResponse.ok || providerPayload?.success !== true || !providerData) {
    if (providerResponse.status >= 400 && providerResponse.status < 500) {
      return failAndRefund(
        admin,
        reference,
        "Withdrawal could not be processed by the payment provider.",
        "The withdrawal could not be processed. Your funds were returned to your wallet.",
      );
    }
    return json(
      {
        success: true,
        status: "Pending",
        transaction,
        payout,
        message: "Withdrawal is being checked. Your reserved funds remain protected.",
      },
      202,
    );
  }

  const attach = await admin.rpc("attach_ghana_payout_provider_reference", {
    p_reference: reference,
    p_provider_reference: providerReference,
    p_provider_status: providerStatus || null,
  });
  if (attach.error) {
    return json(
      {
        error: "Withdrawal was accepted but could not be recorded safely. Please contact support.",
      },
      500,
    );
  }

  if (providerStatus === "successful") {
    const settled = await admin.rpc("settle_ghana_payout", {
      p_reference: reference,
      p_status: "Completed",
      p_provider_reference: providerReference,
      p_provider_status: providerStatus,
      p_failure_reason: null,
    });

    if (settled.error) {
      return json(
        {
          success: true,
          status: "Pending",
          transaction,
          payout: attach.data,
          message: "Withdrawal was accepted and is awaiting final confirmation.",
        },
        202,
      );
    }

    const { data: finalTransaction } = await admin
      .from("transactions")
      .select("*")
      .eq("reference", reference)
      .maybeSingle();

    return json({
      success: true,
      status: "Completed",
      transaction: finalTransaction ?? transaction,
      payout: settled.data ?? attach.data,
    });
  }

  if (providerStatus === "failed") {
    return failAndRefund(
      admin,
      reference,
      "Withdrawal was declined by the payment network.",
      "The withdrawal was declined. Your funds were returned to your wallet.",
    );
  }

  return json(
    {
      success: true,
      status: "Processing",
      transaction,
      payout: attach.data,
      message: "Withdrawal is processing. We will update your activity when it is complete.",
    },
    202,
  );
});
