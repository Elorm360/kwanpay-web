import type { ReactNode } from "react";

type Tone = "paper" | "white" | "ink";

const tones: Record<Tone, string> = {
  paper: "bg-paper text-charcoal",
  white: "bg-white text-charcoal",
  ink: "bg-ink text-white",
};

export function Section({
  id,
  tone = "paper",
  children,
  className = "",
}: {
  id?: string;
  tone?: Tone;
  children: ReactNode;
  className?: string;
}) {
  return (
    <section id={id} className={`px-6 py-20 md:py-28 ${tones[tone]} ${className}`}>
      <div className="mx-auto max-w-6xl">{children}</div>
    </section>
  );
}

/** Small label above a heading: sentence case with an amber dot, not spaced caps. */
export function Eyebrow({ children, onDark = false }: { children: ReactNode; onDark?: boolean }) {
  return (
    <p
      className={`inline-flex items-center gap-2 text-sm font-semibold ${
        onDark ? "text-white/70" : "text-muted"
      }`}
    >
      <span aria-hidden className="h-1.5 w-1.5 rounded-full bg-amber" />
      {children}
    </p>
  );
}

export function Heading({
  children,
  onDark = false,
  className = "",
}: {
  children: ReactNode;
  onDark?: boolean;
  className?: string;
}) {
  return (
    <h2
      className={`mt-4 text-balance text-3xl font-extrabold leading-[1.1] tracking-tight md:text-5xl ${
        onDark ? "text-white" : "text-ink"
      } ${className}`}
    >
      {children}
    </h2>
  );
}

export function Lead({
  children,
  onDark = false,
  className = "",
}: {
  children: ReactNode;
  onDark?: boolean;
  className?: string;
}) {
  return (
    <p
      className={`mt-5 max-w-2xl text-lg leading-8 ${onDark ? "text-white/75" : "text-charcoal/75"} ${className}`}
    >
      {children}
    </p>
  );
}

/** Marks a feature that is planned but not live yet. */
export function SoonTag() {
  return (
    <span className="ml-2 inline-flex items-center rounded-full bg-amber-tint px-2 py-0.5 align-middle text-xs font-semibold text-amber-deep">
      Coming soon
    </span>
  );
}
