import { describe, expect, it } from "vitest";

import {
  adminPasswordProblem,
  passwordResetRequestSchema,
  passwordResetSchema,
} from "../lib/admin-password";

describe("adminPasswordProblem", () => {
  it("requires length, letters and a number", () => {
    expect(adminPasswordProblem("short1")).toMatch(/12/);
    expect(adminPasswordProblem("onlylettershere")).toMatch(/number/);
    expect(adminPasswordProblem("123456789012")).toMatch(/number/);
    expect(adminPasswordProblem("harmattan-route-42")).toBeNull();
  });

  it("refuses the email name inside the password", () => {
    expect(
      adminPasswordProblem("kwesiadmin2026!", "kwesi@example.com")
    ).toMatch(/email/);
  });
});

describe("password reset schemas", () => {
  it("normalises the email", () => {
    const parsed = passwordResetRequestSchema.parse({ email: " Admin@X.com " });
    expect(parsed.email).toBe("admin@x.com");
  });

  it("checks the code and password", () => {
    const base = { email: "a@x.com", password: "harmattan-route-42" };
    expect(passwordResetSchema.safeParse({ ...base, code: "123456" }).success).toBe(true);
    expect(passwordResetSchema.safeParse({ ...base, code: "12ab56" }).success).toBe(false);
    expect(
      passwordResetSchema.safeParse({ ...base, code: "123456", password: "weak" }).success
    ).toBe(false);
  });
});
