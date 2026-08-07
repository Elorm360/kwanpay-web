"use client";

import Link from "next/link";
import { Mail, ArrowUpRight, MapPin, ShieldCheck } from "lucide-react";
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
  { label: "Careers", href: "#", soon: true },
];

const productLinks = [
  { label: "Features", href: "#features" },
  { label: "Security", href: "#trust" },
  { label: "Roadmap", href: "/roadmap" },
  { label: "Request a Demo", href: "/demo" },
];

const resourceLinks = [
  { label: "Privacy Policy", href: "#" },
  { label: "Terms of Service", href: "#" },
  { label: "FAQ", href: "#", soon: true },
  { label: "Support", href: "#" },
];

const socials = [
  { label: "LinkedIn", icon: LinkedinIcon, href: "#" },
  { label: "Instagram", icon: InstagramIcon, href: "#" },
  { label: "X (Twitter)", icon: XIcon, href: "#" },
];

function ColumnHeading({ children }: { children: React.ReactNode }) {
  return (
    <h3
      className="text-[11px] font-bold uppercase tracking-[0.3em] mb-7"
      style={{ color: BRAND.amber }}
    >
      {children}
    </h3>
  );
}

function FooterLink({ label, href, soon }: { label: string; href: string; soon?: boolean }) {
  return (
    <li>
      <Link
        href={href}
        className="group inline-flex items-center gap-1.5 text-slate-400 transition-colors duration-300 hover:text-white"
      >
        <span className="transition-transform duration-300 group-hover:translate-x-1">
          {label}
        </span>
        {soon && (
          <span
            className="text-[9px] font-bold uppercase tracking-wider px-1.5 py-0.5 rounded-full"
            style={{
              background: "rgba(217,142,59,0.15)",
              color: BRAND.amber,
            }}
          >
            Soon
          </span>
        )}
      </Link>
    </li>
  );
}

export default function Footer() {
  return (
    <footer
      id="footer"
      className="relative px-6 pt-20 pb-10 overflow-hidden"
      style={{ background: BRAND.indigo }}
    >
      {/* Top gradient hairline */}
      <div
        className="absolute top-0 left-0 right-0 h-px"
        style={{
          background:
            "linear-gradient(90deg, transparent, rgba(217,142,59,.7), transparent)",
        }}
      />

      {/* Ambient glow */}
      <div
        className="absolute -top-24 right-0 w-[500px] h-[500px] rounded-full opacity-20 blur-3xl pointer-events-none"
        style={{
          background:
            "radial-gradient(circle, rgba(217,142,59,.5), transparent 70%)",
        }}
      />

      <div className="relative max-w-7xl mx-auto">
        {/* Top — 4 columns */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-12 gap-12">
          {/* Brand — spans wider */}
          <div className="lg:col-span-4">
            <div className="flex items-center gap-4">
              <div
                className="h-11 w-11 rounded-2xl flex items-center justify-center shadow-lg"
                style={{
                  background: "rgba(255,255,255,0.08)",
                  border: "1px solid rgba(255,255,255,0.1)",
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

              <h2 className="text-2xl font-black text-white tracking-tight">
                Kwan
                <span style={{ color: BRAND.amber }}>Pay</span>
              </h2>
            </div>

            <p className="mt-7 text-slate-400 leading-8 max-w-sm">
              KwanPay is building the future of borderless travel payments
              across Africa, helping travelers and tourism businesses move money
              with confidence.
            </p>

            {/* Beta badge */}
            <div
              className="mt-8 inline-flex items-center gap-2.5 rounded-full px-4 py-2 border"
              style={{
                borderColor: "rgba(217,142,59,0.4)",
                background: "rgba(217,142,59,0.12)",
              }}
            >
              <span
                className="relative flex w-2 h-2"
              >
                <span
                  className="absolute inline-flex h-full w-full rounded-full opacity-75 animate-ping"
                  style={{ background: BRAND.amber }}
                />
                <span
                  className="relative inline-flex rounded-full w-2 h-2"
                  style={{ background: BRAND.amber }}
                />
              </span>
              <span
                className="text-[11px] font-bold uppercase tracking-widest"
                style={{ color: BRAND.amber }}
              >
                Private Beta
              </span>
            </div>
            <p className="mt-3 text-sm text-slate-500">
              Launching Soon Across Africa
            </p>

            {/* Trust micro-line */}
            <div className="mt-8 flex items-center gap-2 text-slate-500">
              <ShieldCheck size={15} style={{ color: BRAND.amber }} />
              <span className="text-sm">PCI-secured payments on Stellar</span>
            </div>
          </div>

          {/* Company */}
          <div className="lg:col-span-2">
            <ColumnHeading>Company</ColumnHeading>
            <ul className="space-y-4">
              {companyLinks.map((link) => (
                <FooterLink
                  key={link.label}
                  label={link.label}
                  href={link.href}
                  soon={link.soon}
                />
              ))}
            </ul>
          </div>

          {/* Product */}
          <div className="lg:col-span-2">
            <ColumnHeading>Product</ColumnHeading>
            <ul className="space-y-4">
              {productLinks.map((link) => (
                <FooterLink
                  key={link.label}
                  label={link.label}
                  href={link.href}
                />
              ))}
            </ul>
          </div>

          {/* Resources */}
          <div className="lg:col-span-2">
            <ColumnHeading>Resources</ColumnHeading>
            <ul className="space-y-4">
              {resourceLinks.map((link) => (
                <FooterLink
                  key={link.label}
                  label={link.label}
                  href={link.href}
                  soon={link.soon}
                />
              ))}
            </ul>
          </div>

          {/* Contact */}
          <div className="lg:col-span-2">
            <ColumnHeading>Contact</ColumnHeading>
            <ul className="space-y-4">
              <li>
                <a
                  href="mailto:contact@kwanpay.app"
                  className="group inline-flex items-center gap-2 text-slate-400 transition-colors duration-300 hover:text-white"
                >
                  <span
                    className="w-8 h-8 rounded-full flex items-center justify-center shrink-0"
                    style={{ background: "rgba(217,142,59,0.12)" }}
                  >
                    <Mail size={14} style={{ color: BRAND.amber }} />
                  </span>
                  <span className="text-sm">contact@kwanpay.app</span>
                </a>
              </li>
              <li>
                <div className="inline-flex items-center gap-2 text-slate-400">
                  <span
                    className="w-8 h-8 rounded-full flex items-center justify-center shrink-0"
                    style={{ background: "rgba(217,142,59,0.12)" }}
                  >
                    <MapPin size={14} style={{ color: BRAND.amber }} />
                  </span>
                  <span className="text-sm">Across Africa</span>
                </div>
              </li>
            </ul>

            {/* Social icons */}
            <div className="flex gap-3 mt-7">
              {socials.map((social) => {
                const Icon = social.icon;
                return (
                  <a
                    key={social.label}
                    href={social.href}
                    aria-label={social.label}
                    className="w-10 h-10 rounded-full flex items-center justify-center border transition-all duration-300 hover:-translate-y-1 hover:shadow-lg"
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
        <div
          className="border-t border-white/10 mt-16 pt-10 flex flex-col md:flex-row justify-between items-center gap-5"
        >
          <div>
            <p className="text-slate-400 text-sm">
              © 2026 KwanPay Technologies Ltd.
            </p>
            <p className="text-slate-500 mt-1.5 text-xs">
              Building the future of African travel payments.
            </p>
          </div>

          <div className="flex items-center gap-6">
            <a
              href="#"
              className="text-sm text-slate-400 transition-colors duration-300 hover:text-white"
            >
              Privacy
            </a>
            <a
              href="#"
              className="text-sm text-slate-400 transition-colors duration-300 hover:text-white"
            >
              Terms
            </a>
            <span className="inline-flex items-center text-sm text-slate-400">
              Made with
              <svg
                width="14"
                height="14"
                viewBox="0 0 24 24"
                fill="none"
                className="mx-1.5"
              >
                <path
                  d="M12 21s-7.5-4.6-9.5-9.2C.9 8 3 4.5 6.5 4.5c2 0 3.3 1 4.5 2.6 1.2-1.6 2.5-2.6 4.5-2.6 3.5 0 5.6 3.5 4 7.3C19.5 16.4 12 21 12 21z"
                  fill={BRAND.amber}
                />
              </svg>
              in Africa
            </span>
          </div>
        </div>
      </div>
    </footer>
  );
}
