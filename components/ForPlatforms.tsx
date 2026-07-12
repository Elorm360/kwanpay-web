"use client";

import { motion } from "framer-motion";
import { BRAND } from "@/lib/brand";

export default function ForPlatforms() {
  return (
    <section
      id="platforms"
      className="py-36 px-6"
      style={{ background: BRAND.paper }}
    >
      <div className="max-w-7xl mx-auto">

        <div className="grid lg:grid-cols-2 gap-20 items-center">

          {/* Left Side */}

          <motion.div
            initial={{ opacity: 0, x: -40 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
          >
            <p
              className="uppercase tracking-[0.35em] text-sm font-semibold"
              style={{ color: BRAND.amber }}
            >
              FOR PLATFORMS
            </p>

            <h2
              className="mt-6 text-5xl md:text-6xl font-black leading-tight"
              style={{ color: BRAND.indigo }}
            >
              Cross-border payments,
              <br />
              ready to integrate.
            </h2>

            <p className="mt-8 text-lg leading-8 text-slate-600">
              KwanPay is being designed as payment infrastructure for tourism.
              Whether you operate a booking platform, tour marketplace,
              accommodation service, or travel business, you can integrate one
              payment layer instead of building international payment
              infrastructure from scratch.
            </p>

            <button
              className="mt-10 rounded-full px-8 py-4 font-semibold text-white shadow-lg hover:shadow-2xl hover:-translate-y-1 transition-all duration-300"
              style={{
                background: BRAND.amber,
              }}
            >
              Talk to Us About Integration
            </button>

          </motion.div>

          {/* Right Side */}

          <motion.div
            initial={{ opacity: 0, x: 40 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="rounded-[32px] bg-white border border-slate-200 shadow-xl p-10"
          >

            <div className="space-y-8">

              {[
                "Easy platform integration",
                "Cross-border payment routing",
                "Multi-currency support",
                "Fast settlement",
                "Designed for African tourism",
              ].map((item) => (

                <div
                  key={item}
                  className="flex items-center gap-4"
                >

                  <div
                    className="w-10 h-10 rounded-xl flex items-center justify-center text-white font-bold"
                    style={{ background: BRAND.amber }}
                  >
                    ✓
                  </div>

                  <p
                    className="text-lg font-medium"
                    style={{ color: BRAND.indigo }}
                  >
                    {item}
                  </p>

                </div>

              ))}

            </div>

          </motion.div>

        </div>

      </div>
    </section>
  );
}