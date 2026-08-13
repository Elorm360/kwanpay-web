import { NextResponse } from "next/server";

import { getCurrentAdmin } from "@/lib/admin-auth";
import {
  leadArchiveSchema,
  type LeadRecord,
} from "@/lib/admin-types";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin("operator");
  if (!admin) {
    return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  }

  const result = leadArchiveSchema.safeParse(
    await request.json().catch(() => null)
  );
  if (!result.success) {
    return NextResponse.json({ error: "Invalid archive request." }, { status: 400 });
  }

  const { id } = await params;
  const supabaseAdmin = getSupabaseAdmin();
  const { data: existing, error: readError } = await supabaseAdmin
    .from("leads")
    .select("id, archived_at, archived_by_admin_id")
    .eq("id", id)
    .maybeSingle();

  if (readError || !existing) {
    return NextResponse.json({ error: "Lead not found." }, { status: 404 });
  }

  const archivedAt = result.data.archived ? new Date().toISOString() : null;
  const archivedByAdminId = result.data.archived ? admin.id : null;
  const { data: lead, error: updateError } = await supabaseAdmin
    .from("leads")
    .update({
      archived_at: archivedAt,
      archived_by_admin_id: archivedByAdminId,
    })
    .eq("id", id)
    .select("*")
    .single();

  if (updateError) {
    console.error("LEAD ARCHIVE ERROR:", updateError);
    return NextResponse.json(
      { error: result.data.archived ? "Unable to archive lead." : "Unable to restore lead." },
      { status: 500 }
    );
  }

  await supabaseAdmin.from("lead_audit_events").insert({
    lead_id: id,
    actor_admin_id: admin.id,
    action: result.data.archived ? "lead_archived" : "lead_restored",
    changes: {
      archived_at: { from: existing.archived_at, to: archivedAt },
      archived_by_admin_id: {
        from: existing.archived_by_admin_id,
        to: archivedByAdminId,
      },
    },
  });

  return NextResponse.json({ lead: lead as LeadRecord });
}
