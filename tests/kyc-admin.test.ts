import { describe, expect, it } from "vitest";

import { csvCell } from "../lib/csv";
import {
  KYC_REJECTION_REASONS,
  kycReviewSchema,
  maskDocumentNumber,
} from "../lib/kyc-admin";

describe("kycReviewSchema", () => {
  it("accepts an approval without a reason", () => {
    expect(kycReviewSchema.safeParse({ approve: true }).success).toBe(true);
  });

  it("requires a reason to reject", () => {
    expect(kycReviewSchema.safeParse({ approve: false }).success).toBe(false);
    expect(
      kycReviewSchema.safeParse({ approve: false, reason: "   " }).success
    ).toBe(false);
    expect(
      kycReviewSchema.safeParse({
        approve: false,
        reason: KYC_REJECTION_REASONS[0],
      }).success
    ).toBe(true);
  });

  it("rejects overlong reasons and wrong types", () => {
    expect(
      kycReviewSchema.safeParse({ approve: false, reason: "x".repeat(301) })
        .success
    ).toBe(false);
    expect(kycReviewSchema.safeParse({ approve: "yes" }).success).toBe(false);
  });
});

describe("maskDocumentNumber", () => {
  it("keeps only the last four characters", () => {
    expect(maskDocumentNumber("GHA-123456789-0")).toBe("•••• 89-0");
    expect(maskDocumentNumber("AB1")).toBe("••••");
  });
});

describe("csvCell", () => {
  it("quotes and escapes", () => {
    expect(csvCell('say "hi"')).toBe('"say ""hi"""');
    expect(csvCell(null)).toBe('""');
  });

  it("neutralises spreadsheet formulas", () => {
    expect(csvCell("=HYPERLINK(\"http://x\")")).toBe(
      '"\'=HYPERLINK(""http://x"")"'
    );
    expect(csvCell("+233 20 000 0000")).toBe('"\'+233 20 000 0000"');
    expect(csvCell("@cmd")).toBe('"\'@cmd"');
    expect(csvCell("Ama Mensah")).toBe('"Ama Mensah"');
  });
});
