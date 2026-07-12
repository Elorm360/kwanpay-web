"use client";

import Link from "next/link";
import { BRAND } from "@/lib/brand";

export default function Navbar() {
  const linkClassName =
    "relative transition duration-300 hover:text-amber-500 after:absolute after:left-0 after:-bottom-1 after:h-[2px] after:w-0 after:bg-[#D98E3B] after:transition-all hover:after:w-full";

  return (
    <header className="fixed top-0 left-0 right-0 z-50">
      <div className="max-w-7xl mx-auto mt-5 px-6">
        <div className="backdrop-blur-2xl bg-white/80 border border-white/40 shadow-xl rounded-full px-7 py-4 flex items-center justify-between">
          {/* Logo */}
          <div className="flex items-center gap-4">
            <div
              className="h-11 w-11 rounded-2xl flex items-center justify-center shadow-lg"
              style={{
                background: BRAND.indigo,
              }}
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
            </div>

            <div>
              <h1 className="text-2xl font-black" style={{ color: BRAND.indigo }}>
                Kwan
                <span style={{ color: BRAND.amber }}>Pay</span>
              </h1>
              <p className="text-xs text-slate-500">The path your payment takes.</p>
            </div>
          </div>

          {/* Navigation */}
          <nav className="hidden lg:flex gap-10 font-medium">
            <a href="#hero" className={linkClassName}>
              Home
            </a>
            <a href="#problem" className={linkClassName}>
              Problem
            </a>
            <a href="#how-it-works" className={linkClassName}>
              How It Works
            </a>
            <a href="#footer" className={linkClassName}>
              Contact
            </a>
          </nav>

          <Link href="/waitlist">
            <button
              className="rounded-full px-6 py-3 font-semibold shadow-lg transition-all duration-300 hover:scale-105"
              style={{
                background: BRAND.amber,
                color: "white",
              }}
            >
              Request Early Access
            </button>
          </Link>
        </div>
      </div>
    </header>
  );
}

