import { BedDouble, Bus, Check, Compass, Receipt } from "lucide-react";

import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import ClosingCta from "@/components/home/ClosingCta";
import { ButtonLink } from "@/components/ui/Button";
import { PhoneFrame } from "@/components/ui/PhoneFrame";
import { Eyebrow, Heading, Lead, Section, SoonTag } from "@/components/ui/Section";
import { pageMetadata } from "@/lib/page-metadata";
import { PARTNER } from "@/lib/site";

export const metadata = pageMetadata({
  title: "For tourism businesses",
  description:
    "Get paid by travelers in Ghana without the cash chase. KwanPay matches every payment to a booking and gives you a clean record.",
  path: "/business",
});

const kinds = [
  { icon: Compass, name: "Tour operators & guides", note: "Day trips, heritage tours, adventures." },
  { icon: BedDouble, name: "Hotels & guesthouses", note: "Deposits and balances for stays." },
  { icon: Bus, name: "Transport & transfers", note: "Airport pickups, shuttles, intercity routes." },
];

const steps = [
  {
    title: "Get set up",
    body: "We verify your business and create your KwanPay merchant account. Partners of TransVista Africa are first in line.",
  },
  {
    title: "Share your booking reference",
    body: "Travelers pay in the KwanPay app using the reference you already give them. No card machine, no cash to count.",
  },
  {
    title: "See it land, matched to the booking",
    body: "Each payment appears straight away with the booking reference, so you always know who has paid.",
  },
];

type Item = { text: string; soon?: boolean };

const features: Item[] = [
  { text: "Payments from travelers in cedis, wherever they are" },
  { text: "Every payment tied to a booking reference" },
  { text: "A payment history you can reconcile against your bookings" },
  { text: "Balances backed by a double-entry ledger" },
  { text: "Payment links and QR codes", soon: true },
  { text: "Payouts to Mobile Money or your bank account", soon: true },
  { text: "Merchant dashboard on the web", soon: true },
];

function ReceivedPreview() {
  return (
    <div className="px-4 pb-6 pt-12">
      <p className="text-[11px] text-muted">Merchant · Elmina Heritage Tours</p>
      <p className="text-[15px] font-bold text-ink">Payments today</p>
      <div className="mt-4 rounded-3xl bg-ink p-5 text-white">
        <p className="text-[11px] text-white/60">Received today</p>
        <p className="mt-1 text-[26px] font-extrabold tracking-tight tabular-nums">GHS 2,450.00</p>
        <p className="text-[11px] text-white/60">7 payments · all matched</p>
      </div>
      <ul className="mt-4 space-y-2">
        {[
          ["BK-20431", "Castle tour · 2 people", "GHS 700.00"],
          ["BK-20428", "Kakum walkway · 1", "GHS 350.00"],
          ["BK-20425", "Full-day coast tour · 4", "GHS 1,400.00"],
        ].map(([ref, what, amount]) => (
          <li key={ref} className="flex items-center gap-3 rounded-2xl bg-white p-2.5">
            <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-amber-tint text-amber-deep">
              <Receipt size={15} aria-hidden />
            </span>
            <span className="min-w-0 flex-1">
              <span className="block text-[12px] font-semibold text-ink">{ref}</span>
              <span className="block truncate text-[10px] text-muted">{what}</span>
            </span>
            <span className="text-[12px] font-semibold tabular-nums text-success">+{amount}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default function BusinessPage() {
  return (
    <>
      <Navbar />
      <main id="main">
        <section className="bg-paper px-6 pb-20 pt-32 md:pb-28 md:pt-40">
          <div className="mx-auto grid max-w-6xl items-center gap-14 lg:grid-cols-[1.15fr_0.85fr]">
            <div>
              <Eyebrow>For tourism businesses</Eyebrow>
              <h1 className="mt-5 text-balance text-[2.5rem] font-extrabold leading-[1.05] tracking-tight text-ink sm:text-6xl">
                Get paid by travelers, without the cash chase.
              </h1>
              <p className="mt-6 max-w-xl text-lg leading-8 text-charcoal/80">
                Travelers pay you in the KwanPay app with the booking reference
                you already use. You see every payment straight away, matched
                to the right booking.
              </p>
              <div className="mt-9 flex flex-wrap gap-3">
                <ButtonLink href="/demo" variant="accent">
                  Request a demo
                </ButtonLink>
                <ButtonLink href={PARTNER.url} variant="secondary" external>
                  Our partner, {PARTNER.name}
                </ButtonLink>
              </div>
            </div>
            <PhoneFrame
              label="A merchant view in KwanPay: today's payments, each matched to a booking reference"
              caption="Illustrative example with a sample business"
            >
              <ReceivedPreview />
            </PhoneFrame>
          </div>
        </section>

        <Section tone="white">
          <Eyebrow>Who it&apos;s for</Eyebrow>
          <Heading>Built for the businesses travelers book in Ghana.</Heading>
          <ul className="mt-12 grid gap-4 md:grid-cols-3">
            {kinds.map(({ icon: Icon, name, note }) => (
              <li key={name} className="rounded-card border border-line p-6">
                <Icon size={22} className="text-amber-deep" aria-hidden />
                <h3 className="mt-4 text-lg font-bold text-ink">{name}</h3>
                <p className="mt-1.5 text-charcoal/75">{note}</p>
              </li>
            ))}
          </ul>
        </Section>

        <Section tone="ink">
          <Eyebrow onDark>How it works</Eyebrow>
          <Heading onDark>Three steps to your first payment.</Heading>
          <ol className="mt-12 grid gap-px overflow-hidden rounded-card bg-white/10 md:grid-cols-3">
            {steps.map((step, index) => (
              <li key={step.title} className="bg-ink p-8">
                <span className="font-mono text-sm font-semibold text-amber">0{index + 1}</span>
                <h3 className="mt-4 text-xl font-bold text-white">{step.title}</h3>
                <p className="mt-3 leading-7 text-white/70">{step.body}</p>
              </li>
            ))}
          </ol>
        </Section>

        <Section tone="paper">
          <div className="grid gap-12 lg:grid-cols-[0.8fr_1.2fr]">
            <div>
              <Eyebrow>What you get</Eyebrow>
              <Heading>Clear money, clear records.</Heading>
              <Lead>
                Fees are being finalised with our first partners. We&apos;ll
                share them before you sign up, with no surprises.
              </Lead>
            </div>
            <ul className="space-y-3.5 self-center">
              {features.map((item) => (
                <li key={item.text} className="flex gap-3 text-lg leading-8">
                  <Check size={20} className="mt-1.5 shrink-0 text-success" aria-hidden />
                  <span>
                    {item.text}
                    {item.soon && <SoonTag />}
                  </span>
                </li>
              ))}
            </ul>
          </div>
        </Section>

        <ClosingCta />
      </main>
      <Footer />
    </>
  );
}
