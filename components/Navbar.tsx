"use client";

import { useState } from "react";
import Link from "next/link";
import { AnimatePresence, motion, useMotionValueEvent, useScroll } from "framer-motion";
import { Menu, X } from "lucide-react";
import { BRAND } from "@/lib/brand";
import { EASE_OUT } from "@/lib/motion";

const navLinks = [
  { href: "#hero", label: "Home" },
  { href: "#problem", label: "Problem" },
  { href: "#how-it-works", label: "How It Works" },
  { href: "#footer", label: "Contact" },
];

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const { scrollY } = useScroll();

  useMotionValueEvent(scrollY, "change", (latest) => {
    setScrolled(latest > 24);
  });

  const linkClassName =
    "relative transition duration-300 hover:text-amber-500 after:absolute after:left-0 after:-bottom-1 after:h-[2px] after:w-0 after:bg-[#D98E3B] after:transition-all hover:after:w-full";

  return (
    <header className="fixed top-0 left-0 right-0 z-50">
      <motion.div
        initial={{ marginTop: 20, maxWidth: 1120 }}
        animate={{
          marginTop: scrolled ? 12 : 20,
          maxWidth: scrolled ? 880 : 1120,
        }}
        transition={{ duration: 0.4, ease: EASE_OUT }}
        className="mx-auto px-6"
      >
        <div className="relative">
          {/* Gradient hairline under navbar */}
          <div
            className="absolute -bottom-3 left-1/2 -translate-x-1/2 w-3/4 h-px"
            style={{
              background:
                "linear-gradient(90deg, transparent, rgba(217,142,59,.45), transparent)",
            }}
          />

          <motion.div
            animate={{
              paddingTop: scrolled ? 10 : 16,
              paddingBottom: scrolled ? 10 : 16,
              boxShadow: scrolled
                ? "0 10px 30px -10px rgba(30,35,64,0.25)"
                : "0 20px 45px -20px rgba(30,35,64,0.18)",
            }}
            transition={{ duration: 0.4, ease: EASE_OUT }}
            className="backdrop-blur-2xl bg-white/80 border border-white/40 rounded-full px-7 flex items-center justify-between"
          >
            {/* Logo */}
            <Link href="/" className="flex items-center gap-4">
              <motion.div
                whileHover={{ rotate: -8, scale: 1.06 }}
                transition={{ type: "spring", stiffness: 300, damping: 15 }}
                className="h-11 w-11 rounded-2xl flex items-center justify-center shadow-lg shrink-0"
                style={{ background: "linear-gradient(135deg, #1E2340, #13162B)" }}
              >
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                  <path
                    d="M6 18C10 12 14 12 18 6"
                    stroke={BRAND.amber}
                    strokeWidth="2.5"
                    strokeLinecap="round"
                  />
                  <circle cx="18" cy="6" r="2" fill={BRAND.amber} />
                </svg>
              </motion.div>

              <motion.div
                animate={{ opacity: scrolled ? 0 : 1, width: scrolled ? 0 : "auto" }}
                transition={{ duration: 0.3, ease: EASE_OUT }}
                className="overflow-hidden whitespace-nowrap"
              >
                <h1 className="text-2xl font-black tracking-tight" style={{ color: BRAND.indigo }}>
                  Kwan
                  <span style={{ color: BRAND.amber }}>Pay</span>
                </h1>
                <p className="text-[10px] uppercase tracking-[0.2em] font-semibold text-slate-400">
                  Travel Payments
                </p>
              </motion.div>
            </Link>

            {/* Navigation */}
            <nav className="hidden lg:flex gap-10 font-medium">
              {navLinks.map((link) => (
                <a key={link.href} href={link.href} className={linkClassName}>
                  {link.label}
                </a>
              ))}
            </nav>

            <div className="flex items-center gap-3">
              <Link href="/waitlist" className="hidden sm:block">
                <motion.button
                  whileHover={{ scale: 1.05, y: -1 }}
                  whileTap={{ scale: 0.96 }}
                  transition={{ type: "spring", stiffness: 400, damping: 20 }}
                  className="group relative overflow-hidden rounded-full px-6 py-3 font-semibold text-white shadow-lg"
                  style={{ background: "linear-gradient(135deg, #D98E3B, #B56F28)" }}
                >
                  <span className="relative z-10">Request Early Access</span>
                </motion.button>
              </Link>

              {/* Mobile menu toggle */}
              <button
                onClick={() => setMenuOpen((open) => !open)}
                aria-label={menuOpen ? "Close menu" : "Open menu"}
                aria-expanded={menuOpen}
                className="lg:hidden h-11 w-11 rounded-full flex items-center justify-center shrink-0"
                style={{ background: "rgba(30,35,64,0.06)" }}
              >
                <AnimatePresence mode="wait" initial={false}>
                  <motion.span
                    key={menuOpen ? "close" : "open"}
                    initial={{ opacity: 0, rotate: -60 }}
                    animate={{ opacity: 1, rotate: 0 }}
                    exit={{ opacity: 0, rotate: 60 }}
                    transition={{ duration: 0.2 }}
                    className="flex"
                  >
                    {menuOpen ? (
                      <X size={20} color={BRAND.indigo} />
                    ) : (
                      <Menu size={20} color={BRAND.indigo} />
                    )}
                  </motion.span>
                </AnimatePresence>
              </button>
            </div>
          </motion.div>
        </div>

        {/* Mobile menu panel */}
        <AnimatePresence>
          {menuOpen && (
            <motion.div
              initial={{ opacity: 0, y: -12, scale: 0.98 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -12, scale: 0.98 }}
              transition={{ duration: 0.25, ease: EASE_OUT }}
              className="lg:hidden mt-3 rounded-3xl border border-white/40 bg-white/95 backdrop-blur-2xl shadow-xl overflow-hidden"
            >
              <nav className="flex flex-col p-3">
                {navLinks.map((link, i) => (
                  <motion.a
                    key={link.href}
                    href={link.href}
                    onClick={() => setMenuOpen(false)}
                    initial={{ opacity: 0, x: -12 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.05 + i * 0.05, duration: 0.25, ease: EASE_OUT }}
                    className="px-5 py-3 rounded-2xl font-semibold text-lg"
                    style={{ color: BRAND.indigo }}
                  >
                    {link.label}
                  </motion.a>
                ))}
                <motion.div
                  initial={{ opacity: 0, x: -12 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.05 + navLinks.length * 0.05, duration: 0.25, ease: EASE_OUT }}
                  className="px-3 pt-2 pb-1 sm:hidden"
                >
                  <Link href="/waitlist" onClick={() => setMenuOpen(false)}>
                    <button
                      className="w-full rounded-full px-6 py-3 font-semibold text-white shadow-lg"
                      style={{ background: "linear-gradient(135deg, #D98E3B, #B56F28)" }}
                    >
                      Request Early Access
                    </button>
                  </Link>
                </motion.div>
              </nav>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </header>
  );
}
