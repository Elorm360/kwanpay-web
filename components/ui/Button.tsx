import Link from "next/link";
import type { ReactNode } from "react";

type Variant = "primary" | "accent" | "secondary" | "onDark";

const base =
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-full px-6 py-3.5 text-[15px] font-semibold transition-colors duration-200";

const variants: Record<Variant, string> = {
  // Default action: ink on light backgrounds.
  primary: "bg-ink text-white hover:bg-ink-deep",
  // The single main conversion action on a page (see docs/DESIGN.md).
  accent: "bg-amber text-ink hover:bg-amber-deep hover:text-white",
  secondary: "border border-line bg-white text-ink hover:border-ink/40",
  onDark: "border border-white/25 text-white hover:bg-white/10",
};

export function ButtonLink({
  href,
  variant = "primary",
  children,
  className = "",
  external = false,
}: {
  href: string;
  variant?: Variant;
  children: ReactNode;
  className?: string;
  external?: boolean;
}) {
  const classes = `${base} ${variants[variant]} ${className}`;

  if (external) {
    return (
      <a href={href} className={classes} target="_blank" rel="noopener noreferrer">
        {children}
      </a>
    );
  }

  return (
    <Link href={href} className={classes}>
      {children}
    </Link>
  );
}
