import { z } from "zod";

/**
 * Rules for an admin password. Stricter than the app's: this account can
 * see ID documents and change other people's limits.
 */
export function adminPasswordProblem(password: string, email = "") {
  if (password.length < 12) return "Use at least 12 characters.";
  if (password.length > 128) return "Use 128 characters or fewer.";
  if (!/[A-Za-z]/.test(password) || !/\d/.test(password)) {
    return "Use letters and at least one number.";
  }
  const name = email.split("@")[0]?.toLowerCase() ?? "";
  if (name.length >= 4 && password.toLowerCase().includes(name)) {
    return "Do not include your email name in the password.";
  }
  return null;
}

const email = z
  .string()
  .trim()
  .email()
  .transform((value) => value.toLowerCase());

export const passwordResetRequestSchema = z.object({ email });

export const passwordResetSchema = z
  .object({
    email,
    code: z
      .string()
      .trim()
      .regex(/^\d{6,10}$/, "Enter the code from the email."),
    password: z.string(),
  })
  .superRefine((value, ctx) => {
    const problem = adminPasswordProblem(value.password, value.email);
    if (problem) ctx.addIssue({ code: "custom", path: ["password"], message: problem });
  });
