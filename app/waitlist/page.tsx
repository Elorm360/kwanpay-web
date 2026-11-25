"use client";

import { useState } from "react";
import { Mail, MapPin, User, Users } from "lucide-react";

import FormCard from "@/components/forms/FormCard";
import FunnelLayout, { FormError, SubmitButton } from "@/components/forms/FunnelLayout";
import Honeypot from "@/components/forms/Honeypot";
import SelectInput from "@/components/forms/SelectInput";
import SuccessCard from "@/components/forms/SuccessCard";
import TextInput from "@/components/forms/TextInput";
import { USER_TYPES } from "@/lib/constants";
import { submitWaitlist } from "@/lib/waitlist";
import type { WaitlistRequestData } from "@/lib/waitlist-schema";

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
  const [honeypot, setHoneypot] = useState("");

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);

    try {
      await submitWaitlist(form, honeypot);
      setSubmitted(true);
    } catch (err) {
      setError(
        err instanceof Error && err.message
          ? err.message
          : "Something went wrong while joining the waitlist. Please try again."
      );
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <FunnelLayout
      eyebrow="Early access"
      title="Be among the first to use KwanPay in Ghana."
      lead="We're opening the private beta in stages. Join the list and we'll email you when there's a place for you."
      points={[
        "Free to join, no obligation",
        "Early access members hear first about each new feature",
        "We only use your details to contact you about KwanPay",
      ]}
    >
      <FormCard>
        {submitted ? (
          <SuccessCard
            title="You're on the list."
            messageLines={[
              "Thanks for joining KwanPay early access.",
              "We'll email you as soon as there's a place in the beta.",
            ]}
            primaryLabel="Back to the homepage"
            primaryHref="/"
            icon="home"
          />
        ) : (
          <form onSubmit={handleSubmit} className="relative space-y-5">
            <Honeypot value={honeypot} onChange={setHoneypot} />

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
              placeholder="Ama Owusu"
            />
            <TextInput
              label="Email address"
              icon={Mail}
              type="email"
              name="email"
              autoComplete="email"
              maxLength={254}
              value={form.email}
              onChange={(v) => setForm({ ...form, email: v })}
              required
              placeholder="you@example.com"
            />
            <TextInput
              label="Country you live in"
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
            <SelectInput
              label="I am a"
              icon={Users}
              name="role"
              options={USER_TYPES}
              value={form.role}
              onChange={(v) => setForm({ ...form, role: v as WaitlistRequestData["role"] })}
              required
            />

            <FormError message={error} />
            <SubmitButton submitting={submitting} label="Join early access" submittingLabel="Joining…" />
            <p className="text-center text-xs leading-5 text-muted">
              By joining you agree to our{" "}
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
