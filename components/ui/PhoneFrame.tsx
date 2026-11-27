import type { ReactNode } from "react";

/** A plain device frame. Content is the screen; keep it 300px wide. */
export function PhoneFrame({
  children,
  className = "",
  label,
  caption,
}: {
  children: ReactNode;
  className?: string;
  /** Accessible description of what the screen shows. */
  label: string;
  caption?: string;
}) {
  return (
    <figure className={`relative mx-auto w-[300px] ${className}`}>
      <div
        role="img"
        aria-label={label}
        className="rounded-[2.75rem] bg-ink-deep p-2.5 shadow-raised"
      >
        <div className="relative overflow-hidden rounded-[2.25rem] bg-paper">
          <div aria-hidden className="absolute left-1/2 top-2.5 z-10 h-6 w-24 -translate-x-1/2 rounded-full bg-ink-deep" />
          {children}
        </div>
      </div>
      {caption && (
        <figcaption className="mt-4 text-center text-xs text-muted">{caption}</figcaption>
      )}
    </figure>
  );
}
