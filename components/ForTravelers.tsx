"use client";

import { motion } from "framer-motion";
import { BRAND } from "@/lib/brand";

const travelers = [
  {
    title: "Diaspora Travelers",
    description:
      "Support family trips, homecoming events, and tourism across Africa without worrying about expensive international transfers.",
    icon: "🌍",
  },
  {
    title: "International Tourists",
    description:
      "Pay African tourism operators quickly and securely using your preferred currency before your journey begins.",
    icon: "✈️",
  },
  {
    title: "Business Travelers",
    description:
      "Simplify payments for conferences, business tours, accommodation, and transport across African destinations.",
    icon: "💼",
  },
];

export default function ForTravelers() {
  return (
    <section
      className="py-36 px-6"
      style={{ background: "white" }}
    >
      <div className="max-w-7xl mx-auto">

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center"
        >
          <p
            className="uppercase tracking-[0.35em] text-sm font-semibold"
            style={{ color: BRAND.amber }}
          >
            FOR TRAVELERS
          </p>

          <h2
            className="mt-6 text-5xl md:text-6xl font-black"
            style={{ color: BRAND.indigo }}
          >
            Built for how people actually travel.
          </h2>

          <p className="mt-8 max-w-3xl mx-auto text-lg leading-8 text-slate-600">
            Whether you're reconnecting with family, exploring Africa for the
            first time, or travelling for business, KwanPay removes the payment
            friction between you and your destination.
          </p>
        </motion.div>

        <div className="grid lg:grid-cols-3 gap-8 mt-20">

          {travelers.map((item, index) => (
            <motion.div
              key={item.title}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.15 }}
              className="group rounded-3xl bg-white border border-slate-200 p-10 shadow-lg hover:shadow-2xl hover:-translate-y-2 transition-all duration-500"
            >
              <div className="text-5xl">
                {item.icon}
              </div>

              <h3
                className="mt-8 text-2xl font-bold"
                style={{ color: BRAND.indigo }}
              >
                {item.title}
              </h3>

              <p className="mt-5 leading-8 text-slate-600">
                {item.description}
              </p>
            </motion.div>
          ))}

        </div>

      </div>
    </section>
  );
}