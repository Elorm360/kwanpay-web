import type { Metadata } from "next";

import { pageMetadata } from "@/lib/page-metadata";

export const metadata: Metadata = pageMetadata({
  title: "Join Early Access",
  description:
    "Join the KwanPay early access community and be among the first to pay for travel across Africa with one secure wallet.",
  path: "/waitlist",
});

export default function WaitlistLayout({ children }: { children: React.ReactNode }) {
  return children;
}
