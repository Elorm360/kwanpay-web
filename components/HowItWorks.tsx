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
                <div className="rounded-3xl bg-white/5 backdrop-blur-xl border border-white/10 p-10 h-full flex flex-col items-center text-center">

                  <div
                    className="w-16 h-16 rounded-2xl flex items-center justify-center mb-8"
                    style={{ background: BRAND.amber }}
                  >
                    <Icon size={28} color="white" />
                  </div>

                  <span
                    className="text-sm font-bold tracking-widest"
                    style={{ color: BRAND.amber }}
                  >
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
                    →
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
