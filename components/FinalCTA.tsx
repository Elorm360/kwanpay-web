"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { ArrowUpRight, Check, ShieldCheck } from "lucide-react";
import { BRAND } from "@/lib/brand";
import TiltCard from "@/components/TiltCard";

export default function FinalCTA() {
  return (
    <section
      id="join"
      className="py-36 px-6"
      style={{ background: BRAND.indigo }}
    >
      <div className="max-w-7xl mx-auto">
        {/* Two-column: copy + phone mockup */}
        <div className="grid lg:grid-cols-2 gap-16 items-center">

          {/* Left — copy & CTA */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-center lg:text-left"
          >
            <p
              className="uppercase tracking-[0.35em] text-sm font-semibold"
              style={{ color: BRAND.amber }}
            >
              Join the Journey
            </p>

            <h2 className="mt-6 text-5xl md:text-6xl font-black text-white leading-tight">
              The Future of African
              <br />
              Travel Payments Starts Here.
            </h2>

            <p className="mt-8 max-w-xl mx-auto lg:mx-0 text-lg leading-8 text-slate-300">
              We&apos;re building the next generation of travel payments for
              Africa. Join early adopters, tourism businesses and innovators
              helping shape the future of borderless travel.
            </p>

<div className="mt-12 flex justify-center lg:justify-start flex-wrap gap-5">
              <Link href="/demo">
                <motion.span
                  whileHover={{ scale: 1.05, y: -3 }}
                  whileTap={{ scale: 0.97 }}
                  transition={{ type: "spring", stiffness: 340, damping: 22 }}
                  className="inline-block group relative overflow-hidden rounded-full px-9 py-4 font-semibold text-white"
                  style={{
                    background: "linear-gradient(135deg, #D98E3B, #B56F28)",
                    boxShadow: "0 12px 32px -10px rgba(217,142,59,.6)",
                  }}
                >
                  <span className="relative z-10 flex items-center gap-2">
                    Request a Demo
                    <ArrowUpRight size={18} className="transition-transform group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
                  </span>
                </motion.span>
              </Link>

              <Link href="/waitlist">
                <motion.span
                  initial={{ background: "rgba(255,255,255,0)" }}
                  whileHover={{ scale: 1.05, y: -3, background: "rgba(255,255,255,0.1)" }}
                  whileTap={{ scale: 0.97 }}
                  transition={{ type: "spring", stiffness: 340, damping: 22 }}
                  className="inline-block rounded-full px-9 py-4 border backdrop-blur"
                  style={{ borderColor: "rgba(255,255,255,0.3)", color: "white" }}
                >
                  Join Early Access
                </motion.span>
              </Link>
            </div>

            {/* Beta status */}
            <p className="mt-10 text-sm text-slate-400 tracking-wide">
              Private Beta • Launching Soon Across Africa
            </p>
          </motion.div>

          {/* Right — phone mockup placeholder */}
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.15, duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
            className="flex justify-center"
            style={{ perspective: 1000 }}
          >
            <TiltCard className="relative" maxTilt={6}>
              {/* Glow */}
              <motion.div
                className="absolute -inset-8 rounded-[3.5rem] opacity-40 blur-3xl"
                style={{
                  background:
                    "radial-gradient(circle, rgba(217,142,59,.4), rgba(255,255,255,.08) 70%)",
                }}
                animate={{ opacity: [0.3, 0.5, 0.3] }}
                transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
              />

              {/* Phone frame */}
              <div
                className="relative w-[300px] sm:w-[330px] rounded-[3rem] border-[10px] p-4 bg-white shadow-2xl"
                style={{ borderColor: "rgba(255,255,255,0.15)" }}
              >
                {/* Notch */}
                <div
                  className="mx-auto w-24 h-6 rounded-b-2xl"
                  style={{ background: BRAND.indigo }}
                />

                {/* Screen — Coming Soon */}
                <div
                  className="relative mt-6 rounded-[2rem] flex flex-col items-center justify-center text-center overflow-hidden"
                  style={{
                    background:
                      "linear-gradient(160deg, #1E2340, #13162B 55%, #241e3a)",
                    minHeight: "420px",
                  }}
                >
                  {/* ambient glow */}
                  <div
                    className="absolute top-10 right-8 w-36 h-36 rounded-full blur-3xl opacity-50"
                    style={{
                      background:
                        "radial-gradient(circle, rgba(217,142,59,.6), transparent 70%)",
                    }}
                  />
                  <div
                    className="absolute bottom-8 left-6 w-28 h-28 rounded-full blur-2xl opacity-30"
                    style={{
                      background:
                        "radial-gradient(circle, rgba(217,142,59,.5), transparent 70%)",
                    }}
                  />

                  {/* Payment confirmation screen */}
                  <div className="relative w-full px-6 py-8">
                    <motion.div
                      className="w-16 h-16 rounded-full flex items-center justify-center mx-auto"
                      style={{
                        background:
                          "linear-gradient(135deg, rgba(74,222,128,.25), rgba(74,222,128,.08))",
                        border: "1px solid rgba(74,222,128,.45)",
                      }}
                      initial={{ scale: 0.6, opacity: 0 }}
                      whileInView={{ scale: 1, opacity: 1 }}
                      viewport={{ once: true }}
                      transition={{ type: "spring", stiffness: 260, damping: 16, delay: 0.4 }}
                    >
                      <Check size={30} color="#4ADE80" strokeWidth={3} aria-hidden />
                    </motion.div>

                    <p
                      className="mt-5 uppercase tracking-[0.3em] text-[11px] font-semibold"
                      style={{ color: BRAND.amber }}
                    >
                      Payment Sent
                    </p>
                    <p className="mt-2 text-4xl font-black text-white tracking-tight">
                      $185.00
                    </p>
                    <p className="mt-1 text-sm text-slate-300">
                      to Cape Coast Heritage Tours
                    </p>

                    <div className="mt-6 rounded-2xl bg-white/[0.06] border border-white/10 p-4 text-left space-y-3">
                      {[
                        { label: "Merchant receives", value: "GHS 2,868.50" },
                        { label: "Settled via", value: "Stellar · USDC" },
                        { label: "Settlement", value: "~5 seconds" },
                      ].map((row) => (
                        <div key={row.label} className="flex items-center justify-between text-xs">
                          <span className="text-slate-400">{row.label}</span>
                          <span className="font-semibold text-white">{row.value}</span>
                        </div>
                      ))}
                    </div>

                    <div className="mt-5 flex items-center justify-center gap-2 text-[11px] text-slate-400">
                      <ShieldCheck size={13} style={{ color: BRAND.amber }} aria-hidden />
                      Receipt saved to your travel history
                    </div>
                  </div>
                </div>
              </div>

              {/* Caption */}
              <p className="mt-6 text-center text-sm font-medium text-slate-400">
                Illustrative preview of the KwanPay app.
              </p>
            </TiltCard>
          </motion.div>

        </div>

        {/* Premium divider: trusted by the next generation */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.2 }}
          className="mt-24"
        >
          <div className="border-t border-white/15 pt-12 text-center">
            <p className="text-lg md:text-xl font-medium text-slate-300">
              Built for the next generation of African travelers.
            </p>
          </div>
        </motion.div>

        {/* Emotional closing line — bookends the Hero */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.1 }}
          className="mt-20 text-center"
        >
          <p className="text-3xl md:text-5xl font-black leading-snug text-white">
            One Wallet.
            <br />
            Every Journey.
            <br />
            <span style={{ color: BRAND.amber }}>Across Africa.</span>
          </p>
        </motion.div>
      </div>
    </section>
  );
}
