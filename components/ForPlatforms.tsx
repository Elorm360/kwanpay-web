"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import {
  Banknote,
  Globe,
  Receipt,
  TrendingUp,
  Check,
  ArrowRight,
  DollarSign,
  Users,
  CalendarDays,
} from "lucide-react";
import { BRAND } from "@/lib/brand";

const benefits = [
  {
    icon: Banknote,
    title: "Get Paid Faster",
    description:
      "Receive payments quickly so you can focus on delivering exceptional travel experiences.",
  },
  {
    icon: Globe,
    title: "Reach Global Travelers",
    description:
      "Accept payments from travelers visiting Africa without complicated payment processes.",
  },
  {
    icon: Receipt,
    title: "Automatic Records",
    description:
      "Every payment is securely recorded, making reconciliation and reporting much easier.",
  },
  {
    icon: TrendingUp,
    title: "Grow Your Business",
    description:
      "Spend less time chasing payments and more time growing your tourism business.",
  },
];

const checklist = [
  "Faster Payments",
  "Better Cash Flow",
  "Trusted Customers",
  "Digital Records",
];

const bars = [42, 58, 50, 72, 64, 88, 95];

const recentPayments = [
  { name: "Safari Booking", customer: "Liam • UK", amount: "$1,240.00", status: "Paid" },
  { name: "Hotel Stay", customer: "Amara • NG", amount: "$780.00", status: "Paid" },
  { name: "City Tour", customer: "Noah • US", amount: "$350.00", status: "Pending" },
];

export default function ForPlatforms() {
  return (
    <section
      id="platforms"
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
            FOR TOURISM BUSINESSES
          </p>

          <h2
            className="mt-6 text-5xl md:text-6xl font-black leading-tight"
            style={{ color: BRAND.indigo }}
          >
            Built for Tourism Businesses
          </h2>

          <p className="mt-8 max-w-3xl mx-auto text-lg leading-8 text-slate-600">
            Whether you manage tours, operate a hotel, run a transport service
            or offer unforgettable experiences, KwanPay helps you get paid
            faster and serve international travelers with confidence.
          </p>
        </motion.div>

        {/* Split Layout: Story + Dashboard Mockup */}
        <div className="grid lg:grid-cols-2 gap-16 items-center mt-24">

          {/* Left — copy + checklist */}
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
              Get paid faster.
              <br />
              Grow with confidence.
            </h3>

            <p className="mt-6 text-lg text-slate-600 leading-8">
              KwanPay gives tourism businesses a simple way to accept payments
              from travelers around the world — with cash flow you can rely on.
            </p>

            <ul className="mt-10 grid grid-cols-1 sm:grid-cols-2 gap-4">
              {checklist.map((item) => (
                <li key={item} className="flex items-center gap-3">
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
          </motion.div>

          {/* Right — dashboard mockup */}
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            className="flex justify-center"
          >
            <div className="relative w-full max-w-lg">
              {/* Glow */}
              <div
                className="absolute -inset-8 rounded-[3rem] opacity-40 blur-3xl"
                style={{
                  background:
                    "radial-gradient(circle, rgba(217,142,59,.35), rgba(30,35,64,.15) 70%)",
                }}
              />

              {/* Dashboard frame */}
              <div
                className="relative rounded-[2.5rem] border-[10px] bg-white p-6 shadow-2xl"
                style={{ borderColor: BRAND.indigo }}
              >
                {/* Top bar */}
                <div className="flex items-center justify-between">
                  <div>
                    <p
                      className="text-[11px] font-semibold uppercase tracking-widest"
                      style={{ color: BRAND.amber }}
                    >
                      Business Dashboard
                    </p>
                    <p
                      className="text-lg font-bold"
                      style={{ color: BRAND.indigo }}
                    >
                      Serengeti Safaris Ltd.
                    </p>
                  </div>
                  <div
                    className="w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold text-white"
                    style={{ background: BRAND.amber }}
                  >
                    S
                  </div>
                </div>

                {/* KPI cards */}
                <div className="grid grid-cols-3 gap-3 mt-6">
                  {[
                    { icon: DollarSign, label: "Revenue", value: "$12.4k" },
                    { icon: Banknote, label: "Payouts", value: "$9.8k" },
                    { icon: Users, label: "Customers", value: "342" },
                  ].map((kpi) => {
                    const KpiIcon = kpi.icon;
                    return (
                      <div
                        key={kpi.label}
                        className="rounded-2xl border border-slate-200 p-3"
                      >
                        <KpiIcon size={16} color={BRAND.amber} />
                        <p
                          className="mt-2 text-sm font-black"
                          style={{ color: BRAND.indigo }}
                        >
                          {kpi.value}
                        </p>
                        <p className="text-[10px] text-slate-400">
                          {kpi.label}
                        </p>
                      </div>
                    );
                  })}
                </div>

                {/* Bar chart */}
                <div className="mt-6 rounded-2xl border border-slate-200 p-5">
                  <div className="flex items-center justify-between">
                    <p
                      className="text-xs font-semibold"
                      style={{ color: BRAND.indigo }}
                    >
                      Revenue — Last 7 Days
                    </p>
                    <CalendarDays size={14} color={BRAND.amber} />
                  </div>
                  <div className="flex items-end justify-between gap-2 h-24 mt-4">
                    {bars.map((height, i) => (
                      <div
                        key={i}
                        className="flex-1 rounded-t-lg"
                        style={{
                          height: `${height}%`,
                          background:
                            i === bars.length - 1
                              ? BRAND.amber
                              : "rgba(30,35,64,0.15)",
                        }}
                      />
                    ))}
                  </div>
                </div>

                {/* Recent payments */}
                <div className="mt-6 space-y-3">
                  <p
                    className="text-[11px] font-semibold uppercase tracking-widest"
                    style={{ color: BRAND.indigo }}
                  >
                    Recent Payments
                  </p>

                  {recentPayments.map((p) => (
                    <div
                      key={p.name}
                      className="flex items-center justify-between gap-3 rounded-xl border border-slate-200 px-4 py-3"
                    >
                      <div className="min-w-0">
                        <p
                          className="text-sm font-semibold truncate"
                          style={{ color: BRAND.indigo }}
                        >
                          {p.name}
                        </p>
                        <p className="text-xs text-slate-400">{p.customer}</p>
                      </div>
                      <div className="text-right shrink-0">
                        <p className="text-sm font-bold text-slate-600">
                          {p.amount}
                        </p>
                        <p
                          className="text-[10px] font-semibold"
                          style={{
                            color:
                              p.status === "Paid" ? BRAND.amber : "#94A3B8",
                          }}
                        >
                          {p.status}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <p className="mt-6 text-center text-sm font-medium text-slate-500">
                Payouts, revenue &amp; customer records — in one dashboard.
              </p>
            </div>
          </motion.div>

        </div>

        {/* Four Business Benefit Cards */}
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 mt-24">

          {benefits.map((item, index) => {
            const Icon = item.icon;

            return (
              <motion.div
                key={item.title}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
                className="group rounded-3xl bg-white border border-slate-200 p-10 shadow-lg hover:shadow-2xl hover:-translate-y-2 transition-all duration-500"
              >
                <div
                  className="inline-flex items-center justify-center w-14 h-14 rounded-2xl"
                  style={{ background: "rgba(217,142,59,0.12)" }}
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

        {/* Highlight Box */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="mt-24 rounded-[32px] px-8 py-20 text-center overflow-hidden relative"
          style={{ background: BRAND.indigo }}
        >
          <div
            className="absolute inset-0 opacity-30"
            style={{
              background:
                "radial-gradient(circle at top right, rgba(217,142,59,.4), transparent 50%)",
            }}
          />

          <div className="relative">
            <p className="text-3xl md:text-5xl font-black text-white leading-tight">
              One platform.
              <br />
              One wallet.
            </p>
            <p className="mt-8 text-xl md:text-2xl font-semibold text-white/80">
              Thousands of tourism businesses.
              <br />
              Millions of future travelers.
            </p>
          </div>
        </motion.div>

        {/* Mini CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.15 }}
          className="mt-20 flex items-center justify-center gap-3 flex-wrap"
        >
          <span className="text-lg text-slate-600">
            Own a tourism business?
          </span>
          <Link
            href="/waitlist"
            className="inline-flex items-center gap-2 font-semibold transition-colors hover:opacity-70"
            style={{ color: BRAND.amber }}
          >
            Let&apos;s talk about becoming a KwanPay partner
            <ArrowRight size={18} />
          </Link>
        </motion.div>

      </div>
    </section>
  );
}
