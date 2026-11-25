"use client";

import { MotionConfig } from "framer-motion";
import { useEffect, type ReactNode } from "react";
import ScrollProgress from "@/components/ScrollProgress";

export default function Providers({ children }: { children: ReactNode }) {
  // Animated sections are server-rendered in their hidden state. Until this
  // runs, globals.css forces them visible so content never depends on
  // JavaScript arriving (slow 3G, low-end phones). Once hydrated, animations
  // take over for anything still below the fold.
  useEffect(() => {
    document.documentElement.dataset.motionReady = "true";
  }, []);

  return (
    <MotionConfig reducedMotion="user">
      <ScrollProgress />
      {children}
    </MotionConfig>
  );
}
