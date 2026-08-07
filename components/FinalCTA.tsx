"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { Flame, ArrowUpRight } from "lucide-react";
import { BRAND } from "@/lib/brand";

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
                <button
                  className="group relative overflow-hidden rounded-full px-9 py-4 font-semibold text-white shadow-xl hover:-translate-y-1 hover:shadow-2xl transition-all duration-300"
                  style={{
                    background: "linear-gradient(135deg, #D98E3B, #B56F28)",
                    boxShadow: "0 12px 32px -10px rgba(217,142,59,.6)",
                  }}
                >
                  <span className="relative z-10 flex items-center gap-2">
                    Request a Demo
                    <ArrowUpRight size={18} className="transition-transform group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
                  </span>
                </button>
              </Link>

              <Link href="/waitlist">
                <button className="rounded-full px-9 py-4 border border-white/30 text-white hover:bg-white/10 hover:border-white/50 backdrop-blur transition-all duration-300">
                  Join Early Access
                </button>
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
            transition={{ delay: 0.15 }}
            className="flex justify-center"
          >
            <div className="relative">
              {/* Glow */}
              <div
                className="absolute -inset-8 rounded-[3.5rem] opacity-40 blur-3xl"
                style={{
                  background:
                    "radial-gradient(circle, rgba(217,142,59,.4), rgba(255,255,255,.08) 70%)",
                }}
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

                  <div className="relative">
                    <div
                      className="w-16 h-16 rounded-3xl flex items-center justify-center mx-auto"
                      style={{
                        background:
                          "linear-gradient(135deg, rgba(217,142,59,.25), rgba(217,142,59,.08))",
                        border: "1px solid rgba(217,142,59,.35)",
                      }}
                    >
                      <Flame size={30} style={{ color: BRAND.amber }} />
                    </div>

                    <p
                      className="mt-6 uppercase tracking-[0.3em] text-xs font-semibold"
                      style={{ color: BRAND.amber }}
                    >
                      Coming Soon
                    </p>

                    <p className="mt-4 text-2xl font-black text-white">
                      Your Travel Wallet
                    </p>

                    <p className="mt-3 max-w-[220px] text-sm text-slate-300 leading-6">
                      Dashboard screenshot placeholder — the app UI will live here.
                    </p>
                  </div>
                </div>
              </div>

              {/* Caption */}
              <p className="mt-6 text-center text-sm font-medium text-slate-400">
                The KwanPay experience — coming soon.
              </p>
            </div>
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
              Trusted by the next generation of African travelers.
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
