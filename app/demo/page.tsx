"use client";

import { useState } from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import {
  ArrowLeft,
  Mail,
  MapPin,
  Smartphone,
  User,
  Building2,
  Loader2,
  Wallet,
  Send,
  Plus,
  CheckCircle2,
} from "lucide-react";
import { BRAND } from "@/lib/brand";
import { USER_TYPES } from "@/lib/constants";
import { submitDemo } from "@/lib/demo";
import FormCard from "@/components/forms/FormCard";
import TextInput from "@/components/forms/TextInput";
import SelectInput from "@/components/forms/SelectInput";
import SuccessCard from "@/components/forms/SuccessCard";
import { fadeUp, staggerContainer } from "@/lib/motion";
import TiltCard from "@/components/TiltCard";

const transactions = [
  { label: "Serengeti Safari", sub: "Tour Operator", amount: "-$420.00" },
  { label: "City Transport", sub: "Daily Rides", amount: "-$18.50" },
  { label: "Fund Wallet", sub: "Top-up", amount: "+$500.00" },
];

export default function DemoPage() {
  const [form, setForm] = useState({
    full_name: "",
    email: "",
    country: "",
    company: "",
    user_type: "Traveler",
    message: "",
  });

  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);

    try {
      await submitDemo({
        full_name: form.full_name,
        email: form.email,
        country: form.country,
        user_type: form.user_type,
        company: form.company || null,
        message: form.message || null,
      });
      setSubmitted(true);
    } catch (err) {
      console.error("DEMO SUBMIT ERROR:", err);
      setError(
        "Something went wrong while submitting your request. Please try again."
      );
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <main
      className="min-h-screen px-6 py-20"
      style={{ background: BRAND.paper }}
    >
      {/* Ambient glow */}
      <div
        className="fixed inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(circle at 15% 10%, rgba(217,142,59,.10), transparent 40%), radial-gradient(circle at 85% 90%, rgba(30,35,64,.08), transparent 45%)",
        }}
      />

      <div className="relative max-w-7xl mx-auto">
        {/* Back link */}
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-700 transition-colors"
        >
          <ArrowLeft size={16} />
          Back to Home
        </Link>

        {/* Two-column layout */}
        <div className="grid lg:grid-cols-2 gap-14 lg:gap-20 items-start mt-10">
          {/* ---------- LEFT: copy + form ---------- */}
          <motion.div
            variants={staggerContainer(0.1)}
            initial="hidden"
            animate="show"
          >
            {/* Private Beta badge */}
            <motion.div
              variants={fadeUp}
              className="inline-flex items-center gap-2 rounded-full px-4 py-1.5 border text-xs font-bold uppercase tracking-widest"
              style={{
                borderColor: "rgba(217,142,59,0.4)",
                background: "rgba(217,142,59,0.1)",
                color: BRAND.amber,
              }}
            >
              <span
                className="w-1.5 h-1.5 rounded-full"
                style={{ background: BRAND.amber }}
              />
              Private Beta
            </motion.div>

            <motion.h1
              variants={fadeUp}
              className="mt-6 text-4xl md:text-5xl font-black tracking-tight leading-tight"
              style={{ color: BRAND.indigo }}
            >
              See KwanPay
              <br />
              in Action
            </motion.h1>

            <motion.p variants={fadeUp} className="mt-6 text-lg text-slate-600 leading-8 max-w-xl">
              Discover how KwanPay simplifies travel payments across Africa.
            </motion.p>
            <motion.p variants={fadeUp} className="mt-3 text-lg text-slate-600 leading-8 max-w-xl">
              Whether you&apos;re a traveler, tourism business or ecosystem
              partner, we&apos;d love to show you what&apos;s coming.
            </motion.p>

            {/* Form card */}
            <motion.div variants={fadeUp} className="mt-10">
              <FormCard>
                {submitted ? (
                  <SuccessCard
                    title="Thank You!"
                    messageLines={[
                      "We've received your request. Our team will contact you soon.",
                      "Meanwhile, join our Early Access community.",
                    ]}
                    primaryLabel="Join Early Access"
                    primaryHref="/waitlist"
                    icon="forward"
                  />
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-6">
                    <TextInput
                      label="Full Name"
                      icon={User}
                      value={form.full_name}
                      onChange={(v) => setForm({ ...form, full_name: v })}
                      required
                      placeholder="John Doe"
                    />

                    <TextInput
                      label="Email Address"
                      icon={Mail}
                      type="email"
                      value={form.email}
                      onChange={(v) => setForm({ ...form, email: v })}
                      required
                      placeholder="john@example.com"
                    />

                    <TextInput
                      label="Country"
                      icon={MapPin}
                      value={form.country}
                      onChange={(v) => setForm({ ...form, country: v })}
                      required
                      placeholder="Ghana"
                    />

                    <TextInput
                      label="Company"
                      icon={Building2}
                      value={form.company}
                      onChange={(v) => setForm({ ...form, company: v })}
                      optional
                      placeholder="Acme Travel Ltd."
                    />

                    <SelectInput
                      label="I am a..."
                      icon={User}
                      options={USER_TYPES}
                      value={form.user_type}
                      onChange={(v) => setForm({ ...form, user_type: v })}
                      required
                    />

                    <TextInput
                      label="Message"
                      icon={User}
                      value={form.message}
                      onChange={(v) => setForm({ ...form, message: v })}
                      textarea
                      placeholder="Tell us a little about what you're looking for..."
                    />

                    {error && (
                      <p className="text-sm font-medium text-red-600">{error}</p>
                    )}

                    <motion.button
                      type="submit"
                      disabled={submitting}
                      whileHover={submitting ? {} : { scale: 1.02, y: -2 }}
                      whileTap={submitting ? {} : { scale: 0.98 }}
                      transition={{ type: "spring", stiffness: 340, damping: 22 }}
                      className="w-full rounded-full py-4 text-lg font-semibold text-white disabled:opacity-60 inline-flex items-center justify-center gap-2"
                      style={{
                        background:
                          "linear-gradient(135deg, #D98E3B, #B56F28)",
                        boxShadow: "0 10px 30px -8px rgba(217,142,59,.6)",
                      }}
                    >
                      {submitting ? (
                        <>
                          <Loader2 size={20} className="animate-spin" />
                          Requesting...
                        </>
                      ) : (
                        "Request My Demo"
                      )}
                    </motion.button>
                  </form>
                )}
              </FormCard>
            </motion.div>
          </motion.div>

          {/* ---------- RIGHT: phone mockup placeholder ---------- */}
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.15 }}
            className="hidden lg:flex justify-center lg:sticky lg:top-24"
            style={{ perspective: 1000 }}
          >
            <TiltCard className="relative" maxTilt={6}>
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
                  {/* Header with badge */}
                  <div className="flex items-center justify-between">
                    <div>
                      <p
                        className="text-[11px] font-semibold uppercase tracking-widest"
                        style={{ color: BRAND.amber }}
                      >
                        KwanPay
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

                  {/* Recent activity */}
                  <div className="mt-6 space-y-4">
                    <p
                      className="text-[11px] font-semibold uppercase tracking-widest"
                      style={{ color: BRAND.indigo }}
                    >
                      Recent Activity
                    </p>
                    {transactions.map((tx) => (
                      <div key={tx.label} className="flex items-center gap-3">
                        <span
                          className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                          style={{ background: "rgba(217,142,59,0.12)" }}
                        >
                          <Wallet size={18} color={BRAND.amber} />
                        </span>
                        <div className="flex-1 min-w-0">
                          <p
                            className="text-sm font-semibold truncate"
                            style={{ color: BRAND.indigo }}
                          >
                            {tx.label}
                          </p>
                          <p className="text-xs text-slate-400">{tx.sub}</p>
                        </div>
                        <p className="text-sm font-bold text-slate-600">
                          {tx.amount}
                        </p>
                      </div>
                    ))}
                  </div>

                  {/* Dashboard placeholder chip */}
                  <div
                    className="mt-6 flex items-center gap-2 rounded-2xl border px-4 py-3"
                    style={{
                      borderColor: "rgba(217,142,59,0.3)",
                      background: "rgba(217,142,59,0.06)",
                    }}
                  >
                    <CheckCircle2 size={16} style={{ color: BRAND.amber }} />
                    <p className="text-xs font-medium text-slate-600">
                      Dashboard screenshot placeholder
                    </p>
                  </div>
                </div>
              </div>

              {/* Caption */}
              <p className="mt-6 text-center text-sm font-medium text-slate-500">
                Your travel wallet &amp; dashboard — in one place.
              </p>
            </TiltCard>
          </motion.div>
        </div>

        {/* Mobile illustration hint */}
        <div className="lg:hidden mt-12 text-center">
          <div className="inline-flex items-center gap-2 text-sm font-medium text-slate-500">
            <Smartphone size={16} style={{ color: BRAND.amber }} />
            See the KwanPay dashboard on desktop.
          </div>
        </div>
      </div>
    </main>
  );
}
