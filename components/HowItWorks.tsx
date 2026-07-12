"use client";

import { motion } from "framer-motion";
import { BRAND } from "@/lib/brand";

const steps = [
  {
    title: "Traveler Initiates Payment",
    description:
      "The traveler pays in their preferred currency from anywhere in the world.",
  },
  {
    title: "KwanPay Routes Securely",
    description:
      "KwanPay handles currency routing and settlement using the Stellar network.",
  },
  {
    title: "Operator Gets Paid",
    description:
      "The tourism business receives settlement quickly, reducing delays and payment costs.",
  },
];

export default function HowItWorks() {
  return (
    <section
      id="how-it-works"
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
            HOW IT WORKS
          </p>

          <h2 className="text-5xl md:text-6xl font-black mt-6 text-white">
            One payment.
            <br />
            One path.
          </h2>

          <p className="mt-8 max-w-3xl mx-auto text-slate-300 text-lg leading-8">
            Every payment follows one simple journey—from traveler to tourism
            operator—with fast settlement powered by Stellar.
          </p>
        </motion.div>

        <div className="mt-24 flex flex-col lg:flex-row items-center justify-between gap-8">

          {steps.map((step, index) => (
            <motion.div
              key={step.title}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.15 }}
              className="relative flex-1"
            >
              <div className="rounded-3xl bg-white/5 backdrop-blur-xl border border-white/10 p-10 h-full">

                <div
                  className="w-14 h-14 rounded-2xl flex items-center justify-center font-bold text-xl mb-8"
                  style={{
                    background: BRAND.amber,
                    color: "white",
                  }}
                >
                  {index + 1}
                </div>

                <h3 className="text-2xl font-bold text-white">
                  {step.title}
                </h3>

                <p className="mt-5 text-slate-300 leading-8">
                  {step.description}
                </p>

              </div>

              {index < 2 && (
                <div className="hidden lg:flex absolute top-1/2 -right-10 text-4xl text-white/20">
                  →
                </div>
              )}
            </motion.div>
          ))}

        </div>

      </div>
    </section>
  );
}