import { NextResponse } from "next/server";

import { getCurrentAdmin } from "@/lib/admin-auth";
import { leadPatchSchema, type LeadRecord } from "@/lib/admin-types";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin("operator");
  if (!admin) {
    return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  }

  const result = leadPatchSchema.safeParse(
    await request.json().catch(() => null)
  );
  if (!result.success) {
    return NextResponse.json(
      { error: "Please check the submitted changes." },
      { status: 400 }
    );
  }

  const { id } = await params;
  const supabaseAdmin = getSupabaseAdmin();
  const { data: existing, error: readError } = await supabaseAdmin
    .from("leads")
    .select("*")
    .eq("id", id)
    .maybeSingle();

  if (readError || !existing) {
    return NextResponse.json({ error: "Lead not found." }, { status: 404 });
  }

  const changes: Record<string, { from: unknown; to: unknown }> = {};
  for (const [field, value] of Object.entries(result.data)) {
    if (existing[field] !== value) {
      changes[field] = { from: existing[field], to: value };
    }
  }

  if (Object.keys(changes).length === 0) {
    return NextResponse.json({ lead: existing as LeadRecord });
  }

  const { data: lead, error: updateError } = await supabaseAdmin
    .from("leads")
    .update(result.data)
    .eq("id", id)
    .select("*")
    .single();

  if (updateError) {
    console.error("LEAD UPDATE ERROR:", updateError);
    return NextResponse.json({ error: "Unable to update lead." }, { status: 500 });
  }

  await supabaseAdmin.from("lead_audit_events").insert({
    lead_id: id,
    actor_admin_id: admin.id,
    action: "lead_updated",
    changes,
  });

  return NextResponse.json({ lead: lead as LeadRecord });
}
