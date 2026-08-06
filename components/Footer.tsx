"use client";

import Link from "next/link";
import { Mail } from "lucide-react";
import { BRAND } from "@/lib/brand";

const LinkedinIcon = ({ size = 16 }: { size?: number }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor">
    <path d="M20.45 20.45h-3.55v-5.57c0-1.33-.03-3.04-1.85-3.04-1.86 0-2.14 1.45-2.14 2.94v5.67H9.35V9h3.41v1.56h.05c.48-.9 1.64-1.85 3.37-1.85 3.6 0 4.27 2.37 4.27 5.46v6.28zM5.34 7.43a2.06 2.06 0 1 1 0-4.12 2.06 2.06 0 0 1 0 4.12zM7.12 20.45H3.56V9h3.56v11.45z" />
  </svg>
);

const InstagramIcon = ({ size = 16 }: { size?: number }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
    <rect x="3" y="3" width="18" height="18" rx="5" stroke="currentColor" strokeWidth="2" />
    <circle cx="12" cy="12" r="4" stroke="currentColor" strokeWidth="2" />
    <circle cx="17.5" cy="6.5" r="1.3" fill="currentColor" />
  </svg>
);

const XIcon = ({ size = 16 }: { size?: number }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor">
    <path d="M18.24 2.25h3.31l-7.23 8.26 8.5 11.24h-6.66l-5.22-6.82-5.97 6.82H1.66l7.73-8.84L1.25 2.25h6.83l4.71 6.23 5.45-6.23zm-1.16 17.52h1.83L7.08 4.13H5.12l11.96 15.64z" />
  </svg>
);

const companyLinks = [
  { label: "About", href: "#" },
  { label: "Our Vision", href: "#" },
  { label: "Partners", href: "#" },
  { label: "Careers (Coming Soon)", href: "#" },
];

const productLinks = [
  { label: "Features", href: "#features" },
  { label: "Security", href: "#trust" },
  { label: "Roadmap", href: "#trust" },
  { label: "Request a Demo", href: "/waitlist" },
];

const resourceLinks = [
  { label: "Privacy Policy", href: "#" },
  { label: "Terms of Service", href: "#" },
  { label: "FAQ (Coming Soon)", href: "#" },
  { label: "Support", href: "#" },
];

const socials = [
  { label: "LinkedIn", icon: LinkedinIcon, href: "#" },
  { label: "Instagram", icon: InstagramIcon, href: "#" },
  { label: "X (Twitter)", icon: XIcon, href: "#" },
];

export default function Footer() {
  return (
    <footer
      id="footer"
      className="px-6 py-20"
      style={{
        background: BRAND.indigo,
      }}
    >
      <div className="max-w-7xl mx-auto">
        {/* Top — 4 columns */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12">
          {/* Brand */}
          <div>
            <div className="flex items-center gap-4">
              <div
                className="h-11 w-11 rounded-2xl flex items-center justify-center"
                style={{
                  background: "rgba(255,255,255,0.08)",
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

              <h2 className="text-2xl font-black text-white">
                Kwan
                <span style={{ color: BRAND.amber }}>Pay</span>
              </h2>
            </div>

            <p className="mt-8 text-slate-400 leading-8">
              KwanPay is building the future of borderless travel payments
              across Africa, helping travelers and tourism businesses move money
              with confidence.
            </p>

            {/* Beta badge */}
            <div className="mt-8 inline-flex items-center gap-2 rounded-full px-4 py-2 border"
              style={{
                borderColor: "rgba(217,142,59,0.4)",
                background: "rgba(217,142,59,0.12)",
              }}
            >
              <span className="w-2 h-2 rounded-full" style={{ background: BRAND.amber }} />
              <span className="text-xs font-semibold tracking-wide" style={{ color: BRAND.amber }}>
                Private Beta
              </span>
            </div>
            <p className="mt-2 text-sm text-slate-400">
              Launching Soon Across Africa
            </p>
          </div>

          {/* Company */}
          <div>
            <h3 className="text-white font-bold mb-6">Company</h3>
            <ul className="space-y-4">
              {companyLinks.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    className="text-slate-400 transition-colors duration-300 hover:text-white"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Product */}
          <div>
            <h3 className="text-white font-bold mb-6">Product</h3>
            <ul className="space-y-4">
              {productLinks.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    className="text-slate-400 transition-colors duration-300 hover:text-white"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Resources + Contact */}
          <div>
            <h3 className="text-white font-bold mb-6">Resources</h3>
            <ul className="space-y-4">
              {resourceLinks.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    className="text-slate-400 transition-colors duration-300 hover:text-white"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>

            <h3 className="text-white font-bold mt-10 mb-6">Contact</h3>
            <ul className="space-y-4">
              <li>
                <a
                  href="mailto:contact@kwanpay.africa"
                  className="inline-flex items-center gap-2 text-slate-400 transition-colors duration-300 hover:text-white"
                >
                  <Mail size={16} style={{ color: BRAND.amber }} />
                  contact@kwanpay.africa
                </a>
              </li>
            </ul>

            {/* Social icons */}
            <div className="flex gap-3 mt-6">
              {socials.map((social) => {
                const Icon = social.icon;
                return (
                  <a
                    key={social.label}
                    href={social.href}
                    aria-label={social.label}
                    className="w-10 h-10 rounded-full flex items-center justify-center border transition-all duration-300 hover:-translate-y-1"
                    style={{
                      borderColor: "rgba(255,255,255,0.15)",
                      color: "white",
                    }}
                    onMouseEnter={(e) => {
                      e.currentTarget.style.background = BRAND.amber;
                      e.currentTarget.style.borderColor = BRAND.amber;
                    }}
                    onMouseLeave={(e) => {
                      e.currentTarget.style.background = "transparent";
                      e.currentTarget.style.borderColor = "rgba(255,255,255,0.15)";
                    }}
                  >
                    <Icon size={16} />
                  </a>
                );
              })}
            </div>
          </div>
        </div>

        {/* Bottom divider */}
        <div className="border-t border-white/15 mt-20 pt-10 flex flex-col md:flex-row justify-between items-center gap-5">
          <div>
            <p className="text-slate-400">© 2026 KwanPay Technologies Ltd.</p>
            <p className="text-slate-500 mt-1 text-sm">
              Building the future of African travel payments.
            </p>
          </div>

          <p className="text-slate-400">
            Made with <span style={{ color: BRAND.amber }}>❤️</span> in Africa
          </p>
        </div>
      </div>
    </footer>
  );
}
