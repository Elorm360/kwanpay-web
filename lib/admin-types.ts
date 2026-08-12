import { z } from "zod";

export const ADMIN_ROLES = ["viewer", "operator", "admin", "owner"] as const;
export const LEAD_STATUSES = [
  "new",
  "contacted",
  "qualified",
  "nurture",
  "converted",
  "closed_lost",
] as const;
export const LEAD_PRIORITIES = ["low", "normal", "high"] as const;
export const LEAD_SOURCES = ["waitlist", "demo"] as const;

export type AdminRole = (typeof ADMIN_ROLES)[number];
export type LeadStatus = (typeof LEAD_STATUSES)[number];
export type LeadPriority = (typeof LEAD_PRIORITIES)[number];
export type LeadSource = (typeof LEAD_SOURCES)[number];

export type AdminUser = {
  id: string;
  email: string;
  display_name: string;
  role: AdminRole;
  is_active: boolean;
  last_login_at: string | null;
  created_at: string;
};

export type LeadRecord = {
  id: string;
  email: string;
  full_name: string;
  country: string;
  audience_role: string;
  sources: LeadSource[];
  company: string | null;
  message: string | null;
  status: LeadStatus;
  priority: LeadPriority;
  assigned_admin_id: string | null;
  internal_notes: string | null;
  follow_up_at: string | null;
  created_at: string;
  updated_at: string;
};

export type LeadAuditEvent = {
  id: number;
  lead_id: string;
  actor_admin_id: string | null;
  action: string;
  changes: Record<string, { from: unknown; to: unknown }> | Record<string, unknown>;
  created_at: string;
};

export const leadPatchSchema = z
  .object({
    status: z.enum(LEAD_STATUSES).optional(),
    priority: z.enum(LEAD_PRIORITIES).optional(),
    assigned_admin_id: z.string().uuid().nullable().optional(),
    internal_notes: z.string().trim().max(5000).nullable().optional(),
    follow_up_at: z.string().datetime().nullable().optional(),
  })
  .strict()
  .refine((value) => Object.keys(value).length > 0, {
    message: "At least one field is required.",
  });

export const adminCreateSchema = z.object({
  email: z.string().trim().email().transform((value) => value.toLowerCase()),
  password: z.string().min(12).max(256),
  display_name: z.string().trim().min(2).max(100),
  role: z.enum(ADMIN_ROLES),
});

export const adminUpdateSchema = z
  .object({
    role: z.enum(ADMIN_ROLES).optional(),
    is_active: z.boolean().optional(),
    display_name: z.string().trim().min(2).max(100).optional(),
  })
  .strict()
  .refine((value) => Object.keys(value).length > 0);

export function hasAdminRole(current: AdminRole, minimum: AdminRole) {
  return ADMIN_ROLES.indexOf(current) >= ADMIN_ROLES.indexOf(minimum);
}
