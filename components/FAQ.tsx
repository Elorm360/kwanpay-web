import { Plus } from "lucide-react";

import JsonLd from "@/components/JsonLd";
import { ButtonLink } from "@/components/ui/Button";
import { Eyebrow, Heading, Lead, Section } from "@/components/ui/Section";
import { CONTACT_EMAIL } from "@/lib/site";

type Faq = { question: string; answer: string };

const faqs: Faq[] = [
  {
    question: "What is KwanPay?",
    answer:
      "KwanPay is a travel wallet for Africa. Travelers fund one wallet and use it to pay for transport, tours, hotels and experiences, while tourism businesses receive payments faster and with clear records.",
  },
  {
    question: "Is KwanPay available today?",
    answer:
      "KwanPay is in private beta. Join the early access list and we will invite you as we open access in more countries.",
  },
  {
    question: "How do I add money to my wallet?",
    answer:
      "Mobile Money top-ups and withdrawals (MTN, Telecel and AirtelTigo) are next on our roadmap, starting in Ghana. Early access members will hear first when they open.",
  },
  {
    question: "Why is KwanPay built on Stellar?",
    answer:
      "Stellar is a payment network designed for fast, low-cost cross-border transfers with stable digital dollars such as USDC. It lets us settle payments between travelers and businesses quickly and transparently.",
  },
  {
    question: "I run a tour, hotel or transport business. Can I accept KwanPay?",
    answer:
      "Yes, merchant payments are on our roadmap. Request a demo and our team will walk you through how KwanPay can help you get paid by travelers from anywhere.",
  },
  {
    question: "How is my information protected?",
    answer:
      "Accounts are protected by secure authentication, wallet changes go through server-side checks, and we only collect what we need to run the service. Our privacy policy explains what we collect and why.",
  },
];

export default function FAQ() {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((faq) => ({
      "@type": "Question",
      name: faq.question,
      acceptedAnswer: { "@type": "Answer", text: faq.answer },
    })),
  };

  return (
    <Section id="faq" tone="paper">
      <JsonLd data={jsonLd} />

      <div className="grid gap-12 lg:grid-cols-[0.8fr_1.2fr] lg:gap-16">
        <div>
          <Eyebrow>FAQ</Eyebrow>
          <Heading>Questions, answered.</Heading>
          <Lead>
            What to know about KwanPay during the private beta. Can&apos;t find
            your answer?
          </Lead>
          <div className="mt-8 flex flex-wrap gap-3">
            <ButtonLink href="/demo" variant="primary">
              Talk to the team
            </ButtonLink>
            <ButtonLink href={`mailto:${CONTACT_EMAIL}`} variant="secondary" external>
              Email us
            </ButtonLink>
          </div>
        </div>

        <div className="space-y-3">
          {faqs.map((faq, index) => (
            <details
              key={faq.question}
              open={index === 0}
              className="group rounded-card border border-line bg-white px-6 py-5 open:shadow-card"
            >
              <summary className="flex cursor-pointer list-none items-center justify-between gap-6 [&::-webkit-details-marker]:hidden">
                <h3 className="text-lg font-bold leading-7 text-ink">{faq.question}</h3>
                <span
                  aria-hidden
                  className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-amber-tint text-amber-deep transition-transform duration-300 group-open:rotate-45"
                >
                  <Plus size={16} />
                </span>
              </summary>
              <p className="mt-3 pr-10 leading-7 text-charcoal/75">{faq.answer}</p>
            </details>
          ))}
        </div>
      </div>
    </Section>
  );
}
