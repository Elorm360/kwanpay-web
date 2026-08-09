"use client";

import { motion } from "framer-motion";
import { Globe2, Wallet, ShieldCheck } from "lucide-react";
import { BRAND } from "@/lib/brand";
import { fadeUp, staggerContainer, viewportOnce } from "@/lib/motion";

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
          variants={fadeUp}
          initial="hidden"
          whileInView="show"
          viewport={viewportOnce}
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
            Travel Should Be Easy.
            <br />
            Paying Should Be Even Easier.
          </h2>

          <p className="mt-6 text-lg text-slate-600 max-w-3xl mx-auto leading-8">
            Traveling across Africa should be exciting—not stressful.
            From paying tour operators to booking transport and managing
            travel funds, KwanPay removes payment barriers so you can focus
            on the journey, not the transaction.
          </p>
        </motion.div>

        {/* Cards */}
        <motion.div
          variants={staggerContainer(0.12)}
          initial="hidden"
          whileInView="show"
          viewport={viewportOnce}
          className="grid md:grid-cols-3 gap-10 mt-20"
        >

          {[
            {
              icon: Globe2,
              title: "Complicated cross-border Payments",
              desc:
                "Sending money across borders can be slow, expensive and unpredictable, especially when planning a trip.",
            },
            {
              icon: Wallet,
              title: "Too Many Payment Methods",
              desc:
                "Travelers often switch between cash, bank transfers and multiple mobile money services just to complete one journey.",
            },
            {
              icon: ShieldCheck,
              title: "Limited Trust",
              desc:
                "Paying unfamiliar tourism providers should feel safe and transparent, with clear records of every transaction.",
            },
          ].map((item, i) => {
            const Icon = item.icon;

            return (
              <motion.div
                key={i}
                variants={fadeUp}
                whileHover={{ y: -10, boxShadow: "0 30px 60px -20px rgba(30,35,64,0.25)" }}
                transition={{ type: "spring", stiffness: 260, damping: 22 }}
                className="group relative rounded-3xl p-10 bg-white border border-slate-200 shadow-lg overflow-hidden"
              >
                {/* top accent */}
                <div
                  className="absolute top-0 left-0 right-0 h-1 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                  style={{
                    background:
                      "linear-gradient(90deg, #D98E3B, #1E2340)",
                  }}
                />

                <div
                  className="inline-flex items-center justify-center w-14 h-14 rounded-2xl transition-transform duration-300 group-hover:scale-110"
                  style={{
                    background:
                      "linear-gradient(135deg, rgba(217,142,59,.15), rgba(30,35,64,.06))",
                  }}
                >
                  <Icon size={26} color={BRAND.amber} />
                </div>

                <h3
                  className="text-2xl font-bold mt-6"
                  style={{ color: BRAND.indigo }}
                >
                  {item.title}
                </h3>

                <p className="mt-5 text-slate-600 leading-7">
                  {item.desc}
                </p>
              </motion.div>
            );
          })}

        </motion.div>

      </div>
    </section>
  );
}
