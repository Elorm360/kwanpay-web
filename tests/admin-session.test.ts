import { describe, expect, it } from "vitest";

import {
  ADMIN_SESSION_MAX_AGE_SECONDS,
  createAdminSessionToken,
  verifyAdminSessionToken,
} from "../lib/admin-session";

const SECRET = "test-secret-that-is-long-enough-for-session-signing";
const NOW = 1_700_000_000_000;
const ADMIN = {
  adminId: "241e68ce-9973-4a29-90c2-86bca1665747",
  email: "owner@kwanpay.com",
  displayName: "KwanPay Owner",
  role: "owner" as const,
};

describe("admin session tokens", () => {
  it("accepts a valid signed token", async () => {
    const token = await createAdminSessionToken(SECRET, ADMIN, NOW);

    const session = await verifyAdminSessionToken(token, SECRET, NOW + 1_000);
    expect(session).toMatchObject(ADMIN);
  });

  it("rejects tampered and wrongly signed tokens", async () => {
    const token = await createAdminSessionToken(SECRET, ADMIN, NOW);

    await expect(
      verifyAdminSessionToken(`${token}tampered`, SECRET, NOW)
    ).resolves.toBeNull();
    await expect(
      verifyAdminSessionToken(token, "different-secret", NOW)
    ).resolves.toBeNull();
  });

  it("rejects expired tokens", async () => {
    const token = await createAdminSessionToken(SECRET, ADMIN, NOW);
    const afterExpiry =
      NOW + ADMIN_SESSION_MAX_AGE_SECONDS * 1000 + 1;

    await expect(
      verifyAdminSessionToken(token, SECRET, afterExpiry)
    ).resolves.toBeNull();
  });
});
