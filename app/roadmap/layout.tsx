import type { Metadata } from "next";

import { pageMetadata } from "@/lib/page-metadata";

export const metadata: Metadata = pageMetadata({
  title: "Product Roadmap",
  description:
    "Follow KwanPay's public roadmap: from the travel wallet and Stellar settlement to merchant payments and public launch across Africa.",
  path: "/roadmap",
});

export default function RoadmapLayout({ children }: { children: React.ReactNode }) {
  return children;
}
