import { NextResponse } from "next/server";

import { getCurrentAdmin } from "@/lib/admin-auth";
import { adminCreateSchema, type AdminUser } from "@/lib/admin-types";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

export async function GET() {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  }

  const supabaseAdmin = getSupabaseAdmin();
  const { data, error } = await supabaseAdmin
    .from("admin_users")
    .select(
      "id, email, display_name, role, is_active, last_login_at, created_at"
    )
    .order("created_at");

  if (error) {
    return NextResponse.json(
      { error: "Unable to load administrators." },
      { status: 500 }
    );
  }

  return NextResponse.json({ users: data as AdminUser[] });
}

export async function POST(request: Request) {
  const admin = await getCurrentAdmin("owner");
  if (!admin) {
    return NextResponse.json({ error: "Owner access required." }, { status: 403 });
  }

  const result = adminCreateSchema.safeParse(
    await request.json().catch(() => null)
  );
  if (!result.success) {
    return NextResponse.json(
      { error: "Check the name, email, password, and role." },
      { status: 400 }
    );
  }

  const supabaseAdmin = getSupabaseAdmin();
  const { data: authData, error: authError } =
    await supabaseAdmin.auth.admin.createUser({
      email: result.data.email,
      password: result.data.password,
      email_confirm: true,
    });

  if (authError || !authData.user) {
    return NextResponse.json(
      { error: authError?.message ?? "Unable to create administrator." },
      { status: 400 }
    );
  }

  const { data, error } = await supabaseAdmin
    .from("admin_users")
    .insert({
      id: authData.user.id,
      email: result.data.email,
      display_name: result.data.display_name,
      role: result.data.role,
    })
    .select(
      "id, email, display_name, role, is_active, last_login_at, created_at"
    )
    .single();

  if (error) {
    await supabaseAdmin.auth.admin.deleteUser(authData.user.id);
    return NextResponse.json(
      { error: "Unable to create administrator profile." },
      { status: 500 }
    );
  }

  return NextResponse.json({ user: data as AdminUser }, { status: 201 });
}
