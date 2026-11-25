import { ArrowRight, ArrowUpRight } from "lucide-react";
import Link from "next/link";

import { Eyebrow, Heading, Lead, Section } from "@/components/ui/Section";
import { PARTNER } from "@/lib/site";

const places = [
  { name: "Accra", note: "City, culture and food. Where most trips begin." },
  { name: "Cape Coast & Elmina", note: "Castles, heritage and the coast." },
  { name: "Volta Region", note: "Waterfalls, mountains and Lake Volta." },
];

const timeline = [
  {
    when: "Now",
    what: "Private beta: wallet, cedi, dollar and naira balances, transfers and merchant payments.",
  },
  {
    when: "Next",
    what: "Mobile Money top-ups and withdrawals, ID verification and spending limits.",
  },
  {
    when: "Later",
    what: "More countries across West Africa, and payment links for every business.",
  },
];

export default function StartingPoint() {
  return (
    <Section id="ghana" tone="white">
      <Eyebrow>Where we&apos;re starting</Eyebrow>
      <Heading>Ghana first, done properly.</Heading>
      <Lead>
        We&apos;re starting with the places travelers already go, and the
        operators who host them.
      </Lead>

      <ul className="mt-12 grid gap-4 md:grid-cols-3">
        {places.map((place) => (
          <li key={place.name} className="rounded-card border border-line p-6">
            <h3 className="text-lg font-bold text-ink">{place.name}</h3>
            <p className="mt-1.5 text-charcoal/75">{place.note}</p>
          </li>
        ))}
      </ul>

      <div className="mt-14 grid gap-10 lg:grid-cols-2">
        <div>
          <h3 className="text-xl font-bold text-ink">What&apos;s live, and what&apos;s next</h3>
          <ol className="mt-6 space-y-5 border-l-2 border-line pl-6">
            {timeline.map((step) => (
              <li key={step.when} className="relative">
                <span
                  aria-hidden
                  className="absolute -left-[31px] top-1.5 h-3 w-3 rounded-full border-2 border-white bg-amber"
                />
                <p className="text-sm font-semibold text-ink">{step.when}</p>
                <p className="mt-1 leading-7 text-charcoal/75">{step.what}</p>
              </li>
            ))}
          </ol>
          <Link
            href="/roadmap"
            className="mt-6 inline-flex items-center gap-1.5 font-semibold text-ink underline decoration-line underline-offset-4 hover:decoration-ink"
          >
            See the full roadmap <ArrowRight size={16} aria-hidden />
          </Link>
        </div>

        <aside className="rounded-card bg-ink p-8 text-white">
          <p className="text-sm font-semibold text-white/60">Our partner</p>
          <h3 className="mt-3 text-2xl font-bold">{PARTNER.name}</h3>
          <p className="mt-3 leading-7 text-white/75">
            A Ghana travel company that plans trips end to end, coordinating
            tours, transport and stays with vetted local partners. Together
            we&apos;re bringing simple, trusted payments to the experiences
            travelers book in Ghana.
          </p>
          <a
            href={PARTNER.url}
            target="_blank"
            rel="noopener noreferrer"
            className="mt-6 inline-flex items-center gap-1.5 font-semibold text-amber hover:text-white"
          >
            Visit transvistaafrica.com <ArrowUpRight size={16} aria-hidden />
          </a>
        </aside>
      </div>
    </Section>
  );
}
