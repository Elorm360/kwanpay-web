import { Check, Loader2 } from "lucide-react";
import type { ReactNode } from "react";

import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import { Eyebrow } from "@/components/ui/Section";

/** Shared layout for the waitlist and demo-request pages. */
export default function FunnelLayout({
  eyebrow,
  title,
  lead,
  points,
  children,
}: {
  eyebrow: string;
  title: string;
  lead: string;
  points: string[];
  children: ReactNode;
}) {
  return (
    <>
      <Navbar />
      <main id="main" className="bg-paper px-6 pb-20 pt-28 md:pb-28 md:pt-36">
        <div className="mx-auto grid max-w-6xl gap-12 lg:grid-cols-[0.9fr_1.1fr] lg:gap-16">
          <div className="lg:pt-6">
            <Eyebrow>{eyebrow}</Eyebrow>
            <h1 className="mt-5 text-balance text-[2.4rem] font-extrabold leading-[1.06] tracking-tight text-ink md:text-5xl">
              {title}
            </h1>
            <p className="mt-5 max-w-lg text-lg leading-8 text-charcoal/80">{lead}</p>
            <ul className="mt-8 space-y-3.5">
              {points.map((point) => (
                <li key={point} className="flex gap-3 leading-7 text-charcoal">
                  <Check size={18} className="mt-1 shrink-0 text-success" aria-hidden />
                  {point}
                </li>
              ))}
            </ul>
          </div>
          <div>{children}</div>
        </div>
      </main>
      <Footer />
    </>
  );
}

export function SubmitButton({
  submitting,
  label,
  submittingLabel,
}: {
  submitting: boolean;
  label: string;
  submittingLabel: string;
}) {
  return (
    <button
      type="submit"
      disabled={submitting}
      className="inline-flex w-full items-center justify-center gap-2 rounded-full bg-amber px-6 py-4 text-base font-semibold text-ink transition-colors hover:bg-amber-deep hover:text-white disabled:cursor-wait disabled:opacity-70"
    >
      {submitting && <Loader2 size={18} className="animate-spin" aria-hidden />}
      {submitting ? submittingLabel : label}
    </button>
  );
}

export function FormError({ message }: { message: string | null }) {
  if (!message) return null;
  return (
    <p role="alert" className="rounded-control bg-danger/10 px-4 py-3 text-sm font-medium text-danger">
      {message}
    </p>
  );
}
