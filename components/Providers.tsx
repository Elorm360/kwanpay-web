"use client";

import { MotionConfig } from "framer-motion";
import type { ReactNode } from "react";
import ScrollProgress from "@/components/ScrollProgress";

export default function Providers({ children }: { children: ReactNode }) {
  return (
    <MotionConfig reducedMotion="user">
      <ScrollProgress />
      <div className="grain-overlay" aria-hidden="true" />
      {children}
    </MotionConfig>
  );
}
