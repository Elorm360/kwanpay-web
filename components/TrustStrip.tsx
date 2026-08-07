"use client";

import { ShieldCheck, Wallet, Globe2, Sparkles } from "lucide-react";
import { BRAND } from "@/lib/brand";

const items = [
  {
    icon: Wallet,
    title: "Travel Wallet",
  },
  {
    icon: Globe2,
    title: "Built for Africa",
  },
  {
    icon: ShieldCheck,
    title: "Secure Payments",
  },
  {
    icon: Sparkles,
    title: "Private Beta",
  },
];

export default function TrustStrip() {
  return (
    <section
      className="relative border-y overflow-hidden"
      style={{
        background:
          "linear-gradient(180deg, #FFFFFF, #FBFBFC)",
        borderColor: "#ECECEC",
      }}
    >
      {/* Top gradient hairline */}
      <div
        className="absolute top-0 left-0 right-0 h-px"
        style={{
          background:
            "linear-gradient(90deg, transparent, rgba(217,142,59,.4), transparent)",
        }}
      />

      <div className="max-w-7xl mx-auto px-6 py-6">

        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">

          {items.map((item) => {
            const Icon = item.icon;

            return (
              <div
                key={item.title}
                className="group flex items-center justify-center gap-3"
              >
                <span
                  className="relative flex items-center justify-center w-9 h-9 rounded-xl transition-all duration-300 group-hover:-translate-y-0.5"
                  style={{
                    background:
                      "linear-gradient(135deg, rgba(217,142,59,.15), rgba(30,35,64,.06))",
                  }}
                >
                  <Icon size={18} color={BRAND.amber} />
                </span>

                <span
                  className="font-semibold text-sm tracking-wide"
                  style={{
                    color: BRAND.indigo,
                  }}
                >
                  {item.title}
                </span>
              </div>
            );
          })}

        </div>

      </div>
    </section>
  );
}
