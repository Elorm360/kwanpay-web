"use client";

import { motion } from "framer-motion";
import type { ReactNode } from "react";
import { BRAND } from "@/lib/brand";

export default function HomeMotionWrapper({
  children,
}: {
  children: ReactNode;
}) {
  return (
    <motion.main
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.8, ease: "easeOut" }}
      className="min-h-screen overflow-hidden text-slate-900"
      style={{ background: BRAND.paper }}
    >
      {children}
    </motion.main>
  );
}

