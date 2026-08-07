"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import {
  Globe2,
  Sparkles,
  Send,
  ShieldCheck,
  BadgeCheck,
} from "lucide-react";
import { BRAND } from "@/lib/brand";

export default function Hero() {
  return (
    <section
      id="hero"
      className="relative overflow-hidden pt-44 pb-36 px-6"
      style={{ background: BRAND.paper }}
    >
      {/* Background */}
      <div
        className="absolute inset-0 opacity-50"
        style={{
          background: `
          radial-gradient(circle at 20% 15%, rgba(30,35,64,.14), transparent 45%),
          radial-gradient(circle at 85% 30%, rgba(217,142,59,.16), transparent 40%),
          radial-gradient(circle at 50% 95%, rgba(217,142,59,.10), transparent 45%)
        `,
        }}
      />

      {/* Subtle grid texture for depth */}
      <div
        className="absolute inset-0 opacity-[0.04]"
        style={{
          backgroundImage:
            "linear-gradient(rgba(30,35,64,.6) 1px, transparent 1px), linear-gradient(90deg, rgba(30,35,64,.6) 1px, transparent 1px)",
          backgroundSize: "56px 56px",
        }}
      />

      <div className="relative max-w-7xl mx-auto">

        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: .8 }}
          className="text-center"
        >

          {/* Premium badge with gradient border, glow, live dot & shimmer */}
          <div className="inline-flex justify-center mb-8">
            <div
              className="relative rounded-full p-px"
              style={{
                background:
                  "linear-gradient(135deg, rgba(217,142,59,.9), rgba(30,35,64,.55))",
                boxShadow:
                  "0 8px 30px -8px rgba(217,142,59,.45), 0 4px 16px -6px rgba(30,35,64,.25)",
              }}
            >
              <motion.div
                initial={{ opacity: 0, scale: .9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: .6, delay: .2 }}
                className="relative flex items-center gap-3 rounded-full bg-white/95 backdrop-blur px-5 py-2 pr-6 overflow-hidden"
              >
                {/* Shimmer sweep */}
                <motion.span
                  className="absolute inset-y-0 w-1/3 -skew-x-12 pointer-events-none"
                  style={{
                    background:
                      "linear-gradient(90deg, transparent, rgba(255,255,255,.55), transparent)",
                  }}
                  initial={{ x: "-120%" }}
                  animate={{ x: "420%" }}
                  transition={{ duration: 2.6, repeat: Infinity, ease: "easeInOut", repeatDelay: 2.2 }}
                />

                {/* Icon tile */}
                <span
                  className="relative flex items-center justify-center w-8 h-8 rounded-full"
                  style={{
                    background:
                      "linear-gradient(135deg, #D98E3B, #B56F28)",
                    boxShadow: "inset 0 1px 0 rgba(255,255,255,.35)",
                  }}
                >
                  <Globe2 size={16} color="white" />
                </span>

                <span
                  className="relative text-sm font-bold tracking-wide"
                  style={{ color: BRAND.indigo }}
                >
                  Africa&apos;s Travel Wallet
                </span>

                {/* Live status dot */}
                <span className="relative inline-flex items-center gap-1.5 ml-1">
                  <span
                    className="w-2 h-2 rounded-full"
                    style={{ background: BRAND.amber }}
                  />
                  <span
                    className="text-[11px] font-semibold uppercase tracking-widest"
                    style={{ color: BRAND.amber }}
                  >
                    Private Beta
                  </span>
                </span>
              </motion.div>
            </div>
          </div>

          <h1
            className="text-6xl md:text-8xl font-black leading-[1.05] tracking-tight"
            style={{
              color: BRAND.indigo,
            }}
          >
            One Wallet.
            <br />

            Every Journey.
            <br />

            <span
              style={{
                color: BRAND.amber,
              }}
            >
              Across Africa.
            </span>
          </h1>

          <p className="max-w-3xl mx-auto mt-10 text-xl leading-9 text-slate-600">

            KwanPay helps travelers pay for transport,
            tours, hotels and experiences across Africa
            using one secure digital wallet.

            Send money, manage your travel funds and
            pay trusted tourism businesses—all from one
            premium mobile experience.

          </p>

          <div
            className="mt-6 text-sm font-medium"
            style={{ color: BRAND.indigo }}
          >
            Currently in Private Beta • Launching Soon Across Africa
          </div>

<div className="flex justify-center gap-5 mt-12 flex-wrap">

<Link href="/demo">
              <button
                className="group relative overflow-hidden rounded-full px-9 py-4 font-semibold text-white transition-all duration-300 hover:-translate-y-1 hover:shadow-2xl"
                style={{
                  background:
                    "linear-gradient(135deg, #D98E3B, #B56F28)",
                  boxShadow:
                    "0 10px 30px -8px rgba(217,142,59,.6)",
                }}
              >
                <span className="relative z-10 flex items-center gap-2">
                  Request a Demo
                  <Sparkles size={17} className="transition-transform group-hover:rotate-12" />
                </span>
              </button>
            </Link>

            <a
              href="#features"
              className="rounded-full px-9 py-4 border-2 font-semibold hover:bg-white hover:shadow-2xl hover:-translate-y-1 transition-all duration-300"
              style={{
                borderColor: "#D7D7D7",
                color: BRAND.indigo,
                background: "rgba(255,255,255,.6)",
                backdropFilter: "blur(8px)",
              }}
            >
              Explore Features
            </a>

          </div>

        </motion.div>

        {/* Payment Flow */}

        <motion.div
          initial={{ opacity: 0, y: 70 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: .8 }}
          className="mt-28"
        >

          <div className="grid lg:grid-cols-3 gap-8">

{[
              {
                number: "01",
                icon: "pays",
                title: "Traveler Pays",
                body:
                  "The traveler pays using their local currency from anywhere in the world.",
              },

              {
                number: "02",
                icon: "settles",
                title: "KwanPay Settles",
                body:
                  "Payments are routed securely over Stellar with transparent settlement.",
              },

              {
                number: "03",
                icon: "paid",
                title: "Operator Gets Paid",
                body:
                  "Tourism operators receive funds quickly, improving cash flow and reducing payment friction.",
              },
            ].map((step, i) => (
              <div key={step.number} className="relative group">
                <div className="relative h-full rounded-3xl bg-white p-10 border border-slate-100 shadow-lg hover:shadow-2xl hover:-translate-y-2 hover:border-amber-200 transition-all duration-500 overflow-hidden">
                  {/* top accent line */}
                  <div
                    className="absolute top-0 left-0 right-0 h-1 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                    style={{
                      background:
                        "linear-gradient(90deg, #D98E3B, #1E2340)",
                    }}
                  />

                  {/* number tile */}
                  <div className="flex items-center justify-between">
                    <span
                      className="text-5xl font-black"
                      style={{
                        background:
                          "linear-gradient(135deg, #D98E3B, #B56F28)",
                        WebkitBackgroundClip: "text",
                        backgroundClip: "text",
                        color: "transparent",
                      }}
                    >
                      {step.number}
                    </span>

                    <span
                      className="w-12 h-12 rounded-2xl flex items-center justify-center shadow-md"
                      style={{
                        background:
                          "linear-gradient(135deg, rgba(217,142,59,.15), rgba(30,35,64,.08))",
                        color: BRAND.amber,
                      }}
                    >
                      {i === 0 ? (
                        <Send size={22} />
                      ) : i === 1 ? (
                        <ShieldCheck size={22} />
                      ) : (
                        <BadgeCheck size={22} />
                      )}
                    </span>
                  </div>

                  <h3
                    className="mt-6 text-2xl font-bold"
                    style={{ color: BRAND.indigo }}
                  >
                    {step.title}
                  </h3>

                  <p className="mt-4 leading-7 text-slate-600">
                    {step.body}
                  </p>
                </div>

                {/* connector */}
                {i < 2 && (
                  <div className="hidden lg:flex absolute top-1/2 -right-6 z-10 w-6 items-center justify-center">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                      <path
                        d="M5 12h14M13 6l6 6-6 6"
                        stroke="#D98E3B"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                  </div>
                )}
              </div>
            ))}

          </div>

        </motion.div>

      </div>

    </section>
  );
}