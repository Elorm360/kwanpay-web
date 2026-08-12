import { z } from "zod";

import { USER_TYPES } from "./constants";

export const waitlistRequestSchema = z.object({
  full_name: z.string().trim().min(2).max(100),
  email: z.string().trim().email().max(254).transform((value) => value.toLowerCase()),
  country: z.string().trim().min(2).max(100),
  role: z.enum(USER_TYPES),
});

export type WaitlistRequestData = z.infer<typeof waitlistRequestSchema>;

export type WaitlistRecord = WaitlistRequestData & {
  id: string | number;
  created_at?: string;
};
