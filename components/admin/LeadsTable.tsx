"use client";

import type { AdminUser, LeadRecord, LeadStatus } from "@/lib/admin-types";

const statusStyles: Record<LeadStatus, string> = {
  new: "bg-blue-50 text-blue-700",
  contacted: "bg-amber-50 text-amber-700",
  qualified: "bg-violet-50 text-violet-700",
  nurture: "bg-slate-100 text-slate-700",
  converted: "bg-emerald-50 text-emerald-700",
  closed_lost: "bg-red-50 text-red-700",
};

export default function LeadsTable({
  leads,
  admins,
  now,
  onSelect,
}: {
  leads: LeadRecord[];
  admins: AdminUser[];
  now: string;
  onSelect: (lead: LeadRecord) => void;
}) {
  const ownerNames = new Map(
    admins.map((admin) => [admin.id, admin.display_name])
  );

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full">
        <thead className="bg-[#1E2340] text-left text-sm text-white">
          <tr>
            <th className="px-6 py-4 font-semibold">Lead</th>
            <th className="px-6 py-4 font-semibold">Source</th>
            <th className="px-6 py-4 font-semibold">Status</th>
            <th className="px-6 py-4 font-semibold">Owner</th>
            <th className="px-6 py-4 font-semibold">Follow-up</th>
            <th className="px-6 py-4 font-semibold">Joined</th>
          </tr>
        </thead>
        <tbody>
          {leads.map((lead) => {
            const overdue =
              lead.follow_up_at &&
              new Date(lead.follow_up_at).getTime() < new Date(now).getTime() &&
              lead.status !== "converted" &&
              lead.status !== "closed_lost";

            return (
              <tr
                key={lead.id}
                onClick={() => onSelect(lead)}
                className={`cursor-pointer border-b border-slate-100 transition hover:bg-slate-50 ${
                  overdue ? "border-l-4 border-l-red-400" : ""
                }`}
              >
                <td className="px-6 py-5">
                  <p className="font-semibold text-[#1E2340]">
                    {lead.full_name}
                  </p>
                  <p className="mt-1 text-sm text-slate-500">{lead.email}</p>
                </td>
                <td className="px-6 py-5">
                  <div className="flex flex-wrap gap-1">
                    {lead.sources.map((source) => (
                      <span
                        key={source}
                        className="rounded-full bg-slate-100 px-2.5 py-1 text-xs font-semibold capitalize text-slate-600"
                      >
                        {source === "waitlist" ? "Early access" : "Demo"}
                      </span>
                    ))}
                  </div>
                </td>
                <td className="px-6 py-5">
                  <span
                    className={`rounded-full px-3 py-1.5 text-xs font-semibold capitalize ${statusStyles[lead.status]}`}
                  >
                    {lead.status.replace("_", " ")}
                  </span>
                </td>
                <td className="px-6 py-5 text-sm text-slate-600">
                  {lead.assigned_admin_id
                    ? ownerNames.get(lead.assigned_admin_id) ?? "Unknown"
                    : "Unassigned"}
                </td>
                <td
                  className={`px-6 py-5 text-sm ${
                    overdue ? "font-semibold text-red-600" : "text-slate-500"
                  }`}
                >
                  {lead.follow_up_at
                    ? new Date(lead.follow_up_at).toLocaleDateString()
                    : "—"}
                </td>
                <td className="px-6 py-5 text-sm text-slate-500">
                  {new Date(lead.created_at).toLocaleDateString()}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
      {leads.length === 0 && (
        <div className="px-6 py-16 text-center text-slate-500">
          No leads match these filters.
        </div>
      )}
    </div>
  );
}
