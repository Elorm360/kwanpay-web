"use client";

import { motion } from "framer-motion";
import Link from "next/link";
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
        className="absolute inset-0 opacity-40"
        style={{
          background: `
          radial-gradient(circle at top, rgba(30,35,64,.12), transparent 45%),
          radial-gradient(circle at bottom right, rgba(217,142,59,.12), transparent 35%)
        `,
        }}
      />

      <div className="relative max-w-7xl mx-auto">

        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: .8 }}
          className="text-center"
        >

          <div
            className="inline-flex items-center rounded-full px-5 py-2 mb-8 border"
            style={{
              borderColor: "#DADADA",
              background: "white",
            }}
          >
            <span
              className="h-2 w-2 rounded-full mr-3"
              style={{
                background: BRAND.amber,
              }}
            />

            <span
              className="text-sm font-semibold tracking-wide"
              style={{
                color: BRAND.indigo,
              }}
            >
              Africa Payment Infrastructure for Tourism
            </span>
          </div>

          <h1
            className="text-6xl md:text-8xl font-black leading-[1.05] tracking-tight"
            style={{
              color: BRAND.indigo,
            }}
          >
            Send money
            <br />

            for African travel

            <br />

            <span
              style={{
                color: BRAND.amber,
              }}
            >
              without the friction.
            </span>
          </h1>

          <p className="max-w-3xl mx-auto mt-10 text-xl leading-9 text-slate-600">

            KwanPay is cross-border payment infrastructure for African tourism.

            Pay any tourism operator across Africa quickly,

            transparently and at a fraction of traditional transfer costs.

          </p>

          <div className="flex justify-center gap-5 mt-12 flex-wrap">

            <Link href="/waitlist">
              <button
                className="rounded-full px-8 py-4 font-semibold shadow-lg transition-all duration-300 hover:scale-105"
                style={{
                  background: BRAND.amber,
                  color: "white",
                }}
              >
                Request Early Access
              </button>
            </Link>

            <a
              href="#how-it-works"
              className="rounded-full px-8 py-4 border font-semibold hover:bg-white hover:shadow-2xl hover:-translate-y-1 transition-all duration-300"
              style={{
                borderColor: "#D7D7D7",
                color: BRAND.indigo,
              }}
            >
              See how it works
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
                title: "Traveler Pays",
                body:
                  "The traveler pays using their local currency from anywhere in the world.",
              },

              {
                number: "02",
                title: "KwanPay settles",
                body:
                  "Payments are routed securely over Stellar with transparent settlement.",
              },

              {
                number: "03",
                title: "Operator gets paid",
                body:
                  "Tourism operators receive funds quickly, improving cash flow and reducing payment friction.",
              },
            ].map((step) => (
              <div
                key={step.number}
                className="group rounded-3xl bg-white p-10 border border-slate-200 shadow-lg hover:shadow-2xl hover:-translate-y-2 hover:border-slate-300 transition-all duration-500"
              >
                <p
                  className="text-sm font-bold tracking-widest"
                  style={{
                    color: BRAND.amber,
                  }}
                >
                  {step.number}
                </p>

                <h3
                  className="mt-5 text-2xl font-bold"
                  style={{
                    color: BRAND.indigo,
                  }}
                >
                  {step.title}
                </h3>

                <p className="mt-5 leading-8 text-slate-600">
                  {step.body}
                </p>
              </div>
            ))}

          </div>

        </motion.div>

      </div>

    </section>
  );
}