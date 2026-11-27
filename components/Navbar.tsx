"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, X } from "lucide-react";

import { Logo } from "@/components/Logo";
import { ButtonLink } from "@/components/ui/Button";

// Absolute "/#..." hrefs so the links also work from /roadmap, /demo, etc.
const navLinks = [
  { href: "/#how-it-works", label: "How it works" },
  { href: "/#travelers", label: "Travelers" },
  { href: "/business", label: "Businesses" },
  { href: "/roadmap", label: "Roadmap" },
  { href: "/#faq", label: "FAQ" },
];

export default function Navbar() {
  const pathname = usePathname();
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => {
    if (!menuOpen) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === "Escape") setMenuOpen(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [menuOpen]);

  const isCurrent = (href: string) => !href.includes("#") && pathname === href;

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 border-b transition-colors duration-200 ${
        scrolled || menuOpen
          ? "border-line bg-paper/90 backdrop-blur-md"
          : "border-transparent bg-paper/0"
      }`}
    >
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between gap-6 px-6 md:h-[72px]">
        <Link href="/" aria-label="KwanPay home" onClick={() => setMenuOpen(false)}>
          <Logo size={34} />
        </Link>

        <nav aria-label="Main" className="hidden items-center gap-7 lg:flex">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              aria-current={isCurrent(link.href) ? "page" : undefined}
              className="text-[15px] font-medium text-charcoal/80 transition-colors hover:text-ink aria-[current=page]:text-ink aria-[current=page]:underline aria-[current=page]:decoration-amber aria-[current=page]:decoration-2 aria-[current=page]:underline-offset-8"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-2">
          <span className="hidden sm:block">
            <ButtonLink href="/waitlist" variant="accent" className="!px-5 !py-2.5">
              Join early access
            </ButtonLink>
          </span>
          <button
            type="button"
            onClick={() => setMenuOpen((open) => !open)}
            aria-label={menuOpen ? "Close menu" : "Open menu"}
            aria-expanded={menuOpen}
            aria-controls="mobile-menu"
            className="flex h-11 w-11 items-center justify-center rounded-full text-ink hover:bg-ink/5 lg:hidden"
          >
            {menuOpen ? <X size={22} /> : <Menu size={22} />}
          </button>
        </div>
      </div>

      {menuOpen && (
        <nav id="mobile-menu" aria-label="Main" className="border-t border-line bg-paper px-6 pb-6 pt-2 lg:hidden">
          <ul className="mx-auto max-w-6xl">
            {navLinks.map((link) => (
              <li key={link.href}>
                <Link
                  href={link.href}
                  onClick={() => setMenuOpen(false)}
                  aria-current={isCurrent(link.href) ? "page" : undefined}
                  className="block border-b border-line py-4 text-lg font-semibold text-ink"
                >
                  {link.label}
                </Link>
              </li>
            ))}
          </ul>
          <div className="mt-6 sm:hidden">
            <ButtonLink href="/waitlist" variant="accent" className="w-full">
              Join early access
            </ButtonLink>
          </div>
        </nav>
      )}
    </header>
  );
}
