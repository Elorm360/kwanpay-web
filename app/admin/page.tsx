import { redirect } from "next/navigation";

import AdminDashboard from "@/components/admin/AdminDashboard";
import DashboardHeader from "@/components/admin/DashboardHeader";
import { getCurrentAdmin } from "@/lib/admin-auth";
import type { AdminUser, LeadRecord } from "@/lib/admin-types";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

export default async function AdminPage() {
  const currentAdmin = await getCurrentAdmin();
  if (!currentAdmin) redirect("/admin/login");

  const supabaseAdmin = getSupabaseAdmin();
  const [leadsResult, adminsResult] = await Promise.all([
    supabaseAdmin
      .from("leads")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(1000),
    supabaseAdmin
      .from("admin_users")
      .select(
        "id, email, display_name, role, is_active, last_login_at, created_at"
      )
      .order("created_at"),
  ]);

  if (leadsResult.error || adminsResult.error) {
    console.error("ADMIN CRM LOAD ERROR:", {
      leads: leadsResult.error,
      admins: adminsResult.error,
    });

    return (
      <main className="min-h-screen bg-[#EDEFF0] px-6 py-20">
        <div className="mx-auto max-w-2xl rounded-3xl border border-red-200 bg-white p-10">
          <h1 className="text-2xl font-black text-[#1E2340]">
            Admin CRM is not ready
          </h1>
          <p className="mt-4 leading-7 text-slate-600">
            Apply the latest Supabase migration, then refresh this page. The
            required file is{" "}
            <code>supabase/migrations/202608120002_admin_crm.sql</code>.
          </p>
        </div>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-[#EDEFF0] px-4 py-10 sm:px-6 sm:py-14">
      <div className="mx-auto max-w-[1500px]">
        <DashboardHeader admin={currentAdmin} />
        <AdminDashboard
          initialLeads={leadsResult.data as LeadRecord[]}
          initialAdmins={adminsResult.data as AdminUser[]}
          currentAdmin={currentAdmin}
          now={new Date().toISOString()}
        />
      </div>
    </main>
  );
}
