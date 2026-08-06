"use client";

import { motion } from "framer-motion";
import {
  ShieldCheck,
  Lock,
  ReceiptText,
  Globe,
  Check,
  BadgeCheck,
  EyeOff,
  Fingerprint,
} from "lucide-react";
import { BRAND } from "@/lib/brand";

const checklist = [
  "Secure Authentication",
  "Transparent Transactions",
  "Reliable Infrastructure",
  "Growing Ecosystem",
];

const trustCards = [
  {
    icon: ShieldCheck,
    title: "Secure Authentication",
    description:
      "Every account is protected through secure authentication and modern security practices.",
  },
  {
    icon: Lock,
    title: "Your Data Matters",
    description:
      "We are committed to protecting your information and building privacy into every part of the KwanPay experience.",
  },
  {
    icon: ReceiptText,
    title: "Transparent Transactions",
    description:
      "Track your payments with a complete transaction history and clear activity records.",
  },
  {
    icon: Globe,
    title: "Built for Africa",
    description:
      "KwanPay is designed specifically to simplify payments across Africa's growing tourism ecosystem.",
  },
];

const roadmap = [
  "AI Travel Assistant",
  "Multi-Currency Wallet",
  "Merchant Payments",
  "QR Payments",
  "Borderless Travel Experiences",
];

const recentActivity = [
  { label: "Serengeti Safari", detail: "04 Jun • 14:22", amount: "-$420.00" },
  { label: "Fund Wallet", detail: "03 Jun • 09:05", amount: "+$500.00" },
  { label: "Hotel Stay", detail: "02 Jun • 18:41", amount: "-$260.00" },
];

export default function PaymentInfrastructure() {
  return (
    <section
      id="trust"
      className="py-36 px-6"
      style={{ background: "white" }}
    >
      <div className="max-w-7xl mx-auto">

        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center"
        >
          <p
            className="uppercase tracking-[0.35em] text-sm font-semibold"
            style={{ color: BRAND.amber }}
          >
            SECURITY &amp; TRUST
          </p>

          <h2
            className="mt-6 text-5xl md:text-6xl font-black leading-tight"
            style={{ color: BRAND.indigo }}
          >
            Built on Trust.
            <br />
            Designed for Africa.
          </h2>

          <p className="mt-8 max-w-3xl mx-auto text-lg leading-8 text-slate-600">
            Every payment matters. That&apos;s why KwanPay is being built with
            security, transparency and reliability at its core—so travelers and
            tourism businesses can move money with confidence.
          </p>
        </motion.div>

        {/* Two-column: Security Text + Trust Illustration */}
        <div className="grid lg:grid-cols-2 gap-16 items-center mt-24">

          {/* Left — checklist */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
          >
            <h3
              className="text-3xl md:text-4xl font-black leading-tight"
              style={{ color: BRAND.indigo }}
            >
              Secure by design.
              <br />
              Built with modern authentication.
            </h3>

            <p className="mt-6 text-lg text-slate-600 leading-8">
              We prioritize privacy-focused development and transparent
              payments—so both sides of the marketplace can move money with
              peace of mind.
            </p>

            <ul className="mt-10 grid grid-cols-1 sm:grid-cols-2 gap-4">
              {checklist.map((item) => (
                <li key={item} className="flex items-center gap-3">
                  <span
                    className="w-8 h-8 rounded-full flex items-center justify-center shrink-0"
                    style={{ background: "rgba(217,142,59,0.12)" }}
                  >
                    <Check size={16} color={BRAND.amber} />
                  </span>
                  <span
                    className="font-semibold text-lg"
                    style={{ color: BRAND.indigo }}
                  >
                    {item}
                  </span>
                </li>
              ))}
            </ul>
          </motion.div>

          {/* Right — trust illustration */}
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            className="flex justify-center"
          >
            <div className="relative w-full max-w-md">
              {/* Glow */}
              <div
                className="absolute -inset-8 rounded-[3rem] opacity-40 blur-3xl"
                style={{
                  background:
                    "radial-gradient(circle, rgba(217,142,59,.35), rgba(30,35,64,.12) 70%)",
                }}
              />

              {/* Card */}
              <div
                className="relative rounded-[2.5rem] bg-white border border-slate-200 p-8 shadow-2xl"
                style={{ borderColor: "#ECECEC" }}
              >
                {/* Shield + badges */}
                <div className="flex items-center justify-between">
                  <div
                    className="w-16 h-16 rounded-2xl flex items-center justify-center"
                    style={{ background: BRAND.indigo }}
                  >
                    <ShieldCheck size={30} color={BRAND.amber} />
                  </div>

                  <div className="flex gap-2">
                    <span
                      className="inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-semibold"
                      style={{
                        background: "rgba(217,142,59,0.12)",
                        color: BRAND.amber,
                      }}
                    >
                      <Fingerprint size={13} /> Secure
                    </span>
                    <span
                      className="inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-semibold"
                      style={{
                        background: "rgba(30,35,64,0.06)",
                        color: BRAND.indigo,
                      }}
                    >
                      <EyeOff size={13} /> Private
                    </span>
                  </div>
                </div>

                {/* Verified row */}
                <div
                  className="mt-6 rounded-2xl border border-slate-200 p-4 flex items-center gap-3"
                >
                  <BadgeCheck size={22} color={BRAND.amber} />
                  <div>
                    <p
                      className="text-sm font-bold"
                      style={{ color: BRAND.indigo }}
                    >
                      Verified Account
                    </p>
                    <p className="text-xs text-slate-400">
                      Multifactor authentication enabled
                    </p>
                  </div>
                </div>

                {/* Transparent transactions */}
                <div className="mt-6">
                  <p
                    className="text-[11px] font-semibold uppercase tracking-widest"
                    style={{ color: BRAND.indigo }}
                  >
                    Transparent Activity
                  </p>

                  <div className="mt-3 space-y-3">
                    {recentActivity.map((tx) => (
                      <div
                        key={tx.label}
                        className="flex items-center justify-between rounded-xl border border-slate-200 px-4 py-3"
                      >
                        <div>
                          <p
                            className="text-sm font-semibold"
                            style={{ color: BRAND.indigo }}
                          >
                            {tx.label}
                          </p>
                          <p className="text-xs text-slate-400">
                            {tx.detail}
                          </p>
                        </div>
                        <p className="text-sm font-bold text-slate-600">
                          {tx.amount}
                        </p>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              <p className="mt-6 text-center text-sm font-medium text-slate-500">
                Privacy-first. Transparent. Built with modern security.
              </p>
            </div>
          </motion.div>

        </div>

        {/* Four Trust Cards */}
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 mt-24">

          {trustCards.map((item, index) => {
            const Icon = item.icon;

            return (
              <motion.div
                key={item.title}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
                className="group rounded-3xl bg-white border border-slate-200 p-10 shadow-lg hover:shadow-2xl hover:-translate-y-2 transition-all duration-500"
                style={{ borderColor: "#ECECEC" }}
              >
                <div
                  className="inline-flex items-center justify-center w-14 h-14 rounded-2xl"
                  style={{ background: "rgba(217,142,59,0.12)" }}
                >
                  <Icon size={26} color={BRAND.amber} />
                </div>

                <h3
                  className="mt-6 text-2xl font-bold"
                  style={{ color: BRAND.indigo }}
                >
                  {item.title}
                </h3>

                <p className="mt-4 leading-7 text-slate-600">
                  {item.description}
                </p>
              </motion.div>
            );
          })}

        </div>

        {/* Trust Statement */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="mt-24 text-center"
        >
          <p
            className="text-2xl md:text-4xl font-black leading-snug"
            style={{ color: BRAND.indigo }}
          >
            Trust isn&apos;t a feature.
            <br />
            <span style={{ color: BRAND.amber }}>
              It&apos;s the foundation of every payment.
            </span>
          </p>
        </motion.div>

        {/* Coming Soon Roadmap */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.15 }}
          className="mt-24 rounded-[32px] border border-slate-200 p-10 md:p-14"
          style={{ borderColor: "#ECECEC", background: "#FAFBFC" }}
        >
          <p
            className="text-center uppercase tracking-[0.35em] text-sm font-semibold"
            style={{ color: BRAND.amber }}
          >
            Coming Soon
          </p>

          <div className="flex flex-wrap items-center justify-center gap-x-8 gap-y-4 mt-8">
            {roadmap.map((item) => (
              <span
                key={item}
                className="inline-flex items-center gap-2 text-base md:text-lg font-semibold"
                style={{ color: BRAND.indigo }}
              >
                <Check size={18} color={BRAND.amber} />
                {item}
              </span>
            ))}
          </div>

          <p className="text-center mt-8 text-sm text-slate-500">
            KwanPay is evolving into a much larger travel ecosystem.
          </p>
        </motion.div>

      </div>
    </section>
  );
}
