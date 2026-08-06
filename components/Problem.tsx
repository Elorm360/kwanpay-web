"use client";

import { motion } from "framer-motion";
import { Globe2, Wallet, ShieldCheck } from "lucide-react";
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
        <div className="grid md:grid-cols-3 gap-10 mt-20">

          {[
            {
              icon: Globe2,
              title: "Complicated Cross-Border Payments",
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
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 }}
                className="rounded-3xl p-10 bg-white border border-slate-200 shadow-lg hover:shadow-2xl hover:-translate-y-2 transition-all duration-500"
              >
                <div
                  className="inline-flex items-center justify-center w-14 h-14 rounded-2xl"
                  style={{ background: "rgba(217,142,59,0.12)" }}
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

        </div>

      </div>
    </section>
  );
}
