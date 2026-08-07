"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { ArrowLeft, ArrowRight } from "lucide-react";
import { BRAND } from "@/lib/brand";

type SuccessCardProps = {
  emoji?: string;
  title: string;
  messageLines: string[];
  primaryLabel: string;
  primaryHref: string;
  icon?: "forward" | "home";
};

export default function SuccessCard({
  emoji = "🎉",
  title,
  messageLines,
  primaryLabel,
  primaryHref,
  icon = "forward",
}: SuccessCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.96 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.5 }}
      className="text-center py-10"
    >
      <div
        className="w-20 h-20 rounded-full mx-auto flex items-center justify-center text-4xl"
        style={{ background: "rgba(217,142,59,0.12)" }}
      >
        {emoji}
      </div>

      <h2 className="mt-6 text-3xl font-black" style={{ color: BRAND.indigo }}>
        {title}
      </h2>

      {messageLines.map((line, idx) => (
        <p
          key={idx}
          className={
            (idx === 0 ? "mt-4 " : "mt-2 ") +
            "text-slate-600 leading-7 max-w-sm mx-auto"
          }
        >
          {line}
        </p>
      ))}

      <Link href={primaryHref}>
        <button
          className="group mt-8 inline-flex items-center gap-2 rounded-full px-8 py-4 font-semibold text-white transition-all duration-300 hover:-translate-y-0.5 hover:shadow-2xl"
          style={{
            background: "linear-gradient(135deg, #D98E3B, #B56F28)",
            boxShadow: "0 10px 30px -8px rgba(217,142,59,.6)",
          }}
        >
          {primaryLabel}
          {icon === "forward" ? (
            <ArrowRight
              size={18}
              className="transition-transform group-hover:translate-x-0.5"
            />
          ) : (
            <ArrowLeft size={18} />
          )}
        </button>
      </Link>
    </motion.div>
  );
}

