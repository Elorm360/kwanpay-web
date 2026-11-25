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
  "w-full rounded-2xl border border-slate-300 bg-white px-5 py-4 text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all";

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
        className="flex items-center gap-2 mb-2 font-medium text-slate-700"
      >
        <Icon size={15} style={{ color: BRAND.amber }} aria-hidden />
        {label}
        {optional && (
          <span className="text-sm font-normal text-slate-400">
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
