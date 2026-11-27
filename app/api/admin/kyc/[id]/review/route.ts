import { NextResponse } from "next/server";

import { getCurrentAdmin } from "@/lib/admin-auth";
import { kycReviewSchema } from "@/lib/kyc-admin";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

const UUID = /^[0-9a-f-]{36}$/i;

/**
 * Approve or reject one submission. The database function checks the
 * reviewer is an active operator or above, that the submission is still
 * pending, records who decided and when, and raises the user's tier.
 */
export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin("operator");
  if (!admin) {
    return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  }

  const { id } = await params;
  if (!UUID.test(id)) {
    return NextResponse.json({ error: "Submission not found." }, { status: 404 });
  }

  const result = kycReviewSchema.safeParse(
    await request.json().catch(() => null)
  );
  if (!result.success) {
    return NextResponse.json(
      { error: result.error.issues[0]?.message ?? "Invalid review." },
      { status: 400 }
    );
  }

  const { data, error } = await getSupabaseAdmin().rpc("admin_review_kyc", {
    p_admin_id: admin.id,
    p_submission_id: id,
    p_approve: result.data.approve,
    p_reason: result.data.approve ? null : result.data.reason,
  });

  if (error) {
    // P0001 messages come from our own checks and are safe to show.
    const known = error.code === "P0001";
    if (!known) console.error("KYC REVIEW ERROR:", error);
    return NextResponse.json(
      { error: known ? error.message : "Unable to save the decision." },
      { status: known ? 409 : 500 }
    );
  }

  return NextResponse.json({
    submission: {
      id: data.id,
      status: data.status,
      rejection_reason: data.rejection_reason,
      reviewed_by: data.reviewed_by,
      reviewed_at: data.reviewed_at,
    },
  });
}
