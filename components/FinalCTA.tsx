"use client";

import { motion } from "framer-motion";
import { BRAND } from "@/lib/brand";

export default function FinalCTA() {
  return (
    <section
      className="py-36 px-6"
      style={{ background: BRAND.paper }}
    >
      <div
        className="max-w-6xl mx-auto rounded-[40px] overflow-hidden shadow-2xl"
        style={{ background: BRAND.indigo }}
      >
        <div className="px-10 py-24 md:px-20 text-center">

          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
          >

            <p
              className="uppercase tracking-[0.35em] text-sm font-semibold"
              style={{ color: BRAND.amber }}
            >
              JOIN THE JOURNEY
            </p>

            <h2 className="mt-6 text-5xl md:text-6xl font-black text-white leading-tight">
              Be among the first
              <br />
              to experience KwanPay.
            </h2>

            <p className="mt-8 max-w-3xl mx-auto text-lg leading-8 text-slate-300">
              Join our early access list and follow the journey as we build
              Africa's next generation of cross-border payment infrastructure
              for tourism.
            </p>

            <div className="mt-12 flex justify-center flex-wrap gap-5">

              <button
                className="rounded-full px-8 py-4 font-semibold text-white shadow-xl hover:-translate-y-1 hover:shadow-2xl transition-all duration-300"
                style={{
                  background: BRAND.amber,
                }}
              >
                Request Early Access
              </button>

              <button
                className="rounded-full px-8 py-4 border border-white/20 text-white hover:bg-white/10 transition-all duration-300"
              >
                Contact Us
              </button>

            </div>

          </motion.div>

        </div>
      </div>
    </section>
  );
}