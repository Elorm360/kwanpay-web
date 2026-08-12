import { NextResponse } from "next/server";

import { leadSubmissionSchema } from "@/lib/lead-schema";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

export async function POST(request: Request) {
  const body = await request.json().catch(() => null);
  const result = leadSubmissionSchema.safeParse(body);

  if (!result.success) {
    return NextResponse.json(
      { success: false, error: "Please check the submitted details." },
      { status: 400 }
    );
  }

  try {
    const supabaseAdmin = getSupabaseAdmin();
    const submission = result.data;
    const { data: existing, error: lookupError } = await supabaseAdmin
      .from("leads")
      .select("*")
      .eq("email", submission.email)
      .maybeSingle();

    if (lookupError) throw lookupError;

    let lead;
    if (existing) {
      const sources = Array.from(
        new Set([...(existing.sources ?? []), submission.source])
      );
      const { data, error } = await supabaseAdmin
        .from("leads")
        .update({
          full_name: submission.full_name,
          country: submission.country,
          audience_role: submission.audience_role,
          sources,
          company:
            submission.source === "demo"
              ? submission.company ?? existing.company
              : existing.company,
          message:
            submission.source === "demo"
              ? submission.message ?? existing.message
              : existing.message,
        })
        .eq("id", existing.id)
        .select("*")
        .single();

      if (error) throw error;
      lead = data;
    } else {
      const { data, error } = await supabaseAdmin
        .from("leads")
        .insert({
          email: submission.email,
          full_name: submission.full_name,
          country: submission.country,
          audience_role: submission.audience_role,
          sources: [submission.source],
          company:
            submission.source === "demo" ? submission.company ?? null : null,
          message:
            submission.source === "demo" ? submission.message ?? null : null,
        })
        .select("*")
        .single();

      if (error) throw error;
      lead = data;
    }

    await supabaseAdmin.from("lead_audit_events").insert({
      lead_id: lead.id,
      actor_admin_id: null,
      action: existing ? "source_added" : "lead_created",
      changes: { source: submission.source },
    });

    return NextResponse.json({ success: true }, { status: 201 });
  } catch (error) {
    console.error("LEAD SUBMISSION ERROR:", error);
    return NextResponse.json(
      { success: false, error: "Unable to save your request right now." },
      { status: 503 }
    );
  }
}
