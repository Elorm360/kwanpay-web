type Bucket = {
  count: number;
  resetAt: number;
};

/**
 * Fixed-window, in-memory rate limiter.
 *
 * State lives per server instance, so on serverless hosting it slows abuse
 * rather than guaranteeing a global cap. Swap for a shared store (Upstash,
 * Supabase) if a hard limit is ever needed.
 */
export function createRateLimiter({
  limit,
  windowMs,
}: {
  limit: number;
  windowMs: number;
}) {
  const buckets = new Map<string, Bucket>();

  function prune(now: number) {
    if (buckets.size < 5000) return;
    for (const [key, bucket] of buckets) {
      if (bucket.resetAt <= now) buckets.delete(key);
    }
  }

  return {
    /** Records one hit and reports whether the caller is over the limit. */
    hit(key: string, now = Date.now()) {
      prune(now);
      const current = buckets.get(key);

      if (!current || current.resetAt <= now) {
        buckets.set(key, { count: 1, resetAt: now + windowMs });
        return { limited: false, retryAfterSeconds: 0 };
      }

      current.count += 1;
      return {
        limited: current.count > limit,
        retryAfterSeconds: Math.ceil((current.resetAt - now) / 1000),
      };
    },
  };
}
