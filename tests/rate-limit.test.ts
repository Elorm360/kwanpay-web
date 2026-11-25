import { describe, expect, it } from "vitest";

import { getClientIp } from "../lib/client-ip";
import { createRateLimiter } from "../lib/rate-limit";

describe("createRateLimiter", () => {
  it("allows hits up to the limit, then blocks until the window resets", () => {
    const limiter = createRateLimiter({ limit: 2, windowMs: 1000 });

    expect(limiter.hit("a", 0).limited).toBe(false);
    expect(limiter.hit("a", 10).limited).toBe(false);
    const blocked = limiter.hit("a", 20);
    expect(blocked.limited).toBe(true);
    expect(blocked.retryAfterSeconds).toBe(1);

    expect(limiter.hit("b", 20).limited).toBe(false);
    expect(limiter.hit("a", 1000).limited).toBe(false);
  });
});

describe("getClientIp", () => {
  it("prefers the platform-set x-real-ip header", () => {
    const headers = new Headers({
      "x-real-ip": "203.0.113.9",
      "x-forwarded-for": "1.1.1.1, 203.0.113.9",
    });
    expect(getClientIp(headers)).toBe("203.0.113.9");
  });

  it("ignores the spoofable first x-forwarded-for hop", () => {
    const headers = new Headers({ "x-forwarded-for": "6.6.6.6, 198.51.100.4" });
    expect(getClientIp(headers)).toBe("198.51.100.4");
  });

  it("falls back to unknown", () => {
    expect(getClientIp(new Headers())).toBe("unknown");
  });
});
