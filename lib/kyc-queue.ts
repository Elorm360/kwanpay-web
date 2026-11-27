import "server-only";

import type { SupabaseClient } from "@supabase/supabase-js";

import type { KycStatus, KycSubmission } from "./kyc-admin";

type SubmissionRow = {
  id: string;
  user_id: string;
  target_tier: number;
  document_type: string;
  document_number: string;
  back_path: string | null;
  status: KycStatus;
  rejection_reason: string | null;
  reviewed_by: string | null;
  reviewed_at: string | null;
  created_at: string;
};

const COLUMNS =
  "id, user_id, target_tier, document_type, document_number, back_path, status, rejection_reason, reviewed_by, reviewed_at, created_at";

/**
 * Pending submissions oldest first (fair queue), then the most recent
 * decisions, each joined with the person's name, email and current tier.
 * Storage paths stay on the server; photos are fetched as signed links.
 */
export async function loadKycSubmissions(
  supabase: SupabaseClient
): Promise<KycSubmission[]> {
  const [pending, reviewed] = await Promise.all([
    supabase
      .from("kyc_submissions")
      .select(COLUMNS)
      .eq("status", "pending")
      .order("created_at", { ascending: true })
      .limit(500),
    supabase
      .from("kyc_submissions")
      .select(COLUMNS)
      .neq("status", "pending")
      .order("reviewed_at", { ascending: false })
      .limit(200),
  ]);
  if (pending.error) throw pending.error;
  if (reviewed.error) throw reviewed.error;

  const rows = [
    ...(pending.data as SubmissionRow[]),
    ...(reviewed.data as SubmissionRow[]),
  ];
  const userIds = [...new Set(rows.map((row) => row.user_id))];
  if (userIds.length === 0) return [];

  const [profiles, tiers] = await Promise.all([
    supabase.from("profiles").select("id, full_name, email").in("id", userIds),
    supabase.from("user_kyc").select("user_id, tier").in("user_id", userIds),
  ]);
  if (profiles.error) throw profiles.error;
  if (tiers.error) throw tiers.error;

  const profileById = new Map(
    (profiles.data ?? []).map((p) => [p.id as string, p])
  );
  const tierById = new Map(
    (tiers.data ?? []).map((t) => [t.user_id as string, t.tier as number])
  );

  return rows.map(({ back_path, ...row }) => ({
    ...row,
    has_back: Boolean(back_path),
    full_name: (profileById.get(row.user_id)?.full_name as string) ?? null,
    email: (profileById.get(row.user_id)?.email as string) ?? null,
    current_tier: tierById.get(row.user_id) ?? 0,
  }));
}
