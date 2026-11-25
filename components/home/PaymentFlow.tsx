import { Eyebrow, Heading, Lead, Section } from "@/components/ui/Section";

const steps = [
  {
    title: "You pay in the app",
    body: "Pay for a tour, a stay or a ride from your KwanPay balance, in cedis or dollars. You see the exact amount before you confirm.",
  },
  {
    title: "KwanPay records and settles it",
    body: "Each payment is written to a double-entry ledger, so every balance always adds up, and settles over the Stellar network.",
  },
  {
    title: "The business gets paid",
    body: "The operator sees the payment straight away, matched to the booking, with a clear record for their books.",
  },
];

export default function PaymentFlow() {
  return (
    <Section id="how-it-works" tone="ink">
      <Eyebrow onDark>How it works</Eyebrow>
      <Heading onDark>How a payment moves.</Heading>
      <Lead onDark>
        No cash hand-offs, no card that might be declined, no &ldquo;did it go
        through?&rdquo;. Three steps, visible to both sides.
      </Lead>

      <ol className="mt-14 grid gap-px overflow-hidden rounded-card bg-white/10 md:grid-cols-3">
        {steps.map((step, index) => (
          <li key={step.title} className="bg-ink p-8">
            <span className="font-mono text-sm font-semibold text-amber">
              0{index + 1}
            </span>
            <h3 className="mt-4 text-xl font-bold text-white">{step.title}</h3>
            <p className="mt-3 leading-7 text-white/70">{step.body}</p>
          </li>
        ))}
      </ol>
    </Section>
  );
}
