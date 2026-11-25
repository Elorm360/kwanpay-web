import { BookCheck, Clock, Lock, ShieldCheck } from "lucide-react";

import { Eyebrow, Heading, Lead, Section } from "@/components/ui/Section";

const facts = [
  {
    icon: BookCheck,
    title: "A ledger that always balances",
    body: "Every movement is recorded as matching entries that must net to zero. Any balance can be recomputed from its history, and we check that automatically.",
  },
  {
    icon: Clock,
    title: "Nothing credited until it's confirmed",
    body: "Top-ups reach your balance only after the payment partner confirms them. Pending means pending, never money you might lose later.",
  },
  {
    icon: Lock,
    title: "Balances can't be edited",
    body: "Money only moves through audited server functions. The app itself has no way to change a balance, and records can't be rewritten.",
  },
  {
    icon: ShieldCheck,
    title: "Your data, kept minimal",
    body: "We collect what we need to run your wallet, never sell it, and don't use advertising trackers.",
  },
];

export default function TrustFacts() {
  return (
    <Section id="trust" tone="paper">
      <div className="grid gap-12 lg:grid-cols-[0.8fr_1.2fr]">
        <div>
          <Eyebrow>Security</Eyebrow>
          <Heading>Built so the money always adds up.</Heading>
          <Lead>
            Trust in a wallet comes from how it&apos;s built, not from badges.
            Here is what happens behind every payment.
          </Lead>
        </div>

        <div className="grid gap-4 sm:grid-cols-2">
          {facts.map(({ icon: Icon, title, body }) => (
            <article key={title} className="rounded-card bg-white p-6 shadow-card">
              <span className="flex h-10 w-10 items-center justify-center rounded-control bg-amber-tint text-amber-deep">
                <Icon size={20} aria-hidden />
              </span>
              <h3 className="mt-5 text-lg font-bold text-ink">{title}</h3>
              <p className="mt-2 leading-7 text-charcoal/75">{body}</p>
            </article>
          ))}
        </div>
      </div>
    </Section>
  );
}
