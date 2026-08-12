import { z } from "zod";

import { USER_TYPES } from "./constants";

const baseLeadSchema = z.object({
  full_name: z.string().trim().min(2).max(100),
  email: z.string().trim().email().max(254).transform((value) => value.toLowerCase()),
  country: z.string().trim().min(2).max(100),
});

export const leadSubmissionSchema = z.discriminatedUnion("source", [
  baseLeadSchema.extend({
    source: z.literal("waitlist"),
    audience_role: z.enum(USER_TYPES),
  }),
  baseLeadSchema.extend({
    source: z.literal("demo"),
    audience_role: z.enum(USER_TYPES),
    company: z.string().trim().max(150).nullable().optional(),
    message: z.string().trim().max(2000).nullable().optional(),
  }),
]);

export type LeadSubmission = z.infer<typeof leadSubmissionSchema>;
