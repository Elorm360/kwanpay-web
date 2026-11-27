import { NextResponse } from "next/server";

import { getClientIp } from "@/lib/client-ip";
import { leadSubmissionSchema } from "@/lib/lead-schema";
import { createRateLimiter } from "@/lib/rate-limit";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

const limiter = createRateLimiter({ limit: 8, windowMs: 10 * 60 * 1000 });

function fillBlank<T>(current: T | null | undefined, incoming: T | null | undefined) {
  return current ?? incoming ?? null;
}

export async function POST(request: Request) {
  const rate = limiter.hit(getClientIp(request.headers));
  if (rate.limited) {
    return NextResponse.json(
      { success: false, error: "Too many submissions. Please try again shortly." },
      { status: 429, headers: { "Retry-After": String(rate.retryAfterSeconds) } }
    );
  }

  const body = await request.json().catch(() => null);

  // Honeypot: real visitors never see or fill the `website` field. Pretend
  // success so bots get no signal.
  if (body && typeof body === "object" && "website" in body && body.website) {
    return NextResponse.json({ success: true }, { status: 201 });
  }

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
    const company = submission.source === "demo" ? submission.company || null : null;
    const message = submission.source === "demo" ? submission.message || null : null;

    const { data: existing, error: lookupError } = await supabaseAdmin
      .from("leads")
      .select("*")
      .eq("email", submission.email)
      .maybeSingle();

    if (lookupError) throw lookupError;

    let leadId: string;
    if (existing) {
      // This endpoint is unauthenticated, so anyone can submit any email.
      // Never overwrite details an existing lead already has: only add the
      // new source and fill blanks. The full submission is kept in the audit
      // trail so the team can see what was sent.
      const sources = Array.from(
        new Set([...(existing.sources ?? []), submission.source])
      );
      const { error } = await supabaseAdmin
        .from("leads")
        .update({
          sources,
          full_name: fillBlank(existing.full_name, submission.full_name),
          country: fillBlank(existing.country, submission.country),
          audience_role: fillBlank(existing.audience_role, submission.audience_role),
          company: fillBlank(existing.company, company),
          message: fillBlank(existing.message, message),
        })
        .eq("id", existing.id);

      if (error) throw error;
      leadId = existing.id;
    } else {
      const { data, error } = await supabaseAdmin
        .from("leads")
        .insert({
          email: submission.email,
          full_name: submission.full_name,
          country: submission.country,
          audience_role: submission.audience_role,
          sources: [submission.source],
          company,
          message,
        })
        .select("id")
        .single();

      if (error) throw error;
      leadId = data.id;
    }

    const { error: auditError } = await supabaseAdmin
      .from("lead_audit_events")
      .insert({
        lead_id: leadId,
        actor_admin_id: null,
        action: existing ? "source_added" : "lead_created",
        changes: {
          source: submission.source,
          ...(existing
            ? {
                submitted: {
                  full_name: submission.full_name,
                  country: submission.country,
                  audience_role: submission.audience_role,
                  company,
                  message,
                },
              }
            : {}),
        },
      });

    if (auditError) console.error("LEAD AUDIT ERROR:", auditError);

    return NextResponse.json({ success: true }, { status: 201 });
  } catch (error) {
    console.error("LEAD SUBMISSION ERROR:", error);
    return NextResponse.json(
      { success: false, error: "Unable to save your request right now." },
      { status: 503 }
    );
  }
}
