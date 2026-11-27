import Link from "next/link";
import { ArrowLeft } from "lucide-react";

import { BRAND } from "@/lib/brand";

export type LegalSection = { heading: string; body: React.ReactNode };

export default function LegalPage({
  title,
  updated,
  intro,
  sections,
}: {
  title: string;
  updated: string;
  intro: React.ReactNode;
  sections: LegalSection[];
}) {
  return (
    <main id="main" className="min-h-screen px-6 py-20" style={{ background: BRAND.paper }}>
      <div className="max-w-3xl mx-auto">
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-700 transition-colors"
        >
          <ArrowLeft size={16} aria-hidden />
          Back to Home
        </Link>

        <h1
          className="mt-10 text-4xl md:text-5xl font-black tracking-tight"
          style={{ color: BRAND.indigo }}
        >
          {title}
        </h1>
        <p className="mt-4 text-sm font-medium text-slate-500">Last updated {updated}</p>

        <div className="mt-10 rounded-[2rem] bg-white p-8 md:p-12 shadow-xl border border-slate-100">
          <div className="text-slate-600 leading-8">{intro}</div>

          {sections.map((section) => (
            <section key={section.heading} className="mt-10">
              <h2 className="text-xl font-bold" style={{ color: BRAND.indigo }}>
                {section.heading}
              </h2>
              <div className="mt-3 space-y-3 text-slate-600 leading-8 [&_ul]:list-disc [&_ul]:pl-6 [&_a]:font-semibold [&_a]:text-[#B56F28] [&_a]:underline">
                {section.body}
              </div>
            </section>
          ))}
        </div>
      </div>
    </main>
  );
}
