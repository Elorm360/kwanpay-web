import LogoutButton from "@/components/admin/LogoutButton";
import type { AdminUser } from "@/lib/admin-types";

const BRAND = {
  indigo: "#1E2340",
  amber: "#D98E3B",
};

export default function DashboardHeader({ admin }: { admin: AdminUser }) {
  return (
    <div className="flex flex-col gap-6 sm:flex-row sm:items-center sm:justify-between mb-10">

      <div>

        <p
          className="uppercase tracking-[0.3em] text-sm font-semibold"
          style={{ color: BRAND.amber }}
        >
          Admin Dashboard
        </p>

        <h1
          className="mt-3 text-5xl font-black"
          style={{ color: BRAND.indigo }}
        >
          KwanPay
        </h1>

        <p className="mt-4 text-slate-500 text-lg">
          Manage leads, follow-ups, and your operations team.
        </p>

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
  );
}