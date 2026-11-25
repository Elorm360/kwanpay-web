import { NextResponse } from "next/server";

import { passwordResetRequestSchema } from "@/lib/admin-password";
import { getClientIp } from "@/lib/client-ip";
import { getLoginRateLimit, recordFailedLogin } from "@/lib/login-rate-limit";
import { getSupabase } from "@/lib/supabase";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

// Same answer whether or not the email is an admin, so this cannot be used
// to find out who the administrators are.
const SENT = {
  success: true,
  message:
    "If that email belongs to an administrator, a reset code is on its way.",
};

export async function POST(req: Request) {
  const ipKey = `reset-ip:${getClientIp(req.headers)}`;
  const ipLimit = getLoginRateLimit(ipKey);
  if (ipLimit.limited) {
    return NextResponse.json(
      { success: false, error: "Too many requests. Try again later." },
      { status: 429, headers: { "Retry-After": String(ipLimit.retryAfterSeconds) } }
    );
  }

  const result = passwordResetRequestSchema.safeParse(
    await req.json().catch(() => null)
  );
  if (!result.success) {
    return NextResponse.json(
      { success: false, error: "Enter a valid email address." },
      { status: 400 }
    );
  }

  // Every request sends an email, so every request counts toward the limit.
  const emailKey = `reset-email:${result.data.email}`;
  recordFailedLogin(ipKey);
  if (getLoginRateLimit(emailKey).limited) return NextResponse.json(SENT);
  recordFailedLogin(emailKey);

  const { data: admin } = await getSupabaseAdmin()
    .from("admin_users")
    .select("id, is_active")
    .eq("email", result.data.email)
    .maybeSingle();

  if (admin?.is_active) {
    const { error } = await getSupabase().auth.resetPasswordForEmail(
      result.data.email
    );
    if (error) {
      console.error("ADMIN RESET EMAIL ERROR:", error.code ?? error.message);
      if (error.status === 429) {
        return NextResponse.json(
          {
            success: false,
            error: "Our email service is busy. Wait a minute and try again.",
          },
          { status: 429 }
        );
      }
    }
  }

  return NextResponse.json(SENT);
}
