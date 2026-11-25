import { redirect } from "next/navigation";

import DashboardHeader from "@/components/admin/DashboardHeader";
import KycQueue from "@/components/admin/KycQueue";
import { getCurrentAdmin } from "@/lib/admin-auth";
import { hasAdminRole } from "@/lib/admin-types";
import { loadKycSubmissions } from "@/lib/kyc-queue";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

export const dynamic = "force-dynamic";

export default async function KycReviewPage() {
  const admin = await getCurrentAdmin();
  if (!admin) redirect("/admin/login");

  // ID documents are personal data: viewers see that the page exists, not
  // anyone's documents.
  if (!hasAdminRole(admin.role, "operator")) {
    return (
      <main className="min-h-screen bg-[#EDEFF0] px-4 py-10 sm:px-6 sm:py-14">
        <div className="mx-auto max-w-[1500px]">
          <DashboardHeader admin={admin} active="kyc" />
          <div className="max-w-xl rounded-3xl border border-slate-200 bg-white p-8">
            <h2 className="text-xl font-bold text-[#1E2340]">
              Operator access needed
            </h2>
            <p className="mt-3 leading-7 text-slate-600">
              ID documents are only shown to operators and above. Ask an admin
              to change your role if you review documents.
            </p>
          </div>
        </div>
      </main>
    );
  }

  let submissions;
  try {
    submissions = await loadKycSubmissions(getSupabaseAdmin());
  } catch (error) {
    console.error("KYC QUEUE LOAD ERROR:", error);
    return (
      <main className="min-h-screen bg-[#EDEFF0] px-6 py-20">
        <div className="mx-auto max-w-2xl rounded-3xl border border-red-200 bg-white p-10">
          <h1 className="text-2xl font-black text-[#1E2340]">
            KYC review is not ready
          </h1>
          <p className="mt-4 leading-7 text-slate-600">
            Apply the latest Supabase migrations, then refresh this page.
          </p>
        </div>
      </main>
    );
  }

  const pending = submissions.filter((s) => s.status === "pending").length;

  return (
    <main className="min-h-screen bg-[#EDEFF0] px-4 py-10 sm:px-6 sm:py-14">
      <div className="mx-auto max-w-[1500px]">
        <DashboardHeader admin={admin} active="kyc" pendingKyc={pending} />
        <KycQueue initialSubmissions={submissions} now={new Date().toISOString()} />
      </div>
    </main>
  );
}
