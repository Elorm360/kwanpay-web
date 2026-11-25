import { Check, Circle, Hammer } from "lucide-react";

import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import ClosingCta from "@/components/home/ClosingCta";
import { Eyebrow, Section } from "@/components/ui/Section";

type Status = "done" | "progress" | "next";

type Phase = {
  title: string;
  status: Status;
  summary: string;
  items: string[];
};

// Keep in step with docs/ROADMAP.md (the engineering plan).
const phases: Phase[] = [
  {
    title: "Foundation",
    status: "done",
    summary: "The app, accounts and the basics of a wallet.",
    items: [
      "Mobile app for Android and iOS",
      "Accounts with email verification and code-based password reset",
      "Cedi, dollar and naira balances",
      "Wallet-to-wallet transfers by wallet ID",
      "Currency conversion with live rates",
    ],
  },
  {
    title: "A money core you can trust",
    status: "done",
    summary: "How balances are kept correct, behind every payment.",
    items: [
      "Double-entry ledger as the source of truth for balances",
      "Balances change only through audited server functions",
      "Automatic checks that every balance matches its history",
      "Records that can't be edited or deleted",
    ],
  },
  {
    title: "Private beta in Ghana",
    status: "progress",
    summary: "First users and first partner businesses.",
    items: [
      "Payments to tourism operators by booking reference",
      "USDC payments over the Stellar network",
      "First partner operators with TransVista Africa",
      "Early-access invitations",
    ],
  },
  {
    title: "Mobile Money and identity",
    status: "next",
    summary: "Getting money in and out, safely.",
    items: [
      "Top-ups with MTN MoMo, Telecel Cash and AirtelTigo Money",
      "Withdrawals to Mobile Money",
      "ID verification with limits per level",
      "Receipts and payment notifications",
    ],
  },
  {
    title: "Tools for businesses",
    status: "next",
    summary: "Everything an operator needs to get paid.",
    items: [
      "Payment links and QR codes",
      "Merchant dashboard on the web",
      "Payouts to bank or Mobile Money",
      "Monthly statements",
    ],
  },
  {
    title: "Public launch and expansion",
    status: "next",
    summary: "From beta to everyone, then beyond Ghana.",
    items: [
      "Play Store and App Store release",
      "Public launch in Ghana",
      "Expansion across West Africa",
      "Trip budgeting and spending insights",
    ],
  },
];

const statusStyle: Record<Status, { label: string; badge: string; icon: typeof Check; dot: string }> = {
  done: { label: "Done", badge: "bg-success/10 text-success", icon: Check, dot: "bg-success" },
  progress: { label: "In progress", badge: "bg-amber-tint text-amber-deep", icon: Hammer, dot: "bg-amber" },
  next: { label: "Planned", badge: "bg-ink/5 text-muted", icon: Circle, dot: "bg-line" },
};

export default function RoadmapPage() {
  const done = phases.filter((p) => p.status === "done").length;

  return (
    <>
      <Navbar />
      <main id="main">
        <section className="bg-paper px-6 pb-16 pt-32 md:pb-20 md:pt-40">
          <div className="mx-auto max-w-6xl">
            <Eyebrow>Roadmap</Eyebrow>
            <h1 className="mt-5 max-w-3xl text-balance text-[2.5rem] font-extrabold leading-[1.05] tracking-tight text-ink sm:text-6xl">
              What we&apos;ve built, and what&apos;s next.
            </h1>
            <p className="mt-6 max-w-2xl text-lg leading-8 text-charcoal/80">
              KwanPay is in private beta in Ghana. This page is updated as
              work ships. {done} of {phases.length} stages are done; dates
              depend on partner and regulatory steps, so we don&apos;t
              promise them.
            </p>
          </div>
        </section>

        <Section tone="white">
          <ol className="relative space-y-6 border-l-2 border-line pl-8 md:pl-12">
            {phases.map((phase, index) => {
              const style = statusStyle[phase.status];
              const Icon = style.icon;
              return (
                <li key={phase.title} className="relative">
                  <span
                    aria-hidden
                    className={`absolute -left-[41px] top-7 h-4 w-4 rounded-full border-4 border-white md:-left-[57px] ${style.dot}`}
                  />
                  <article className="rounded-card border border-line bg-paper/60 p-6 md:p-8">
                    <div className="flex flex-wrap items-center gap-3">
                      <span className="font-mono text-sm font-semibold text-muted">
                        Stage {index + 1}
                      </span>
                      <span
                        className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ${style.badge}`}
                      >
                        <Icon size={12} aria-hidden />
                        {style.label}
                      </span>
                    </div>
                    <h2 className="mt-3 text-2xl font-bold text-ink">{phase.title}</h2>
                    <p className="mt-1.5 text-charcoal/75">{phase.summary}</p>
                    <ul className="mt-5 grid gap-x-8 gap-y-2.5 sm:grid-cols-2">
                      {phase.items.map((item) => (
                        <li key={item} className="flex gap-2.5 leading-7 text-charcoal">
                          {phase.status === "done" ? (
                            <Check size={16} className="mt-1.5 shrink-0 text-success" aria-hidden />
                          ) : (
                            <span aria-hidden className="mt-3 h-1.5 w-1.5 shrink-0 rounded-full bg-muted/60" />
                          )}
                          {item}
                        </li>
                      ))}
                    </ul>
                  </article>
                </li>
              );
            })}
          </ol>
        </Section>

        <ClosingCta />
      </main>
      <Footer />
    </>
  );
}
