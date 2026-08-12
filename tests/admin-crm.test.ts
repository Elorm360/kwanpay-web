import { describe, expect, it } from "vitest";

import {
  hasAdminRole,
  leadPatchSchema,
} from "../lib/admin-types";
import { leadSubmissionSchema } from "../lib/lead-schema";

describe("admin CRM validation", () => {
  it("normalizes public lead submissions", () => {
    const submission = leadSubmissionSchema.parse({
      source: "demo",
      full_name: "  Ama Mensah ",
      email: " AMA@EXAMPLE.COM ",
      country: " Ghana ",
      audience_role: "Tourism Business",
      company: " Kwan Tours ",
    });

    expect(submission.email).toBe("ama@example.com");
    expect(submission.source).toBe("demo");
    if (submission.source === "demo") {
      expect(submission.company).toBe("Kwan Tours");
    }
  });

  it("only accepts operational lead fields", () => {
    expect(
      leadPatchSchema.safeParse({
        status: "qualified",
        priority: "high",
        email: "changed@example.com",
      }).success
    ).toBe(false);
  });

  it("enforces the admin role hierarchy", () => {
    expect(hasAdminRole("owner", "admin")).toBe(true);
    expect(hasAdminRole("operator", "operator")).toBe(true);
    expect(hasAdminRole("viewer", "operator")).toBe(false);
  });
});
