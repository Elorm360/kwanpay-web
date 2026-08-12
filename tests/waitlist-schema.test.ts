import { describe, expect, it } from "vitest";

import { waitlistRequestSchema } from "../lib/waitlist-schema";

describe("waitlist request validation", () => {
  it("normalizes valid signup data", () => {
    const result = waitlistRequestSchema.parse({
      full_name: "  Ama Mensah  ",
      email: "  AMA@EXAMPLE.COM ",
      country: "  Ghana ",
      role: "Traveler",
    });

    expect(result).toEqual({
      full_name: "Ama Mensah",
      email: "ama@example.com",
      country: "Ghana",
      role: "Traveler",
    });
  });

  it("rejects unknown roles and invalid email addresses", () => {
    expect(
      waitlistRequestSchema.safeParse({
        full_name: "Ama Mensah",
        email: "not-an-email",
        country: "Ghana",
        role: "Unknown",
      }).success
    ).toBe(false);
  });
});
