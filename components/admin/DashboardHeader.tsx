import Link from "next/link";

import LogoutButton from "@/components/admin/LogoutButton";
import type { AdminUser } from "@/lib/admin-types";

const SECTIONS = [
  { key: "leads", href: "/admin", label: "Leads" },
  { key: "kyc", href: "/admin/kyc", label: "KYC review" },
] as const;

type Section = (typeof SECTIONS)[number]["key"];

const INTRO: Record<Section, string> = {
  leads: "Manage leads, follow-ups, and your operations team.",
  kyc: "Check ID documents and raise account limits.",
};

export default function DashboardHeader({
  admin,
  active = "leads",
  pendingKyc,
}: {
  admin: AdminUser;
  active?: Section;
  pendingKyc?: number;
}) {
  return (
    <div className="mb-10">
      <div className="flex flex-col gap-6 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.3em] text-[#D98E3B]">
            Admin Dashboard
          </p>
          <h1 className="mt-3 text-5xl font-black text-[#1E2340]">KwanPay</h1>
          <p className="mt-4 text-lg text-slate-500">{INTRO[active]}</p>
        </div>

        <div className="flex items-center gap-4">
          <div className="text-right">
            <p className="text-sm font-semibold text-slate-700">
              {admin.display_name}
            </p>
            <p className="text-xs capitalize text-slate-500">{admin.role}</p>
          </div>
          <LogoutButton />
        </div>
      </div>

      <nav
        aria-label="Admin sections"
        className="mt-8 flex gap-2 border-b border-slate-300"
      >
        {SECTIONS.map((section) => {
          const current = section.key === active;
          return (
            <Link
              key={section.key}
              href={section.href}
              aria-current={current ? "page" : undefined}
              className={`-mb-px flex items-center gap-2 border-b-2 px-4 py-3 text-sm font-semibold transition-colors ${
                current
                  ? "border-[#1E2340] text-[#1E2340]"
                  : "border-transparent text-slate-500 hover:text-[#1E2340]"
              }`}
            >
              {section.label}
              {section.key === "kyc" && pendingKyc ? (
                <span className="rounded-full bg-[#D98E3B] px-2 py-0.5 text-xs font-bold text-[#1E2340]">
                  {pendingKyc}
                </span>
              ) : null}
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
