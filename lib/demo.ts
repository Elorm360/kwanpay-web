import type { USER_TYPES } from "@/lib/constants";

export type DemoRequestData = {
  full_name: string;
  email: string;
  country: string;
  user_type: (typeof USER_TYPES)[number];
  company?: string | null;
  message?: string | null;
};

export async function submitDemo(data: DemoRequestData) {
  const response = await fetch("/api/leads", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      source: "demo",
      full_name: data.full_name,
      email: data.email,
      country: data.country,
      audience_role: data.user_type,
      company: data.company,
      message: data.message,
    }),
  });

  if (!response.ok) {
    const result = await response.json().catch(() => null);
    throw new Error(result?.error ?? "Unable to request a demo");
  }

  return true;
}
