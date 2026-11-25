import { ArrowRight, Check } from "lucide-react";

import { ButtonLink } from "@/components/ui/Button";

type SuccessCardProps = {
  title: string;
  messageLines: string[];
  primaryLabel: string;
  primaryHref: string;
  /** Kept for compatibility with existing callers. */
  icon?: "forward" | "home";
  emoji?: string;
};

export default function SuccessCard({
  title,
  messageLines,
  primaryLabel,
  primaryHref,
  icon = "forward",
}: SuccessCardProps) {
  return (
    <div role="status" className="py-6 text-center">
      <span className="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-success/10 text-success">
        <Check size={28} strokeWidth={2.5} aria-hidden />
      </span>

      <h2 className="mt-6 text-2xl font-extrabold tracking-tight text-ink md:text-3xl">{title}</h2>

      {messageLines.map((line, index) => (
        <p
          key={line}
          className={`${index === 0 ? "mt-3" : "mt-1.5"} mx-auto max-w-sm leading-7 text-charcoal/75`}
        >
          {line}
        </p>
      ))}

      <ButtonLink href={primaryHref} variant="primary" className="mt-8">
        {primaryLabel}
        {icon === "forward" && <ArrowRight size={16} aria-hidden />}
      </ButtonLink>
    </div>
  );
}
