const WINDOW_MS = 15 * 60 * 1000;
const MAX_FAILURES = 5;

type Attempt = {
  count: number;
  resetAt: number;
};

const attempts = new Map<string, Attempt>();

export function getLoginRateLimit(key: string, now = Date.now()) {
  const attempt = attempts.get(key);

  if (!attempt || attempt.resetAt <= now) {
    attempts.delete(key);
    return { limited: false, retryAfterSeconds: 0 };
  }

  return {
    limited: attempt.count >= MAX_FAILURES,
    retryAfterSeconds: Math.ceil((attempt.resetAt - now) / 1000),
  };
}

export function recordFailedLogin(key: string, now = Date.now()) {
  const current = attempts.get(key);

  if (!current || current.resetAt <= now) {
    attempts.set(key, { count: 1, resetAt: now + WINDOW_MS });
    return;
  }

  attempts.set(key, { ...current, count: current.count + 1 });
}

export function clearLoginFailures(key: string) {
  attempts.delete(key);
}
