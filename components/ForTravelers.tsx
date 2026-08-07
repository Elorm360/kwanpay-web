"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import {
  Plane,
  Hotel,
  Car,
  Smartphone,
  Check,
  ArrowRight,
  Send,
  Plus,
  Landmark,
  Bus,
} from "lucide-react";
import { BRAND } from "@/lib/brand";

const experiences = [
  {
    icon: Plane,
    title: "Travel Anywhere",
    description:
      "Move across African destinations with one travel wallet designed for borderless experiences.",
  },
  {
    icon: Hotel,
    title: "Book With Confidence",
    description:
      "Pay trusted hotels, tour operators and travel businesses from a single wallet.",
  },
  {
    icon: Car,
    title: "Pay on the Move",
    description:
      "Transport, experiences and local services—all managed from one secure payment experience.",
  },
  {
    icon: Smartphone,
    title: "Track Every Payment",
    description:
      "View balances, monitor transactions and manage your travel spending in real time.",
  },
];

const checklist = ["Travel", "Hotels", "Transport", "Experiences"];

const transactions = [
  {
    icon: Landmark,
    label: "Serengeti Safari",
    sub: "Tour Operator",
    amount: "-$420.00",
  },
  {
    icon: Bus,
    label: "City Transport",
    sub: "Daily Rides",
    amount: "-$18.50",
  },
  {
    icon: Send,
    label: "Fund Wallet",
    sub: "Top-up",
    amount: "+$500.00",
  },
];

export default function ForTravelers() {
  return (
    <section
      id="features"
      className="py-36 px-6"
      style={{ background: "white" }}
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
            className="uppercase tracking-[0.35em] text-sm font-semibold"
            style={{ color: BRAND.amber }}
          >
            FOR TRAVELERS
          </p>

          <h2
            className="mt-6 text-5xl md:text-6xl font-black"
            style={{ color: BRAND.indigo }}
          >
            Built for Every African Journey
          </h2>

          <p className="mt-8 max-w-3xl mx-auto text-lg leading-8 text-slate-600">
            Whether you&apos;re exploring a new city, booking a safari, paying
            for transport or discovering hidden destinations, KwanPay keeps
            every payment simple and secure.
          </p>
        </motion.div>

        {/* Split Layout: Story + Phone Mockup */}
        <div className="grid lg:grid-cols-2 gap-16 items-center mt-24">

          {/* Left — copy, checklist, mini CTA */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
          >
            <h3
              className="text-3xl md:text-4xl font-black leading-tight"
              style={{ color: BRAND.indigo }}
            >
              Your entire trip.
              <br />
              One wallet.
            </h3>

            <p className="mt-6 text-lg text-slate-600 leading-8">
              From the first booking to the final ride home, KwanPay stays with
              you—covering every payment across your journey.
            </p>

            <ul className="mt-10 grid grid-cols-1 sm:grid-cols-2 gap-4">
              {checklist.map((item) => (
                <li
                  key={item}
                  className="flex items-center gap-3"
                >
                  <span
                    className="w-8 h-8 rounded-full flex items-center justify-center shrink-0"
                    style={{ background: "rgba(217,142,59,0.12)" }}
                  >
                    <Check size={16} color={BRAND.amber} />
                  </span>
                  <span
                    className="font-semibold text-lg"
                    style={{ color: BRAND.indigo }}
                  >
                    {item}
                  </span>
                </li>
              ))}
            </ul>

            <div className="mt-12 flex items-center gap-3 flex-wrap">
              <span className="text-lg text-slate-600">
                Experience the future of travel payments.
              </span>
              <Link
                href="/demo"
                className="inline-flex items-center gap-2 font-semibold transition-colors hover:opacity-70"
                style={{ color: BRAND.amber }}
              >
                Request a Demo
                <ArrowRight size={18} />
              </Link>
            </div>
          </motion.div>

          {/* Right — phone mockup placeholder */}
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            className="flex justify-center"
          >
            <div className="relative">
              {/* Glow */}
              <div
                className="absolute -inset-8 rounded-[3.5rem] opacity-40 blur-3xl"
                style={{
                  background:
                    "radial-gradient(circle, rgba(217,142,59,.35), rgba(30,35,64,.15) 70%)",
                }}
              />

              {/* Phone frame */}
              <div
                className="relative w-[300px] sm:w-[330px] rounded-[3rem] border-[10px] p-4 bg-white shadow-2xl"
                style={{ borderColor: BRAND.indigo }}
              >
                {/* Notch */}
                <div
                  className="mx-auto w-24 h-6 rounded-b-2xl"
                  style={{ background: BRAND.indigo }}
                />

                {/* Screen */}
                <div className="mt-6">
                  {/* Greeting */}
                  <div className="flex items-center justify-between">
                    <div>
                      <p
                        className="text-[11px] font-semibold uppercase tracking-widest"
                        style={{ color: BRAND.amber }}
                      >
                        Good Morning
                      </p>
                      <p
                        className="text-lg font-bold"
                        style={{ color: BRAND.indigo }}
                      >
                        Welcome back, Ama
                      </p>
                    </div>
                    <div
                      className="w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold text-white"
                      style={{ background: BRAND.amber }}
                    >
                      A
                    </div>
                  </div>

                  {/* Balance card */}
                  <div
                    className="relative mt-5 rounded-3xl p-6 overflow-hidden"
                    style={{
                      background:
                        "linear-gradient(135deg, #1E2340, #13162B 60%, #2a2240)",
                      boxShadow: "0 16px 40px -12px rgba(30,35,64,.55)",
                    }}
                  >
                    {/* decorative radial */}
                    <div
                      className="absolute -top-10 -right-10 w-32 h-32 rounded-full opacity-40 blur-2xl"
                      style={{
                        background:
                          "radial-gradient(circle, rgba(217,142,59,.6), transparent 70%)",
                      }}
                    />

                    <div className="relative flex items-center justify-between">
                      <p className="text-xs text-white/60">Total Balance</p>
                      <span className="inline-flex items-center gap-1 text-[10px] font-semibold text-white/70">
                        <span
                          className="w-1.5 h-1.5 rounded-full"
                          style={{ background: "#4ADE80" }}
                        />
                        Active
                      </span>
                    </div>
                    <p className="relative mt-1 text-3xl font-black text-white tracking-tight">
                      $2,450.80
                    </p>

                    <div className="relative flex gap-2 mt-6">
                      <span
                        className="inline-flex items-center gap-1.5 rounded-full px-4 py-2 text-xs font-semibold text-white shadow-lg"
                        style={{
                          background:
                            "linear-gradient(135deg, #D98E3B, #B56F28)",
                        }}
                      >
                        <Send size={13} /> Send
                      </span>
                      <span className="inline-flex items-center gap-1.5 rounded-full px-4 py-2 text-xs font-semibold text-white bg-white/15 backdrop-blur">
                        <Plus size={13} /> Top Up
                      </span>
                    </div>
                  </div>

                  {/* Transactions */}
                  <div className="mt-6 space-y-4">
                    <p
                      className="text-[11px] font-semibold uppercase tracking-widest"
                      style={{ color: BRAND.indigo }}
                    >
                      Recent Activity
                    </p>

                    {transactions.map((tx) => {
                      const Icon = tx.icon;
                      return (
                        <div
                          key={tx.label}
                          className="flex items-center gap-3"
                        >
                          <span
                            className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                            style={{ background: "rgba(217,142,59,0.12)" }}
                          >
                            <Icon size={18} color={BRAND.amber} />
                          </span>
                          <div className="flex-1 min-w-0">
                            <p
                              className="text-sm font-semibold truncate"
                              style={{ color: BRAND.indigo }}
                            >
                              {tx.label}
                            </p>
                            <p className="text-xs text-slate-400">
                              {tx.sub}
                            </p>
                          </div>
                          <p className="text-sm font-bold text-slate-600">
                            {tx.amount}
                          </p>
                        </div>
                      );
                    })}
                  </div>
                </div>
              </div>

              {/* Caption */}
              <p className="mt-6 text-center text-sm font-medium text-slate-500">
                Your dashboard, wallet &amp; send money — in one place.
              </p>
            </div>
          </motion.div>

        </div>

        {/* Four Experience Cards */}
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 mt-24">

          {experiences.map((item, index) => {
            const Icon = item.icon;

            return (
              <motion.div
                key={item.title}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
className="group relative rounded-3xl bg-white border border-slate-200 p-10 shadow-lg hover:shadow-2xl hover:-translate-y-2 transition-all duration-500 overflow-hidden"
              >
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
                  className="mt-6 text-2xl font-bold"
                  style={{ color: BRAND.indigo }}
                >
                  {item.title}
                </h3>

                <p className="mt-4 leading-7 text-slate-600">
                  {item.description}
                </p>
              </motion.div>
            );
          })}

        </div>

      </div>
    </section>
  );
}
