/**
 * Best-effort client IP for rate limiting.
 *
 * The first entry of `x-forwarded-for` is supplied by the client and can be
 * spoofed to dodge per-IP limits. Prefer the platform-set `x-real-ip`
 * (Vercel, most reverse proxies), then the last `x-forwarded-for` hop, which
 * is appended by the proxy closest to us.
 */
export function getClientIp(headers: Headers) {
  const realIp = headers.get("x-real-ip")?.trim();
  if (realIp) return realIp;

  const forwarded = headers
    .get("x-forwarded-for")
    ?.split(",")
    .map((part) => part.trim())
    .filter(Boolean);

  return forwarded?.at(-1) ?? "unknown";
}
