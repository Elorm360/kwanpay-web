import Link from "next/link";
import { Plus } from "lucide-react";

import JsonLd from "@/components/JsonLd";
import { BRAND } from "@/lib/brand";
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
      "The beta is starting with mobile money top-ups and withdrawals, beginning in Ghana. More funding methods and countries will follow as we expand.",
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
    <section id="faq" className="py-32 px-6" style={{ background: BRAND.paper }}>
      <JsonLd data={jsonLd} />

      <div className="max-w-6xl mx-auto grid lg:grid-cols-[1fr_1.6fr] gap-14 lg:gap-20">
        <div>
          <p
            className="uppercase tracking-[0.35em] text-sm font-semibold"
            style={{ color: BRAND.amber }}
          >
            FAQ
          </p>
          <h2
            className="mt-5 text-4xl md:text-5xl font-black tracking-tight leading-tight"
            style={{ color: BRAND.indigo }}
          >
            Questions, answered.
          </h2>
          <p className="mt-6 text-lg leading-8 text-slate-600 max-w-md">
            Everything you need to know about KwanPay during the private beta.
            Can&apos;t find what you&apos;re looking for?
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link
              href="/demo"
              className="rounded-full px-6 py-3 font-semibold text-white"
              style={{
                background: "linear-gradient(135deg, #D98E3B, #B56F28)",
                boxShadow: "0 10px 30px -10px rgba(217,142,59,.6)",
              }}
            >
              Talk to the team
            </Link>
            <a
              href={`mailto:${CONTACT_EMAIL}`}
              className="rounded-full px-6 py-3 font-semibold border-2 border-slate-300 bg-white/60 hover:border-amber-400 transition-colors"
              style={{ color: BRAND.indigo }}
            >
              Email us
            </a>
          </div>
        </div>

        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <details
              key={faq.question}
              open={index === 0}
              className="group rounded-3xl border border-slate-200 bg-white px-7 py-6 shadow-sm transition-shadow open:shadow-lg open:border-amber-200"
            >
              <summary className="flex cursor-pointer list-none items-center justify-between gap-6 [&::-webkit-details-marker]:hidden">
                <h3
                  className="text-lg font-bold leading-7"
                  style={{ color: BRAND.indigo }}
                >
                  {faq.question}
                </h3>
                <span
                  aria-hidden
                  className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full transition-transform duration-300 group-open:rotate-45"
                  style={{ background: "rgba(217,142,59,0.12)", color: BRAND.amber }}
                >
                  <Plus size={18} />
                </span>
              </summary>
              <p className="mt-4 pr-12 leading-7 text-slate-600">{faq.answer}</p>
            </details>
          ))}
        </div>
      </div>
    </section>
  );
}
