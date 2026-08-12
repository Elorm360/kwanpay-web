"use client";

import { useState } from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import { ArrowLeft, Mail, MapPin, User, Loader2 } from "lucide-react";
import { BRAND } from "@/lib/brand";
import { USER_TYPES } from "@/lib/constants";
import { submitWaitlist } from "@/lib/waitlist";
import type { WaitlistRequestData } from "@/lib/waitlist-schema";
import FormCard from "@/components/forms/FormCard";
import TextInput from "@/components/forms/TextInput";
import SelectInput from "@/components/forms/SelectInput";
import SuccessCard from "@/components/forms/SuccessCard";
import { fadeUp, staggerContainer } from "@/lib/motion";

export default function WaitlistPage() {
  const [form, setForm] = useState<WaitlistRequestData>({
    full_name: "",
    email: "",
    country: "",
    role: "Traveler",
  });

  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);

    try {
      await submitWaitlist({
        full_name: form.full_name,
        email: form.email,
        country: form.country,
        role: form.role,
      });
      setSubmitted(true);
    } catch (err) {
      console.error("WAITLIST SUBMIT ERROR:", err);
      setError(
        "Something went wrong while joining the waitlist. Please try again."
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

      <motion.div
        variants={staggerContainer(0.12)}
        initial="hidden"
        animate="show"
        className="relative max-w-3xl mx-auto"
      >
        {/* Back link */}
        <motion.div variants={fadeUp}>
          <Link
            href="/"
            className="inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-700 transition-colors"
          >
            <ArrowLeft size={16} />
            Back to Home
          </Link>
        </motion.div>

        {/* Header */}
        <motion.div variants={fadeUp} className="mt-10">
          {/* Private Beta badge */}
          <div
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
          </div>

          <h1
            className="mt-6 text-4xl md:text-5xl font-black tracking-tight leading-tight"
            style={{ color: BRAND.indigo }}
          >
            Join the KwanPay
            <br />
            Early Access Community
          </h1>

          <p className="mt-6 text-lg text-slate-600 leading-8 max-w-2xl">
            Be among the first travelers, tourism businesses and partners to
            experience borderless travel payments across Africa.
          </p>
        </motion.div>

        {/* Form card */}
        <motion.div variants={fadeUp} className="mt-12">
          <FormCard>
            {submitted ? (
              <SuccessCard
                title="You're on the list!"
                messageLines={[
                  "Thank you for joining the KwanPay Early Access community.",
                  "We'll keep you updated as we prepare for launch.",
                ]}
                primaryLabel="Return Home"
                primaryHref="/"
                icon="home"
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

                <SelectInput
                  label="I am a..."
                  icon={User}
                  options={USER_TYPES}
                  value={form.role}
                  onChange={(v) =>
                    setForm({
                      ...form,
                      role: v as WaitlistRequestData["role"],
                    })
                  }
                  required
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
                    background: "linear-gradient(135deg, #D98E3B, #B56F28)",
                    boxShadow: "0 10px 30px -8px rgba(217,142,59,.6)",
                  }}
                >
                  {submitting ? (
                    <>
                      <Loader2 size={20} className="animate-spin" />
                      Joining...
                    </>
                  ) : (
                    "Join Early Access"
                  )}
                </motion.button>
              </form>
            )}
          </FormCard>
        </motion.div>

        {/* Applications open note */}
        <motion.p
          variants={fadeUp}
          className="mt-8 text-center text-sm font-medium text-slate-500"
        >
          Applications Now Open
        </motion.p>
      </motion.div>
    </main>
  );
}
