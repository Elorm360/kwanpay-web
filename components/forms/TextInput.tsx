"use client";

import { useId } from "react";
import type { LucideIcon } from "lucide-react";
import { BRAND } from "@/lib/brand";

type TextInputProps = {
  label: string;
  icon: LucideIcon;
  value: string;
  onChange: (value: string) => void;
  required?: boolean;
  optional?: boolean;
  type?: string;
  placeholder?: string;
  textarea?: boolean;
  rows?: number;
  name?: string;
  autoComplete?: string;
  maxLength?: number;
  minLength?: number;
};

const inputClass =
  "w-full rounded-control border border-line bg-white px-4 py-3.5 text-[16px] text-ink placeholder:text-muted/70 focus:outline-none focus:ring-2 focus:ring-amber/60 focus:border-amber transition-colors";

export default function TextInput({
  label,
  icon: Icon,
  value,
  onChange,
  required,
  optional,
  type = "text",
  placeholder,
  textarea,
  rows = 4,
  name,
  autoComplete,
  maxLength,
  minLength,
}: TextInputProps) {
  const id = useId();
  const shared = {
    id,
    name,
    required,
    placeholder,
    value,
    maxLength,
    minLength,
    autoComplete,
  };

  return (
    <div>
      <label
        htmlFor={id}
        className="mb-2 flex items-center gap-2 text-sm font-semibold text-ink"
      >
        <Icon size={15} style={{ color: BRAND.amber }} aria-hidden />
        {label}
        {optional && (
          <span className="font-normal text-muted">
            (Optional)
          </span>
        )}
      </label>

      {textarea ? (
        <textarea
          {...shared}
          rows={rows}
          onChange={(e) => onChange(e.target.value)}
          className={`${inputClass} resize-none`}
        />
      ) : (
        <input
          {...shared}
          type={type}
          onChange={(e) => onChange(e.target.value)}
          className={inputClass}
        />
      )}
    </div>
  );
}
