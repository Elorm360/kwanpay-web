"use client";

import { useRef } from "react";
import {
  motion,
  useMotionTemplate,
  useMotionValue,
  useScroll,
  useTransform,
} from "framer-motion";
import Link from "next/link";
import {
  Globe2,
  Sparkles,
  Send,
  ShieldCheck,
  BadgeCheck,
} from "lucide-react";
import { BRAND } from "@/lib/brand";
import { EASE_OUT, fadeUp, staggerContainer, viewportOnce } from "@/lib/motion";

const headline = staggerContainer(0.12, 0.35);

const word: import("framer-motion").Variants = {
  hidden: { opacity: 0, y: "100%" },
  show: { opacity: 1, y: "0%", transition: { duration: 0.8, ease: EASE_OUT } },
};

export default function Hero() {
  const sectionRef = useRef<HTMLElement>(null);
  const mx = useMotionValue(0.5);
  const my = useMotionValue(0.5);

  function handleMouseMove(e: React.MouseEvent<HTMLElement>) {
    const rect = sectionRef.current?.getBoundingClientRect();
    if (!rect) return;
    mx.set((e.clientX - rect.left) / rect.width);
    my.set((e.clientY - rect.top) / rect.height);
  }

  const spotlight = useMotionTemplate`radial-gradient(560px circle at ${useTransform(
    mx,
    (v) => `${v * 100}%`
  )} ${useTransform(my, (v) => `${v * 100}%`)}, rgba(217,142,59,.16), transparent 65%)`;

  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ["start start", "end start"],
  });
  const bgY = useTransform(scrollYProgress, [0, 1], ["0%", "30%"]);
  const contentY = useTransform(scrollYProgress, [0, 1], ["0%", "12%"]);
  const contentOpacity = useTransform(scrollYProgress, [0, 0.8], [1, 0]);

  return (
    <section
      id="hero"
      ref={sectionRef}
      onMouseMove={handleMouseMove}
      className="relative overflow-hidden pt-44 pb-36 px-6"
      style={{ background: BRAND.paper }}
    >
      {/* Background */}
      <motion.div style={{ y: bgY }} className="absolute inset-0 opacity-50">
        <div
          className="absolute inset-0"
          style={{
            background: `
            radial-gradient(circle at 20% 15%, rgba(30,35,64,.14), transparent 45%),
            radial-gradient(circle at 85% 30%, rgba(217,142,59,.16), transparent 40%),
            radial-gradient(circle at 50% 95%, rgba(217,142,59,.10), transparent 45%)
          `,
          }}
        />
      </motion.div>

      {/* Cursor spotlight */}
      <motion.div
        aria-hidden
        className="absolute inset-0 pointer-events-none hidden md:block"
        style={{ background: spotlight }}
      />

      {/* Subtle grid texture for depth */}
      <motion.div
        style={{ y: bgY }}
        className="absolute inset-0 opacity-[0.04]"
      >
        <div
          className="absolute inset-0"
          style={{
            backgroundImage:
              "linear-gradient(rgba(30,35,64,.6) 1px, transparent 1px), linear-gradient(90deg, rgba(30,35,64,.6) 1px, transparent 1px)",
            backgroundSize: "56px 56px",
          }}
        />
      </motion.div>

      <motion.div
        style={{ y: contentY, opacity: contentOpacity }}
        className="relative max-w-7xl mx-auto"
      >

        <motion.div
          variants={headline}
          initial="hidden"
          animate="show"
          className="text-center"
        >

          {/* Premium badge with gradient border, glow, live dot & shimmer */}
          <motion.div variants={fadeUp} className="inline-flex justify-center mb-8">
            <div
              className="relative rounded-full p-px"
              style={{
                background:
                  "linear-gradient(135deg, rgba(217,142,59,.9), rgba(30,35,64,.55))",
                boxShadow:
                  "0 8px 30px -8px rgba(217,142,59,.45), 0 4px 16px -6px rgba(30,35,64,.25)",
              }}
            >
              <div className="relative flex items-center gap-3 rounded-full bg-white/95 backdrop-blur px-5 py-2 pr-6 overflow-hidden">
                {/* Shimmer sweep */}
                <motion.span
                  className="absolute inset-y-0 w-1/3 -skew-x-12 pointer-events-none"
                  style={{
                    background:
                      "linear-gradient(90deg, transparent, rgba(255,255,255,.55), transparent)",
                  }}
                  initial={{ x: "-120%" }}
                  animate={{ x: "420%" }}
                  transition={{ duration: 2.6, repeat: Infinity, ease: "easeInOut", repeatDelay: 2.2 }}
                />

                {/* Icon tile */}
                <span
                  className="relative flex items-center justify-center w-8 h-8 rounded-full"
                  style={{
                    background:
                      "linear-gradient(135deg, #D98E3B, #B56F28)",
                    boxShadow: "inset 0 1px 0 rgba(255,255,255,.35)",
                  }}
                >
                  <Globe2 size={16} color="white" />
                </span>

                <span
                  className="relative text-sm font-bold tracking-wide"
                  style={{ color: BRAND.indigo }}
                >
                  Africa&apos;s Travel Wallet
                </span>

                {/* Live status dot */}
                <span className="relative inline-flex items-center gap-1.5 ml-1">
                  <span
                    className="w-2 h-2 rounded-full"
                    style={{ background: BRAND.amber }}
                  />
                  <span
                    className="text-[11px] font-semibold uppercase tracking-widest"
                    style={{ color: BRAND.amber }}
                  >
                    Private Beta
                  </span>
                </span>
              </div>
            </div>
          </motion.div>

          <h1
            className="text-6xl md:text-8xl font-black leading-[1.05] tracking-tight"
            style={{ color: BRAND.indigo }}
          >
            <span className="block overflow-hidden">
              <motion.span variants={word} className="block">
                One Wallet.
              </motion.span>
            </span>
            <span className="block overflow-hidden">
              <motion.span variants={word} className="block">
                Every Journey.
              </motion.span>
            </span>
            <span className="block overflow-hidden">
              <motion.span
                variants={word}
                className="block bg-clip-text text-transparent"
                style={{
                  backgroundImage:
                    "linear-gradient(90deg, #D98E3B, #F2B463, #D98E3B, #B56F28)",
                  backgroundSize: "300% 100%",
                  animation: "gradient-shift 6s ease-in-out infinite",
                }}
              >
                Across Africa.
              </motion.span>
            </span>
          </h1>

          <motion.p
            variants={fadeUp}
            className="max-w-3xl mx-auto mt-10 text-xl leading-9 text-slate-600"
          >
            KwanPay helps travelers pay for transport, tours, hotels and
            experiences across Africa using one secure digital wallet. Send
            money, manage your travel funds and pay trusted tourism
            businesses—all from one premium mobile experience.
          </motion.p>

          <motion.div
            variants={fadeUp}
            className="mt-6 text-sm font-medium"
            style={{ color: BRAND.indigo }}
          >
            Currently in Private Beta • Launching Soon Across Africa
          </motion.div>

          <motion.div
            variants={fadeUp}
            className="flex justify-center gap-5 mt-12 flex-wrap"
          >
            <Link href="/demo">
              <motion.button
                whileHover={{ scale: 1.05, y: -3 }}
                whileTap={{ scale: 0.97 }}
                transition={{ type: "spring", stiffness: 340, damping: 22 }}
                className="group relative overflow-hidden rounded-full px-9 py-4 font-semibold text-white"
                style={{
                  background: "linear-gradient(135deg, #D98E3B, #B56F28)",
                  boxShadow: "0 10px 30px -8px rgba(217,142,59,.6)",
                }}
              >
                <span className="relative z-10 flex items-center gap-2">
                  Request a Demo
                  <Sparkles size={17} className="transition-transform group-hover:rotate-12" />
                </span>
              </motion.button>
            </Link>

            <motion.a
              href="#features"
              whileHover={{ scale: 1.05, y: -3 }}
              whileTap={{ scale: 0.97 }}
              transition={{ type: "spring", stiffness: 340, damping: 22 }}
              className="rounded-full px-9 py-4 border-2 font-semibold"
              style={{
                borderColor: "#D7D7D7",
                color: BRAND.indigo,
                background: "rgba(255,255,255,.6)",
                backdropFilter: "blur(8px)",
              }}
            >
              Explore Features
            </motion.a>

          </motion.div>

        </motion.div>

        {/* Payment Flow */}

        <motion.div
          variants={staggerContainer(0.15)}
          initial="hidden"
          whileInView="show"
          viewport={viewportOnce}
          className="mt-28"
        >

          <div className="grid lg:grid-cols-3 gap-8">

            {[
              {
                number: "01",
                title: "Traveler Pays",
                body:
                  "The traveler pays using their local currency from anywhere in the world.",
              },

              {
                number: "02",
                title: "KwanPay Settles",
                body:
                  "Payments are routed securely over Stellar with transparent settlement.",
              },

              {
                number: "03",
                title: "Operator Gets Paid",
                body:
                  "Tourism operators receive funds quickly, improving cash flow and reducing payment friction.",
              },
            ].map((step, i) => (
              <motion.div key={step.number} variants={fadeUp} className="relative group">
                <motion.div
                  whileHover={{ y: -10, boxShadow: "0 30px 60px -18px rgba(30,35,64,0.28)" }}
                  transition={{ type: "spring", stiffness: 260, damping: 22 }}
                  className="relative h-full rounded-3xl bg-white p-10 border border-slate-100 shadow-lg hover:border-amber-200 overflow-hidden"
                >
                  {/* top accent line */}
                  <div
                    className="absolute top-0 left-0 right-0 h-1 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                    style={{
                      background:
                        "linear-gradient(90deg, #D98E3B, #1E2340)",
                    }}
                  />

                  {/* number tile */}
                  <div className="flex items-center justify-between">
                    <span
                      className="text-5xl font-black"
                      style={{
                        background:
                          "linear-gradient(135deg, #D98E3B, #B56F28)",
                        WebkitBackgroundClip: "text",
                        backgroundClip: "text",
                        color: "transparent",
                      }}
                    >
                      {step.number}
                    </span>

                    <motion.span
                      whileHover={{ scale: 1.1, rotate: 6 }}
                      transition={{ type: "spring", stiffness: 300, damping: 15 }}
                      className="w-12 h-12 rounded-2xl flex items-center justify-center shadow-md"
                      style={{
                        background:
                          "linear-gradient(135deg, rgba(217,142,59,.15), rgba(30,35,64,.08))",
                        color: BRAND.amber,
                      }}
                    >
                      {i === 0 ? (
                        <Send size={22} />
                      ) : i === 1 ? (
                        <ShieldCheck size={22} />
                      ) : (
                        <BadgeCheck size={22} />
                      )}
                    </motion.span>
                  </div>

                  <h3
                    className="mt-6 text-2xl font-bold"
                    style={{ color: BRAND.indigo }}
                  >
                    {step.title}
                  </h3>

                  <p className="mt-4 leading-7 text-slate-600">
                    {step.body}
                  </p>
                </motion.div>

                {/* connector */}
                {i < 2 && (
                  <div className="hidden lg:flex absolute top-1/2 -right-6 z-10 w-6 items-center justify-center">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                      <path
                        d="M5 12h14M13 6l6 6-6 6"
                        stroke="#D98E3B"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                  </div>
                )}
              </motion.div>
            ))}

          </div>

        </motion.div>

      </motion.div>

    </section>
  );
}
