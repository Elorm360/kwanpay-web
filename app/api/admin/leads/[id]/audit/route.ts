import { NextResponse } from "next/server";

import { getCurrentAdmin } from "@/lib/admin-auth";
import type { LeadAuditEvent } from "@/lib/admin-types";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

export async function GET(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  }

  const { id } = await params;
  const supabaseAdmin = getSupabaseAdmin();
  const { data, error } = await supabaseAdmin
    .from("lead_audit_events")
    .select("*")
    .eq("lead_id", id)
    .order("created_at", { ascending: false })
    .limit(100);

  if (error) {
    return NextResponse.json(
      { error: "Unable to load activity." },
      { status: 500 }
    );
  }

  return NextResponse.json({ events: data as LeadAuditEvent[] });
}
