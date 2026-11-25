import { NextResponse } from "next/server";

import { passwordResetSchema } from "@/lib/admin-password";
import { getClientIp } from "@/lib/client-ip";
import {
  clearLoginFailures,
  getLoginRateLimit,
  recordFailedLogin,
} from "@/lib/login-rate-limit";
import { getSupabase } from "@/lib/supabase";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

const BAD_CODE = "That code is wrong or has expired. Ask for a new one.";

export async function POST(req: Request) {
  const ipKey = `reset-ip:${getClientIp(req.headers)}`;
  const ipLimit = getLoginRateLimit(ipKey);
  if (ipLimit.limited) {
    return NextResponse.json(
      { success: false, error: "Too many attempts. Try again later." },
      { status: 429, headers: { "Retry-After": String(ipLimit.retryAfterSeconds) } }
    );
  }

  const result = passwordResetSchema.safeParse(
    await req.json().catch(() => null)
  );
  if (!result.success) {
    return NextResponse.json(
      {
        success: false,
        error: result.error.issues[0]?.message ?? "Check the form and try again.",
      },
      { status: 400 }
    );
  }
  const { email, code, password } = result.data;

  // Codes are short, so wrong guesses are limited per account as well.
  const codeKey = `reset-code:${email}`;
  if (getLoginRateLimit(codeKey).limited) {
    return NextResponse.json(
      { success: false, error: "Too many attempts. Ask for a new code later." },
      { status: 429 }
    );
  }
  const fail = () => {
    recordFailedLogin(ipKey);
    recordFailedLogin(codeKey);
    return NextResponse.json({ success: false, error: BAD_CODE }, { status: 400 });
  };

  const supabaseAdmin = getSupabaseAdmin();
  const { data: admin } = await supabaseAdmin
    .from("admin_users")
    .select("id, is_active")
    .eq("email", email)
    .maybeSingle();

  // Only administrators reset here; app users use the app.
  if (!admin?.is_active) return fail();

  const client = getSupabase();
  const { data, error } = await client.auth.verifyOtp({
    email,
    token: code,
    type: "recovery",
  });
  if (error || !data.user || data.user.id !== admin.id) return fail();

  const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
    admin.id,
    { password }
  );
  // The recovery session has done its job; do not leave it usable.
  await client.auth.signOut({ scope: "global" }).catch(() => undefined);

  if (updateError) {
    console.error("ADMIN PASSWORD UPDATE ERROR:", updateError.code ?? updateError.message);
    const weak = updateError.code === "weak_password";
    return NextResponse.json(
      {
        success: false,
        error: weak
          ? "That password is too common or has appeared in a data breach. Choose another."
          : "Unable to change the password. Try again.",
      },
      { status: weak ? 400 : 500 }
    );
  }

  clearLoginFailures(codeKey);
  clearLoginFailures(`email:${email}`);
  return NextResponse.json({ success: true });
}
