import { cookies } from "next/headers";
import { redirect } from "next/navigation";

import DashboardHeader from "@/components/admin/DashboardHeader";
import DashboardContent from "@/components/admin/DashboardContent";
import { supabaseAdmin } from "@/lib/supabaseAdmin";


const BRAND = {
  paper: "#EDEFF0",
};


function isSameLocalDay(createdAt: string | null | undefined, now: Date) {
  if (!createdAt) return false;
  const created = new Date(createdAt);
  if (Number.isNaN(created.getTime())) return false;
  return created.toDateString() === now.toDateString();
}

function isInLastNDays(createdAt: string | null | undefined, now: Date, days: number) {
  if (!createdAt) return false;
  const created = new Date(createdAt);
  if (Number.isNaN(created.getTime())) return false;

  const weekAgo = new Date(now);
  weekAgo.setDate(weekAgo.getDate() - days);

  return created >= weekAgo;
}

function isSameMonth(createdAt: string | null | undefined, now: Date) {
  if (!createdAt) return false;
  const created = new Date(createdAt);
  if (Number.isNaN(created.getTime())) return false;

  return created.getMonth() === now.getMonth() && created.getFullYear() === now.getFullYear();
}

export default async function AdminPage() {
  const cookieStore = await cookies();

  const loggedIn = cookieStore.get("admin-auth")?.value === "true";

  if (!loggedIn) {
    redirect("/admin/login");
  }

  if (!supabaseAdmin) {
    return (
      <main
        className="min-h-screen flex items-center justify-center"
        style={{ background: BRAND.paper }}
      >
        <h1 className="text-2xl font-bold">Supabase is not configured.</h1>
      </main>
    );
  }


  const { data: waitlist, error } = await supabaseAdmin
  .from("waitlist")
  .select("*")
  .order("created_at", { ascending: false });

if (error) {
  console.error("ADMIN WAITLIST ERROR:", error);
}

  const safeWaitlist = waitlist ?? [];

  // Compute statistics once (instead of filtering inside JSX)
  const now = new Date();
  const totalWaitlistCount = safeWaitlist.length;
  const joinedTodayCount = safeWaitlist.filter((user) => isSameLocalDay(user.created_at, now)).length;
  const thisWeekCount = safeWaitlist.filter((user) => isInLastNDays(user.created_at, now, 7)).length;
  const thisMonthCount = safeWaitlist.filter((user) => isSameMonth(user.created_at, now)).length;

  return (
    <main
      className="min-h-screen py-14 px-6"
      style={{ background: BRAND.paper }}
    >
      <div className="max-w-7xl mx-auto">
        <DashboardHeader />

        {/* Statistics */}

        <div className="grid gap-6 md:grid-cols-2 xl:grid-cols-4 mb-10">
          {/* Total */}
          <div className="rounded-3xl bg-white p-6 shadow-sm border border-slate-200">
            <p className="text-sm text-slate-500">Total Waitlist</p>
            <h2 className="mt-3 text-4xl font-black text-[#1E2340]">{totalWaitlistCount}</h2>
            <p className="mt-2 text-sm text-slate-500">Total registrations</p>
          </div>

          {/* Today */}
          <div className="rounded-3xl bg-white p-6 shadow-sm border border-slate-200">
            <p className="text-sm text-slate-500">Joined Today</p>
            <h2 className="mt-3 text-4xl font-black text-green-600">{joinedTodayCount}</h2>
            <p className="mt-2 text-sm text-slate-500">New today</p>
          </div>

          {/* This Week */}
          <div className="rounded-3xl bg-white p-6 shadow-sm border border-slate-200">
            <p className="text-sm text-slate-500">This Week</p>
            <h2 className="mt-3 text-4xl font-black text-blue-600">{thisWeekCount}</h2>
            <p className="mt-2 text-sm text-slate-500">Last 7 days</p>
          </div>

          {/* This Month */}
          <div className="rounded-3xl bg-white p-6 shadow-sm border border-slate-200">
            <p className="text-sm text-slate-500">This Month</p>
            <h2 className="mt-3 text-4xl font-black text-amber-600">{thisMonthCount}</h2>
            <p className="mt-2 text-sm text-slate-500">Current month</p>
          </div>
        </div>

        <div className="mt-8">
          <DashboardContent people={safeWaitlist} />
        </div>
      </div>
    </main>
  );
}


