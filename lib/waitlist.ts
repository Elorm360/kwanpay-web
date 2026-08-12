import type { WaitlistRequestData } from "@/lib/waitlist-schema";

export async function submitWaitlist(data: WaitlistRequestData) {
  const response = await fetch("/api/leads", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      source: "waitlist",
      full_name: data.full_name,
      email: data.email,
      country: data.country,
      audience_role: data.role,
    }),
  });

  if (!response.ok) {
    const result = await response.json().catch(() => null);
    throw new Error(result?.error ?? "Unable to join the waitlist");
  }

  return true;
}
