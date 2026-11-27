import { ArrowRight, Check } from "lucide-react";

import { ButtonLink } from "@/components/ui/Button";
import { Eyebrow, Heading, Section, SoonTag } from "@/components/ui/Section";

type Item = { text: string; soon?: boolean };

const travelers: Item[] = [
  { text: "Keep cedis, dollars and naira in one wallet" },
  { text: "Convert at a rate you see before you confirm" },
  { text: "Pay vetted tour operators with your booking reference" },
  { text: "Send money to other KwanPay users by wallet ID" },
  { text: "Top up and withdraw with Mobile Money", soon: true },
];

const businesses: Item[] = [
  { text: "Get paid by travelers from anywhere, into your KwanPay account" },
  { text: "Every payment tied to a booking reference" },
  { text: "A clean payment history for reconciliation" },
  { text: "Payment links and QR codes", soon: true },
  { text: "Payouts to Mobile Money or bank", soon: true },
];

function List({ items }: { items: Item[] }) {
  return (
    <ul className="mt-6 space-y-3.5">
      {items.map((item) => (
        <li key={item.text} className="flex gap-3 leading-7">
          <Check size={18} className="mt-1 shrink-0 text-success" aria-hidden />
          <span>
            {item.text}
            {item.soon && <SoonTag />}
          </span>
        </li>
      ))}
    </ul>
  );
}

export default function Audiences() {
  return (
    <Section id="travelers" tone="white">
      <Eyebrow>Who it&apos;s for</Eyebrow>
      <Heading>One wallet, two sides of every trip.</Heading>

      <div className="mt-12 grid gap-6 md:grid-cols-2">
        <article className="rounded-card border border-line bg-paper p-8">
          <h3 className="text-2xl font-bold text-ink">For travelers</h3>
          <p className="mt-2 text-charcoal/75">
            Visiting Ghana or travelling within it.
          </p>
          <List items={travelers} />
          <ButtonLink href="/waitlist" variant="primary" className="mt-8">
            Join early access
          </ButtonLink>
        </article>

        <article className="rounded-card border border-line bg-paper p-8">
          <h3 className="text-2xl font-bold text-ink">For tourism businesses</h3>
          <p className="mt-2 text-charcoal/75">
            Tour operators, hotels, guesthouses and transport.
          </p>
          <List items={businesses} />
          <ButtonLink href="/business" variant="secondary" className="mt-8">
            How it works for businesses
            <ArrowRight size={16} aria-hidden />
          </ButtonLink>
        </article>
      </div>
    </Section>
  );
}
