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
      className="border-y"
      style={{
        background: "#ffffff",
        borderColor: "#ECECEC",
      }}
    >
      <div className="max-w-7xl mx-auto px-6 py-5">

        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">

          {items.map((item) => {
            const Icon = item.icon;

            return (
              <div
                key={item.title}
                className="flex items-center justify-center gap-3"
              >
                <Icon
                  size={20}
                  color={BRAND.amber}
                />

                <span
                  className="font-medium"
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
