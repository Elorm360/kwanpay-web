import type { Metadata } from "next";

import { pageMetadata } from "@/lib/page-metadata";

export const metadata: Metadata = pageMetadata({
  title: "Request a Demo",
  description:
    "See KwanPay in action. Book a walkthrough of Africa's travel wallet for travelers, tourism businesses and partners.",
  path: "/demo",
});

export default function DemoLayout({ children }: { children: React.ReactNode }) {
  return children;
}
