"use client";

import { useId } from "react";
import { ChevronDown, type LucideIcon } from "lucide-react";
import { BRAND } from "@/lib/brand";

type SelectInputProps = {
  label: string;
  icon: LucideIcon;
  options: readonly string[];
  value: string;
  onChange: (value: string) => void;
  required?: boolean;
  name?: string;
};

export default function SelectInput({
  label,
  icon: Icon,
  options,
  value,
  onChange,
  required,
  name,
}: SelectInputProps) {
  const id = useId();

  return (
    <div>
      <label
        htmlFor={id}
        className="mb-2 flex items-center gap-2 text-sm font-semibold text-ink"
      >
        <Icon size={15} style={{ color: BRAND.amber }} aria-hidden />
        {label}
      </label>

      <div className="relative">
        <select
          id={id}
          name={name}
          required={required}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className="w-full cursor-pointer appearance-none rounded-control border border-line bg-white px-4 py-3.5 pr-12 text-[16px] text-ink focus:border-amber focus:outline-none focus:ring-2 focus:ring-amber/60 transition-colors"
        >
          {options.map((opt) => (
            <option key={opt} value={opt}>
              {opt}
            </option>
          ))}
        </select>
        <ChevronDown
          size={18}
          aria-hidden
          className="pointer-events-none absolute right-4 top-1/2 -translate-y-1/2 text-muted"
        />
      </div>
    </div>
  );
}
