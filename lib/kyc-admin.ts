import { z } from "zod";

export const KYC_STATUSES = ["pending", "approved", "rejected"] as const;
export type KycStatus = (typeof KYC_STATUSES)[number];

export const KYC_DOCUMENT_LABELS: Record<string, string> = {
  ghana_card: "Ghana Card",
  passport: "Passport",
};

/** Reasons a reviewer can pick; the text goes to the user as written. */
export const KYC_REJECTION_REASONS = [
  "The photo is blurry or part of the document is cut off.",
  "The name on the ID does not match your KwanPay profile.",
  "The document has expired.",
  "The selfie does not match the photo on the ID.",
  "The number you entered does not match the document.",
] as const;

export type KycSubmission = {
  id: string;
  user_id: string;
  target_tier: number;
  document_type: string;
  document_number: string;
  status: KycStatus;
  rejection_reason: string | null;
  reviewed_by: string | null;
  reviewed_at: string | null;
  created_at: string;
  has_back: boolean;
  full_name: string | null;
  email: string | null;
  current_tier: number;
};

export type KycPhotoLinks = {
  front: string | null;
  back: string | null;
  selfie: string | null;
};

export const kycReviewSchema = z
  .object({
    approve: z.boolean(),
    reason: z.string().trim().max(300).optional(),
  })
  .refine((value) => value.approve || (value.reason ?? "").length >= 5, {
    message: "Give the user a reason.",
    path: ["reason"],
  });

/** Shows only the end of an ID number in lists. */
export function maskDocumentNumber(value: string) {
  const clean = value.trim();
  if (clean.length <= 4) return "••••";
  return `•••• ${clean.slice(-4)}`;
}

/** Signed links to ID photos live this long. */
export const KYC_PHOTO_LINK_SECONDS = 300;
