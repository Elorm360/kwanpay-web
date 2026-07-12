import LogoutButton from "@/components/admin/LogoutButton";

const BRAND = {
  indigo: "#1E2340",
  amber: "#D98E3B",
};

export default function DashboardHeader() {
  return (
    <div className="flex items-center justify-between mb-12">

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
          Monitor your early access community.
        </p>

      </div>

      <div className="flex items-center gap-4">

        <span className="text-sm text-slate-500">
          Administrator
        </span>

        <LogoutButton />

      </div>

    </div>
  );
}