"use client";

import { motion, useScroll, useSpring } from "framer-motion";
import { BRAND } from "@/lib/brand";

export default function ScrollProgress() {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, {
    stiffness: 260,
    damping: 40,
    mass: 0.3,
  });

  return (
    <motion.div
      style={{ scaleX, background: BRAND.amber }}
      className="fixed top-0 left-0 right-0 h-[3px] origin-left z-[60]"
    />
  );
}
