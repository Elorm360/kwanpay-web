import type { AdminRole } from "./admin-types";

const encoder = new TextEncoder();

export const ADMIN_SESSION_COOKIE = "admin-session";
export const ADMIN_SESSION_MAX_AGE_SECONDS = 60 * 60 * 24;

export type AdminSession = {
  adminId: string;
  email: string;
  displayName: string;
  role: AdminRole;
  expiresAt: number;
};

function bytesToBase64Url(bytes: Uint8Array) {
  let binary = "";

  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }

  return btoa(binary)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
}

function stringToBase64Url(value: string) {
  return bytesToBase64Url(encoder.encode(value));
}

function base64UrlToString(value: string) {
  const base64 = value.replace(/-/g, "+").replace(/_/g, "/");
  const padded = base64.padEnd(Math.ceil(base64.length / 4) * 4, "=");
  const bytes = Uint8Array.from(atob(padded), (character) =>
    character.charCodeAt(0)
  );

  return new TextDecoder().decode(bytes);
}

async function sign(value: string, secret: string) {
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const signature = await crypto.subtle.sign("HMAC", key, encoder.encode(value));

  return bytesToBase64Url(new Uint8Array(signature));
}

function safeEqual(left: string, right: string) {
  if (left.length !== right.length) return false;

  let difference = 0;
  for (let index = 0; index < left.length; index += 1) {
    difference |= left.charCodeAt(index) ^ right.charCodeAt(index);
  }

  return difference === 0;
}

export async function createAdminSessionToken(
  secret: string,
  admin: Omit<AdminSession, "expiresAt">,
  now = Date.now()
) {
  const payload = stringToBase64Url(
    JSON.stringify({
      ...admin,
      expiresAt: now + ADMIN_SESSION_MAX_AGE_SECONDS * 1000,
    })
  );
  const signature = await sign(payload, secret);

  return `${payload}.${signature}`;
}

export async function verifyAdminSessionToken(
  token: string | undefined,
  secret: string | undefined,
  now = Date.now()
) {
  if (!token || !secret) return null;

  const [payloadValue, suppliedSignature, ...extraParts] = token.split(".");
  if (!payloadValue || !suppliedSignature || extraParts.length > 0) return null;

  const expectedSignature = await sign(payloadValue, secret);
  if (!safeEqual(suppliedSignature, expectedSignature)) return null;

  try {
    const payload = JSON.parse(base64UrlToString(payloadValue)) as AdminSession;

    if (
      !payload.adminId ||
      !payload.email ||
      !payload.displayName ||
      !payload.role ||
      !Number.isFinite(payload.expiresAt) ||
      payload.expiresAt <= now
    ) {
      return null;
    }

    return payload;
  } catch {
    return null;
  }
}
