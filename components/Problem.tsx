"use client";

import { motion } from "framer-motion";
import { BRAND } from "@/lib/brand";

export default function Problem() {
  return (
    <section
id="problem"
      className="py-36 px-6"
      style={{ background: BRAND.paper }}
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
            className="uppercase tracking-[0.35em] font-semibold text-sm"
            style={{ color: BRAND.amber }}
          >
            The Problem
          </p>

          <h2
            className="text-5xl md:text-6xl font-black mt-6"
            style={{ color: BRAND.indigo }}
          >
            Cross-border payments still don’t work for African travel
          </h2>

          <p className="mt-6 text-lg text-slate-600 max-w-3xl mx-auto leading-8">
            Global travel is growing fast — but payment infrastructure between
            travelers and African tourism operators is still slow, expensive,
            and unreliable.
          </p>
        </motion.div>

        {/* Cards */}
        <div className="grid md:grid-cols-3 gap-10 mt-20">

          {[
            {
              title: "High Fees",
              desc:
                "International transfers and card payments often lose 5–10% in hidden fees and FX charges.",
            },
            {
              title: "Slow Settlement",
              desc:
                "Payments take 3–5 business days to reach operators, delaying bookings and cash flow.",
            },
            {
              title: "Limited Access",
              desc:
                "Many African tourism businesses cannot reliably accept international payments at all.",
            },
          ].map((item, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1 }}
              className="rounded-3xl p-10 bg-white border border-slate-200 shadow-lg hover:-translate-y-2 transition"
            >
              <div
                className="text-sm font-bold tracking-widest"
                style={{ color: BRAND.amber }}
              >
                0{i + 1}
              </div>

              <h3
                className="text-2xl font-bold mt-5"
                style={{ color: BRAND.indigo }}
              >
                {item.title}
              </h3>

              <p className="mt-5 text-slate-600 leading-7">
                {item.desc}
              </p>
            </motion.div>
          ))}

        </div>

      </div>
    </section>
  );
}