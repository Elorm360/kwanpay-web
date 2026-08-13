import { NextResponse } from "next/server";

import { getCurrentAdmin } from "@/lib/admin-auth";
import { adminUpdateSchema, type AdminUser } from "@/lib/admin-types";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin("owner");
  if (!admin) {
    return NextResponse.json({ error: "Owner access required." }, { status: 403 });
  }

  const result = adminUpdateSchema.safeParse(
    await request.json().catch(() => null)
  );
  if (!result.success) {
    return NextResponse.json({ error: "Invalid changes." }, { status: 400 });
  }

  const { id } = await params;
  if (id === admin.id && result.data.is_active === false) {
    return NextResponse.json(
      { error: "You cannot deactivate your own account." },
      { status: 400 }
    );
  }

  const supabaseAdmin = getSupabaseAdmin();
  const { data: target } = await supabaseAdmin
    .from("admin_users")
    .select("role, is_active")
    .eq("id", id)
    .maybeSingle();

  const removesOwner =
    target?.role === "owner" &&
    target.is_active &&
    (result.data.role !== undefined && result.data.role !== "owner" ||
      result.data.is_active === false);

  if (removesOwner) {
    const { count } = await supabaseAdmin
      .from("admin_users")
      .select("id", { count: "exact", head: true })
      .eq("role", "owner")
      .eq("is_active", true);

    if ((count ?? 0) <= 1) {
      return NextResponse.json(
        { error: "At least one active owner is required." },
        { status: 400 }
      );
    }
  }

  const { data, error } = await supabaseAdmin
    .from("admin_users")
    .update(result.data)
    .eq("id", id)
    .select(
      "id, email, display_name, role, is_active, last_login_at, created_at"
    )
    .single();

  if (error) {
    return NextResponse.json(
      { error: "Unable to update administrator." },
      { status: 500 }
    );
  }

  return NextResponse.json({ user: data as AdminUser });
}

export async function DELETE(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin("owner");
  if (!admin) {
    return NextResponse.json({ error: "Owner access required." }, { status: 403 });
  }

  const { id } = await params;
  if (id === admin.id) {
    return NextResponse.json(
      { error: "You cannot delete your own account." },
      { status: 400 }
    );
  }

  const supabaseAdmin = getSupabaseAdmin();
  const { data: target, error: readError } = await supabaseAdmin
    .from("admin_users")
    .select("id, role, is_active")
    .eq("id", id)
    .maybeSingle();

  if (readError || !target) {
    return NextResponse.json(
      { error: "Administrator not found." },
      { status: 404 }
    );
  }

  if (target.role === "owner" && target.is_active) {
    const { count } = await supabaseAdmin
      .from("admin_users")
      .select("id", { count: "exact", head: true })
      .eq("role", "owner")
      .eq("is_active", true);

    if ((count ?? 0) <= 1) {
      return NextResponse.json(
        { error: "At least one active owner is required." },
        { status: 400 }
      );
    }
  }

  const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(id);
  if (deleteError) {
    return NextResponse.json(
      { error: "Unable to delete administrator." },
      { status: 500 }
    );
  }

  const { error: auditError } = await supabaseAdmin
    .from("member_deletion_events")
    .insert({
      entity_type: "admin_user",
      entity_id: id,
      actor_admin_id: admin.id,
    });
  if (auditError) {
    console.error("ADMIN DELETE AUDIT ERROR:", auditError);
  }

  return NextResponse.json({ deleted: true });
}
