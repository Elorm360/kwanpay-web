import "server-only";

import { cookies } from "next/headers";

import {
  ADMIN_SESSION_COOKIE,
  verifyAdminSessionToken,
} from "./admin-session";
import {
  hasAdminRole,
  type AdminRole,
  type AdminUser,
} from "./admin-types";
import { getSupabaseAdmin } from "./supabaseAdmin";

export async function getCurrentAdmin(
  minimumRole: AdminRole = "viewer"
): Promise<AdminUser | null> {
  const cookieStore = await cookies();
  const session = await verifyAdminSessionToken(
    cookieStore.get(ADMIN_SESSION_COOKIE)?.value,
    process.env.ADMIN_SESSION_SECRET
  );

  if (!session) return null;

  const supabaseAdmin = getSupabaseAdmin();
  const { data, error } = await supabaseAdmin
    .from("admin_users")
    .select(
      "id, email, display_name, role, is_active, last_login_at, created_at"
    )
    .eq("id", session.adminId)
    .maybeSingle();

  if (error || !data || !data.is_active) return null;

  const admin = data as AdminUser;
  return hasAdminRole(admin.role, minimumRole) ? admin : null;
}
