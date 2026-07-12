"use client";

import { motion } from "framer-motion";
import { BRAND } from "@/lib/brand";

export default function PaymentInfrastructure() {
  return (
    <section
      className="py-36 px-6"
      style={{ background: BRAND.indigo }}
    >
      <div className="max-w-7xl mx-auto">

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
            PAYMENT INFRASTRUCTURE
          </p>

          <h2 className="mt-6 text-5xl md:text-6xl font-black text-white">
            Engineered for fast,
            <br />
            borderless payments.
          </h2>

          <p className="mt-8 max-w-3xl mx-auto text-lg leading-8 text-slate-300">
            KwanPay is being developed with modern payment infrastructure in
            mind, enabling faster settlement, transparent cross-border
            transactions, and a smoother payment experience for African tourism.
            As the platform evolves, we intend to leverage the Stellar network
            to power efficient global settlement.
          </p>

        </motion.div>

        <div className="grid md:grid-cols-3 gap-8 mt-20">

          <div className="rounded-3xl bg-white/5 border border-white/10 p-8 backdrop-blur-xl">
            <h3 className="text-2xl font-bold text-white">
              Fast Settlement
            </h3>

            <p className="mt-4 text-slate-300 leading-8">
              Reduce payment delays and move funds more efficiently across
              borders.
            </p>
          </div>

          <div className="rounded-3xl bg-white/5 border border-white/10 p-8 backdrop-blur-xl">
            <h3 className="text-2xl font-bold text-white">
              Transparent
            </h3>

            <p className="mt-4 text-slate-300 leading-8">
              Every payment follows a clear route, giving travelers and tourism
              businesses greater confidence.
            </p>
          </div>

          <div className="rounded-3xl bg-white/5 border border-white/10 p-8 backdrop-blur-xl">
            <h3 className="text-2xl font-bold text-white">
              Built to Scale
            </h3>

            <p className="mt-4 text-slate-300 leading-8">
              Designed as infrastructure that can support multiple tourism
              platforms across Africa over time.
            </p>
          </div>

        </div>

      </div>
    </section>
  );
}