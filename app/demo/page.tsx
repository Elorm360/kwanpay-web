"use client";

import { useState } from "react";
import { Building2, Mail, MapPin, MessageSquare, User, Users } from "lucide-react";

import FormCard from "@/components/forms/FormCard";
import FunnelLayout, { FormError, SubmitButton } from "@/components/forms/FunnelLayout";
import Honeypot from "@/components/forms/Honeypot";
import SelectInput from "@/components/forms/SelectInput";
import SuccessCard from "@/components/forms/SuccessCard";
import TextInput from "@/components/forms/TextInput";
import { USER_TYPES } from "@/lib/constants";
import { submitDemo, type DemoRequestData } from "@/lib/demo";

export default function DemoPage() {
  const [form, setForm] = useState({
    full_name: "",
    email: "",
    country: "",
    company: "",
    user_type: "Tourism Business" as DemoRequestData["user_type"],
    message: "",
  });
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [honeypot, setHoneypot] = useState("");

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);

    try {
      await submitDemo(
        {
          full_name: form.full_name,
          email: form.email,
          country: form.country,
          user_type: form.user_type,
          company: form.company || null,
          message: form.message || null,
        },
        honeypot
      );
      setSubmitted(true);
    } catch (err) {
      setError(
        err instanceof Error && err.message
          ? err.message
          : "Something went wrong while sending your request. Please try again."
      );
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <FunnelLayout
      eyebrow="Request a demo"
      title="See how KwanPay works for your business."
      lead="Tell us a little about you. We'll set up a short call, walk you through the app and answer your questions."
      points={[
        "A short walkthrough on a video call",
        "See how travelers pay you and how payments reach your books",
        "Partners of TransVista Africa get priority",
      ]}
    >
      <FormCard>
        {submitted ? (
          <SuccessCard
            title="Thanks, we've got your request."
            messageLines={[
              "We'll email you to arrange a time that suits you.",
              "In the meantime, you can join early access for the app.",
            ]}
            primaryLabel="Join early access"
            primaryHref="/waitlist"
          />
        ) : (
          <form onSubmit={handleSubmit} className="relative space-y-5">
            <Honeypot value={honeypot} onChange={setHoneypot} />

            <div className="grid gap-5 sm:grid-cols-2">
              <TextInput
                label="Full name"
                icon={User}
                name="full_name"
                autoComplete="name"
                minLength={2}
                maxLength={100}
                value={form.full_name}
                onChange={(v) => setForm({ ...form, full_name: v })}
                required
                placeholder="Kwame Mensah"
              />
              <TextInput
                label="Work email"
                icon={Mail}
                type="email"
                name="email"
                autoComplete="email"
                maxLength={254}
                value={form.email}
                onChange={(v) => setForm({ ...form, email: v })}
                required
                placeholder="you@company.com"
              />
            </div>

            <div className="grid gap-5 sm:grid-cols-2">
              <TextInput
                label="Business name"
                icon={Building2}
                name="company"
                autoComplete="organization"
                maxLength={150}
                value={form.company}
                onChange={(v) => setForm({ ...form, company: v })}
                optional
                placeholder="Coastline Tours"
              />
              <TextInput
                label="Country"
                icon={MapPin}
                name="country"
                autoComplete="country-name"
                minLength={2}
                maxLength={100}
                value={form.country}
                onChange={(v) => setForm({ ...form, country: v })}
                required
                placeholder="Ghana"
              />
            </div>

            <SelectInput
              label="I am a"
              icon={Users}
              name="user_type"
              options={USER_TYPES}
              value={form.user_type}
              onChange={(v) => setForm({ ...form, user_type: v as DemoRequestData["user_type"] })}
              required
            />

            <TextInput
              label="What would you like to know?"
              icon={MessageSquare}
              name="message"
              maxLength={2000}
              optional
              textarea
              rows={4}
              value={form.message}
              onChange={(v) => setForm({ ...form, message: v })}
              placeholder="For example: how payouts work, or how to accept payments for group tours."
            />

            <FormError message={error} />
            <SubmitButton submitting={submitting} label="Request a demo" submittingLabel="Sending…" />
            <p className="text-center text-xs leading-5 text-muted">
              We&apos;ll only use your details to arrange the demo. See our{" "}
              <a href="/privacy" className="underline underline-offset-2">
                privacy policy
              </a>
              .
            </p>
          </form>
        )}
      </FormCard>
    </FunnelLayout>
  );
}
