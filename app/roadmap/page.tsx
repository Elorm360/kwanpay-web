"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import {
  ArrowLeft,
  ArrowRight,
  Check,
  Hammer,
  Circle,
  Rocket,
} from "lucide-react";
import { BRAND } from "@/lib/brand";
import { fadeUp, staggerContainer } from "@/lib/motion";

type Status = "done" | "progress" | "todo";

type Phase = {
  phase: string;
  title: string;
  emoji: string;
  status: Status;
  statusLabel: string;
  items: string[];
};

const phases: Phase[] = [
  {
    phase: "Phase 1",
    title: "Foundation",
    emoji: "✅",
    status: "done",
    statusLabel: "Completed",
    items: [
      "Brand Identity",
      "Landing Page",
      "Flutter UI System",
      "Authentication",
      "User Profiles",
      "Dashboard",
      "Wallet Interface",
      "Transaction History",
    ],
  },
  {
    phase: "Phase 2",
    title: "Wallet Experience",
    emoji: "🚧",
    status: "progress",
    statusLabel: "In Progress",
    items: [
      "Add Funds",
      "Withdraw Funds",
      "Wallet Sync",
      "Transaction Refresh",
      "Wallet Balance",
    ],
  },
  {
    phase: "Phase 3",
    title: "Stellar Integration",
    emoji: "⏳",
    status: "todo",
    statusLabel: "Next",
    items: [
      "Stellar Wallet Creation",
      "Stellar USDC",
      "On-chain Transactions",
      "Horizon/RPC Integration",
      "Anchor Support",
    ],
  },
  {
    phase: "Phase 4",
    title: "Merchant Payments",
    emoji: "💳",
    status: "todo",
    statusLabel: "Upcoming",
    items: [
      "Merchant Accounts",
      "QR Payments",
      "Tourism Checkout",
      "Payment Links",
      "Merchant Dashboard",
    ],
  },
  {
    phase: "Phase 5",
    title: "AI Travel Companion",
    emoji: "🤖",
    status: "todo",
    statusLabel: "Upcoming",
    items: [
      "AI Travel Assistant",
      "Smart Budgeting",
      "Travel Recommendations",
      "Spending Insights",
      "Trip Planning",
    ],
  },
  {
    phase: "Phase 6",
    title: "Public Launch",
    emoji: "🚀",
    status: "todo",
    statusLabel: "Upcoming",
    items: [
      "Public Beta",
      "Play Store",
      "App Store",
      "Country Expansion",
      "Tourism Partnerships",
    ],
  },
];

function statusColor(status: Status) {
  if (status === "done") return "#22c55e";
  if (status === "progress") return BRAND.amber;
  return "#94A3B8";
}

function statusBg(status: Status) {
  if (status === "done") return "rgba(34,197,94,0.12)";
  if (status === "progress") return "rgba(217,142,59,0.12)";
  return "rgba(148,163,184,0.12)";
}

function StatusIcon({ status }: { status: Status }) {
  if (status === "done") {
    return (
      <span
        className="w-9 h-9 rounded-full flex items-center justify-center shrink-0"
        style={{ background: statusBg("done") }}
      >
        <Check size={17} color="#22c55e" />
      </span>
    );
  }

  if (status === "progress") {
    return (
      <span
        className="w-9 h-9 rounded-full flex items-center justify-center shrink-0"
        style={{ background: statusBg("progress") }}
      >
        <Hammer size={17} color={BRAND.amber} />
      </span>
    );
  }

  return (
    <span
      className="w-9 h-9 rounded-full flex items-center justify-center shrink-0 border"
      style={{ borderColor: "#E2E8F0", color: "#94A3B8" }}
    >
      <Circle size={15} />
    </span>
  );
}

export default function RoadmapPage() {
  const progress = 45;

  return (
    <main
      className="min-h-screen px-6 py-24"
      style={{ background: "#ffffff" }}
    >
      <motion.div
        variants={staggerContainer(0.12)}
        initial="hidden"
        animate="show"
        className="max-w-5xl mx-auto"
      >
        {/* Back link */}
        <motion.div variants={fadeUp}>
          <Link
            href="/"
            className="inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-700 transition-colors"
          >
            <ArrowLeft size={16} />
            Back to Home
          </Link>
        </motion.div>

        {/* Hero */}
        <motion.div variants={fadeUp} className="text-center mt-10">
          {/* Status badge */}
          <div
            className="inline-flex items-center gap-2 rounded-full px-5 py-2 border text-xs font-bold uppercase tracking-widest"
            style={{
              borderColor: "rgba(217,142,59,0.4)",
              background: "rgba(217,142,59,0.1)",
              color: BRAND.amber,
            }}
          >
            <Rocket size={14} />
            Current Stage · Private Beta Development
          </div>

          <h1
            className="mt-6 text-5xl md:text-6xl font-black tracking-tight leading-tight"
            style={{ color: BRAND.indigo }}
          >
            Building KwanPay
            <br />
            in Public
          </h1>

          <p className="mt-6 text-lg text-slate-600 leading-8 max-w-2xl mx-auto">
            Follow our journey as we build Africa&apos;s next-generation travel
            wallet powered by modern payment infrastructure.
          </p>
        </motion.div>

        {/* Overall Progress */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.15 }}
          className="mt-14 rounded-3xl border border-slate-200 bg-white shadow-lg p-8"
          style={{ borderColor: "#ECECEC" }}
        >
          <div className="flex items-center justify-between flex-wrap gap-3">
            <p
              className="text-sm font-bold uppercase tracking-widest"
              style={{ color: BRAND.indigo }}
            >
              Overall Progress
            </p>
            <p
              className="text-2xl font-black"
              style={{ color: BRAND.amber }}
            >
              {progress}%
            </p>
          </div>

          {/* Progress bar */}
          <div
            className="mt-4 h-3 rounded-full overflow-hidden"
            style={{ background: "#EDEFF0" }}
          >
            <motion.div
              className="h-full rounded-full"
              style={{
                background:
                  "linear-gradient(90deg, #D98E3B, #B56F28)",
              }}
              initial={{ width: 0 }}
              animate={{ width: `${progress}%` }}
              transition={{ duration: 1.2, ease: "easeOut", delay: 0.3 }}
            />
          </div>

          <p className="mt-4 text-sm text-slate-500">
            Updated as the product evolves. {progress}% of our core roadmap is
            complete or in active development.
          </p>
        </motion.div>

        {/* Legend */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.7, delay: 0.25 }}
          className="mt-10 flex flex-wrap items-center justify-center gap-6"
        >
          <span className="inline-flex items-center gap-2 text-sm font-medium text-slate-600">
            <Check size={16} color="#22c55e" /> Completed
          </span>
          <span className="inline-flex items-center gap-2 text-sm font-medium text-slate-600">
            <Hammer size={16} color={BRAND.amber} /> In Progress
          </span>
          <span className="inline-flex items-center gap-2 text-sm font-medium text-slate-600">
            <Circle size={15} color="#94A3B8" /> Upcoming
          </span>
        </motion.div>

        {/* Timeline */}
        <div className="mt-16 space-y-8 relative">
          {/* Vertical line */}
          <div
            className="hidden md:block absolute left-[26px] top-4 bottom-4 w-px"
            style={{ background: "linear-gradient(180deg, #D98E3B, #E2E8F0)" }}
          />

          {phases.map((phase, idx) => (
            <motion.div
              key={phase.phase}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5 }}
              className="relative md:pl-20"
            >
              {/* Phase marker */}
              <div
                className="hidden md:flex absolute left-[9px] top-2 w-9 h-9 rounded-full items-center justify-center text-white font-bold text-sm"
                style={{ background: BRAND.indigo }}
              >
                {idx + 1}
              </div>

              <motion.div
                whileHover={{ y: -6, boxShadow: "0 30px 60px -20px rgba(30,35,64,0.25)" }}
                transition={{ type: "spring", stiffness: 260, damping: 22 }}
                className="rounded-3xl bg-white border border-slate-200 shadow-lg p-8"
              >
                {/* Phase header */}
                <div className="flex items-center justify-between flex-wrap gap-3">
                  <div className="flex items-center gap-4">
                    <span className="text-3xl">{phase.emoji}</span>
                    <div>
                      <p
                        className="text-xs font-bold uppercase tracking-widest"
                        style={{ color: BRAND.amber }}
                      >
                        {phase.phase}
                      </p>
                      <h2
                        className="mt-1 text-2xl font-black"
                        style={{ color: BRAND.indigo }}
                      >
                        {phase.title}
                      </h2>
                    </div>
                  </div>

                  <span
                    className="inline-flex items-center gap-2 rounded-full px-4 py-1.5 text-xs font-bold uppercase tracking-wider"
                    style={{
                      background: statusBg(phase.status),
                      color: statusColor(phase.status),
                    }}
                  >
                    <span
                      className="w-1.5 h-1.5 rounded-full"
                      style={{ background: statusColor(phase.status) }}
                    />
                    {phase.statusLabel}
                  </span>
                </div>

                {/* Items */}
                <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {phase.items.map((item) => (
                    <div
                      key={item}
                      className="flex items-center gap-3 rounded-2xl border px-4 py-3"
                      style={{
                        borderColor: "#E2E8F0",
                        background:
                          phase.status === "done"
                            ? "rgba(34,197,94,0.04)"
                            : phase.status === "progress"
                            ? "rgba(217,142,59,0.06)"
                            : "white",
                      }}
                    >
                      <StatusIcon status={phase.status} />
                      <span
                        className="font-semibold"
                        style={{
                          color:
                            phase.status === "todo" ? "#94A3B8" : BRAND.indigo,
                        }}
                      >
                        {item}
                      </span>
                    </div>
                  ))}
                </div>
              </motion.div>
            </motion.div>
          ))}
        </div>

        {/* Vision statement */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="mt-20 rounded-[32px] px-8 py-16 text-center overflow-hidden relative"
          style={{ background: BRAND.indigo }}
        >
          <div
            className="absolute inset-0 opacity-30"
            style={{
              background:
                "radial-gradient(circle at top right, rgba(217,142,59,.4), transparent 50%)",
            }}
          />
          <div className="relative">
            <p className="text-2xl md:text-4xl font-black text-white leading-snug max-w-3xl mx-auto">
              Our mission is to build the financial infrastructure that makes
              traveling across Africa as seamless as traveling within a single
              country.
            </p>
          </div>
        </motion.div>

        {/* Final CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="mt-20 text-center"
        >
          <h2
            className="text-4xl md:text-5xl font-black"
            style={{ color: BRAND.indigo }}
          >
            Help Shape KwanPay
          </h2>
          <p className="mt-5 text-lg text-slate-600 leading-8 max-w-xl mx-auto">
            Join the movement shaping the future of travel payments in Africa.
          </p>

          <div className="mt-10 flex justify-center gap-5 flex-wrap">
            <Link href="/waitlist">
              <motion.button
                whileHover={{ scale: 1.05, y: -3 }}
                whileTap={{ scale: 0.97 }}
                transition={{ type: "spring", stiffness: 340, damping: 22 }}
                className="group inline-flex items-center gap-2 rounded-full px-8 py-4 font-semibold text-white"
                style={{
                  background:
                    "linear-gradient(135deg, #D98E3B, #B56F28)",
                  boxShadow: "0 10px 30px -8px rgba(217,142,59,.6)",
                }}
              >
                Join Early Access
                <ArrowRight
                  size={18}
                  className="transition-transform group-hover:translate-x-0.5"
                />
              </motion.button>
            </Link>

            <Link href="/demo">
              <motion.button
                whileHover={{ scale: 1.05, y: -3 }}
                whileTap={{ scale: 0.97 }}
                transition={{ type: "spring", stiffness: 340, damping: 22 }}
                className="rounded-full px-8 py-4 border-2 font-semibold"
                style={{
                  borderColor: "#D7D7D7",
                  color: BRAND.indigo,
                  background: "white",
                }}
              >
                Request a Demo
              </motion.button>
            </Link>
          </div>
        </motion.div>
      </motion.div>
    </main>
  );
}
