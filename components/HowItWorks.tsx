"use client";

import { motion } from "framer-motion";
import { Wallet, UserCheck, CreditCard, Send } from "lucide-react";
import { BRAND } from "@/lib/brand";

const steps = [
  {
    icon: Wallet,
    title: "Create Your Wallet",
    description:
      "Sign up in minutes and receive your secure KwanPay travel wallet.",
  },
  {
    icon: UserCheck,
    title: "Verify Your Account",
    description:
      "Complete a simple verification process to unlock your wallet and keep payments secure.",
  },
  {
    icon: CreditCard,
    title: "Fund Your Wallet",
    description:
      "Top up your wallet and prepare for your next adventure across Africa.",
  },
  {
    icon: Send,
    title: "Pay Anywhere",
    description:
      "Send money, pay tourism businesses and manage every travel payment from one place.",
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
            How KwanPay Works
          </h2>

          <p className="mt-8 max-w-3xl mx-auto text-slate-300 text-lg leading-8">
            From creating your wallet to paying across Africa, KwanPay makes
            every step simple, secure and seamless.
          </p>
        </motion.div>

        <div className="mt-24 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-5">

          {steps.map((step, index) => {
            const Icon = step.icon;

            return (
              <motion.div
                key={step.title}
                initial={{ opacity: 0, y: 40 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.15 }}
                className="relative"
              >
                <div className="group relative rounded-3xl bg-white/5 backdrop-blur-xl border border-white/10 p-10 h-full flex flex-col items-center text-center overflow-hidden hover:border-white/20 hover:-translate-y-2 hover:shadow-2xl transition-all duration-500">

                  {/* top gradient accent */}
                  <div
                    className="absolute top-0 left-0 right-0 h-px opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                    style={{
                      background:
                        "linear-gradient(90deg, transparent, rgba(217,142,59,.6), transparent)",
                    }}
                  />

                  <div
                    className="relative w-16 h-16 rounded-2xl flex items-center justify-center mb-8 transition-transform duration-300 group-hover:scale-110"
                    style={{
                      background:
                        "linear-gradient(135deg, #D98E3B, #B56F28)",
                      boxShadow: "0 8px 24px -6px rgba(217,142,59,.5)",
                    }}
                  >
                    <Icon size={28} color="white" />
                  </div>

                  <span
                    className="inline-flex items-center gap-2 text-sm font-bold tracking-widest"
                    style={{ color: BRAND.amber }}
                  >
                    <span className="w-1.5 h-1.5 rounded-full" style={{ background: BRAND.amber }} />
                    STEP {index + 1}
                  </span>

                  <h3 className="text-2xl font-bold text-white mt-3">
                    {step.title}
                  </h3>

                  <p className="mt-5 text-slate-300 leading-8">
                    {step.description}
                  </p>

                </div>

                {index < 3 && (
                  <div className="hidden lg:flex absolute top-1/2 -right-5 text-3xl text-white/20 z-10">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" className="opacity-60">
                      <path
                        d="M5 12h14M13 6l6 6-6 6"
                        stroke="#D98E3B"
                        strokeWidth="1.6"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                  </div>
                )}
              </motion.div>
            );
          })}

        </div>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.2 }}
          className="mt-20 text-center text-lg text-slate-300"
        >
          Everything you need for borderless African travel.
          <br />
          <span className="font-semibold text-white">
            One wallet. One experience.
          </span>
        </motion.p>

      </div>
    </section>
  );
}
