import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { z } from "zod";

import {
  ADMIN_SESSION_COOKIE,
  ADMIN_SESSION_MAX_AGE_SECONDS,
  createAdminSessionToken,
} from "@/lib/admin-session";
import type { AdminUser } from "@/lib/admin-types";
import {
  clearLoginFailures,
  getLoginRateLimit,
  recordFailedLogin,
} from "@/lib/login-rate-limit";
import { getSupabase } from "@/lib/supabase";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

const loginSchema = z.object({
  email: z.string().trim().email().transform((value) => value.toLowerCase()),
  password: z.string().min(1).max(256),
});

export async function POST(req: Request) {
  const clientKey =
    req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";
  const rateLimit = getLoginRateLimit(clientKey);

  if (rateLimit.limited) {
    return NextResponse.json(
      { success: false, error: "Too many attempts. Try again later." },
      {
        status: 429,
        headers: { "Retry-After": String(rateLimit.retryAfterSeconds) },
      }
    );
  }

  const result = loginSchema.safeParse(await req.json().catch(() => null));
  if (!result.success) {
    return NextResponse.json(
      { success: false, error: "A password is required." },
      { status: 400 }
    );
  }

  const sessionSecret = process.env.ADMIN_SESSION_SECRET;

  if (!sessionSecret || sessionSecret.length < 32) {
    return NextResponse.json(
      { success: false, error: "Admin authentication is not configured." },
      { status: 503 }
    );
  }

  const supabaseAdmin = getSupabaseAdmin();
  const profileResult = await supabaseAdmin
    .from("admin_users")
    .select(
      "id, email, display_name, role, is_active, last_login_at, created_at"
    )
    .eq("email", result.data.email)
    .maybeSingle();
  let profile = profileResult.data;
  const profileError = profileResult.error;

  if (profileError) {
    console.error("ADMIN PROFILE LOOKUP ERROR:", profileError);
    return NextResponse.json(
      { success: false, error: "Apply the admin CRM database migration first." },
      { status: 503 }
    );
  }

  if (!profile && process.env.ADMIN_PASSWORD === result.data.password) {
    const { count, error: countError } = await supabaseAdmin
      .from("admin_users")
      .select("id", { count: "exact", head: true });

    if (countError) {
      return NextResponse.json(
        { success: false, error: "Unable to check administrator setup." },
        { status: 503 }
      );
    }

    if (count === 0) {
      const { data: listedUsers, error: listError } =
        await supabaseAdmin.auth.admin.listUsers({
          page: 1,
          perPage: 1000,
        });

      if (listError) {
        return NextResponse.json(
          { success: false, error: "Unable to check existing accounts." },
          { status: 503 }
        );
      }

      let authUser = listedUsers.users.find(
        (user) => user.email?.toLowerCase() === result.data.email
      );
      let createdNewUser = false;

      if (authUser) {
        const { data: updated, error: updateError } =
          await supabaseAdmin.auth.admin.updateUserById(authUser.id, {
            password: result.data.password,
            email_confirm: true,
          });

        if (updateError) {
          return NextResponse.json(
            { success: false, error: "Unable to prepare the owner account." },
            { status: 500 }
          );
        }
        authUser = updated.user;
      } else {
        const { data: created, error: createError } =
          await supabaseAdmin.auth.admin.createUser({
            email: result.data.email,
            password: result.data.password,
            email_confirm: true,
          });

        if (createError || !created.user) {
          return NextResponse.json(
            { success: false, error: "Unable to create the owner account." },
            { status: 500 }
          );
        }
        authUser = created.user;
        createdNewUser = true;
      }

      if (authUser) {
        const displayName = result.data.email.split("@")[0];
        const { data: bootstrapped, error: bootstrapError } = await supabaseAdmin
          .from("admin_users")
          .insert({
            id: authUser.id,
            email: result.data.email,
            display_name: displayName,
            role: "owner",
          })
          .select(
            "id, email, display_name, role, is_active, last_login_at, created_at"
          )
          .single();

        if (bootstrapError) {
          if (createdNewUser) {
            await supabaseAdmin.auth.admin.deleteUser(authUser.id);
          }
          return NextResponse.json(
            { success: false, error: "Unable to create the first owner." },
            { status: 500 }
          );
        }

        profile = bootstrapped;
      }
    }
  }

  const supabase = getSupabase();
  const { data: authData, error: authError } =
    await supabase.auth.signInWithPassword(result.data);

  if (
    authError ||
    !authData.user ||
    !profile ||
    profile.id !== authData.user.id ||
    !profile.is_active
  ) {
    recordFailedLogin(clientKey);
    return NextResponse.json(
      { success: false, error: "Incorrect email or password." },
      { status: 401 }
    );
  }

  const admin = profile as AdminUser;
  clearLoginFailures(clientKey);
  await supabaseAdmin
    .from("admin_users")
    .update({ last_login_at: new Date().toISOString() })
    .eq("id", admin.id);

  const token = await createAdminSessionToken(sessionSecret, {
    adminId: admin.id,
    email: admin.email,
    displayName: admin.display_name,
    role: admin.role,
  });
  const cookieStore = await cookies();

  cookieStore.set(ADMIN_SESSION_COOKIE, token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "strict",
    path: "/",
    maxAge: ADMIN_SESSION_MAX_AGE_SECONDS,
  });

  return NextResponse.json(
    { success: true },
    { headers: { "Cache-Control": "no-store" } }
  );
}