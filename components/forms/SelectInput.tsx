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
        className="flex items-center gap-2 mb-2 font-medium text-slate-700"
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
          className="w-full appearance-none cursor-pointer rounded-2xl border border-slate-300 bg-white px-5 py-4 pr-12 text-slate-900 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 transition-all"
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
          className="absolute right-5 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400"
        />
      </div>
    </div>
  );
}
