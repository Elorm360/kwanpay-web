import Link from "next/link";
import { ArrowUpRight, Mail } from "lucide-react";

import { Logo } from "@/components/Logo";
import { CONTACT_EMAIL, LEGAL_ENTITY, PARTNER } from "@/lib/site";

const LinkedinIcon = () => (
  <svg width={16} height={16} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
    <path d="M20.45 20.45h-3.55v-5.57c0-1.33-.03-3.04-1.85-3.04-1.86 0-2.14 1.45-2.14 2.94v5.67H9.35V9h3.41v1.56h.05c.48-.9 1.64-1.85 3.37-1.85 3.6 0 4.27 2.37 4.27 5.46v6.28zM5.34 7.43a2.06 2.06 0 1 1 0-4.12 2.06 2.06 0 0 1 0 4.12zM7.12 20.45H3.56V9h3.56v11.45z" />
  </svg>
);

const InstagramIcon = () => (
  <svg width={16} height={16} viewBox="0 0 24 24" fill="none" aria-hidden>
    <rect x="3" y="3" width="18" height="18" rx="5" stroke="currentColor" strokeWidth="2" />
    <circle cx="12" cy="12" r="4" stroke="currentColor" strokeWidth="2" />
    <circle cx="17.5" cy="6.5" r="1.3" fill="currentColor" />
  </svg>
);

const XIcon = () => (
  <svg width={16} height={16} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
    <path d="M18.24 2.25h3.31l-7.23 8.26 8.5 11.24h-6.66l-5.22-6.82-5.97 6.82H1.66l7.73-8.84L1.25 2.25h6.83l4.71 6.23 5.45-6.23zm-1.16 17.52h1.83L7.08 4.13H5.12l11.96 15.64z" />
  </svg>
);

type FooterLinkItem = { label: string; href: string; external?: boolean };

const columns: { title: string; links: FooterLinkItem[] }[] = [
  {
    title: "Product",
    links: [
      { label: "How it works", href: "/#how-it-works" },
      { label: "For travelers", href: "/#travelers" },
      { label: "For businesses", href: "/business" },
      { label: "Security", href: "/#trust" },
      { label: "Roadmap", href: "/roadmap" },
    ],
  },
  {
    title: "Company",
    links: [
      { label: "Starting in Ghana", href: "/#ghana" },
      { label: PARTNER.name, href: PARTNER.url, external: true },
      { label: "Request a demo", href: "/demo" },
      { label: "Join early access", href: "/waitlist" },
    ],
  },
  {
    title: "Help",
    links: [
      { label: "FAQ", href: "/#faq" },
      { label: "Contact support", href: `mailto:${CONTACT_EMAIL}?subject=Support`, external: true },
      { label: "Privacy policy", href: "/privacy" },
      { label: "Terms of use", href: "/terms" },
    ],
  },
];

// Add real profile URLs here; icons render only once a URL is set, so the
// footer never shows dead social links.
const socials = [
  { label: "KwanPay on LinkedIn", icon: LinkedinIcon, href: "" },
  { label: "KwanPay on Instagram", icon: InstagramIcon, href: "" },
  { label: "KwanPay on X", icon: XIcon, href: "" },
].filter((social) => social.href);

function FooterLink({ label, href, external }: FooterLinkItem) {
  const className = "inline-flex items-center gap-1 text-white/70 transition-colors hover:text-white";
  if (external) {
    const isMail = href.startsWith("mailto:");
    return (
      <a
        href={href}
        className={className}
        {...(isMail ? {} : { target: "_blank", rel: "noopener noreferrer" })}
      >
        {label}
        {!isMail && <ArrowUpRight size={13} aria-hidden />}
      </a>
    );
  }
  return (
    <Link href={href} className={className}>
      {label}
    </Link>
  );
}

export default function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer id="footer" className="bg-ink-deep px-6 pb-10 pt-16 text-white md:pt-20">
      <div className="mx-auto max-w-6xl">
        <div className="grid gap-12 lg:grid-cols-[1.2fr_2fr]">
          <div>
            <Link href="/" aria-label="KwanPay home">
              <Logo onDark size={38} />
            </Link>
            <p className="mt-5 max-w-sm leading-7 text-white/65">
              The travel wallet for Ghana and beyond: pay tours, stays and
              rides from one balance. Built with {PARTNER.name}.
            </p>
            <a
              href={`mailto:${CONTACT_EMAIL}`}
              className="mt-6 inline-flex items-center gap-2 text-white/80 hover:text-white"
            >
              <Mail size={16} className="text-amber" aria-hidden />
              {CONTACT_EMAIL}
            </a>
            {socials.length > 0 && (
              <div className="mt-6 flex gap-2">
                {socials.map(({ label, icon: Icon, href }) => (
                  <a
                    key={label}
                    href={href}
                    aria-label={label}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex h-10 w-10 items-center justify-center rounded-full border border-white/15 text-white/80 hover:border-white/40 hover:text-white"
                  >
                    <Icon />
                  </a>
                ))}
              </div>
            )}
          </div>

          <nav aria-label="Footer" className="grid grid-cols-2 gap-10 sm:grid-cols-3">
            {columns.map((column) => (
              <div key={column.title}>
                <h2 className="text-sm font-semibold text-white">{column.title}</h2>
                <ul className="mt-4 space-y-3 text-[15px]">
                  {column.links.map((link) => (
                    <li key={link.label}>
                      <FooterLink {...link} />
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </nav>
        </div>

        <div className="mt-14 flex flex-col gap-3 border-t border-white/10 pt-8 text-sm text-white/50 md:flex-row md:items-center md:justify-between">
          <p>
            © {year} {LEGAL_ENTITY} All rights reserved.
          </p>
          <p>Currently in private beta in Ghana.</p>
        </div>
      </div>
    </footer>
  );
}
