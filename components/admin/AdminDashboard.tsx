"use client";

import { useMemo, useState } from "react";

import {
  hasAdminRole,
  LEAD_STATUSES,
  type AdminUser,
  type LeadRecord,
} from "@/lib/admin-types";
import AdminUsersPanel from "./AdminUsersPanel";
import LeadFilters from "./LeadFilters";
import LeadPanel from "./LeadPanel";
import LeadsTable from "./LeadsTable";
import Pagination from "./Pagination";
import StatCard from "./StatCard";

function csvCell(value: unknown) {
  const text = value == null ? "" : String(value);
  return `"${text.replaceAll('"', '""')}"`;
}

export default function AdminDashboard({
  initialLeads,
  initialAdmins,
  currentAdmin,
  now,
}: {
  initialLeads: LeadRecord[];
  initialAdmins: AdminUser[];
  currentAdmin: AdminUser;
  now: string;
}) {
  const [leads, setLeads] = useState(initialLeads);
  const [admins, setAdmins] = useState(initialAdmins);
  const [selectedLead, setSelectedLead] = useState<LeadRecord | null>(null);
  const [search, setSearch] = useState("");
  const [source, setSource] = useState("all");
  const [status, setStatus] = useState("all");
  const [owner, setOwner] = useState("all");
  const [archive, setArchive] = useState("active");
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);

  const filteredLeads = useMemo(() => {
    const query = search.trim().toLowerCase();
    return leads.filter((lead) => {
      const matchesSearch =
        !query ||
        [
          lead.full_name,
          lead.email,
          lead.country,
          lead.company,
          lead.audience_role,
        ].some((value) => value?.toLowerCase().includes(query));
      const matchesSource =
        source === "all" ||
        (source === "both"
          ? lead.sources.includes("waitlist") && lead.sources.includes("demo")
          : lead.sources.includes(source as "waitlist" | "demo"));
      const matchesStatus = status === "all" || lead.status === status;
      const matchesOwner =
        owner === "all" ||
        (owner === "unassigned"
          ? !lead.assigned_admin_id
          : lead.assigned_admin_id === owner);
      const matchesArchive =
        archive === "all" ||
        (archive === "archived" ? Boolean(lead.archived_at) : !lead.archived_at);

      return (
        matchesSearch &&
        matchesSource &&
        matchesStatus &&
        matchesOwner &&
        matchesArchive
      );
    });
  }, [archive, leads, owner, search, source, status]);

  const pageCount = Math.max(1, Math.ceil(filteredLeads.length / pageSize));
  const currentPage = Math.min(page, pageCount);
  const visibleLeads = filteredLeads.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize
  );

  const metrics = useMemo(() => {
    const nowTime = new Date(now).getTime();
    const activeLeads = leads.filter((lead) => !lead.archived_at);
    const waitlist = activeLeads.filter((lead) =>
      lead.sources.includes("waitlist")
    ).length;
    const demo = activeLeads.filter((lead) =>
      lead.sources.includes("demo")
    ).length;
    const both = activeLeads.filter(
      (lead) =>
        lead.sources.includes("waitlist") && lead.sources.includes("demo")
    ).length;
    const overdue = activeLeads.filter(
      (lead) =>
        lead.follow_up_at &&
        new Date(lead.follow_up_at).getTime() < nowTime &&
        !["converted", "closed_lost"].includes(lead.status)
    ).length;

    return {
      waitlist,
      demo,
      both,
      overdue,
      active: activeLeads.length,
      archived: leads.length - activeLeads.length,
      conversion: activeLeads.length
        ? Math.round((both / activeLeads.length) * 100)
        : 0,
    };
  }, [leads, now]);

  const statusCounts = LEAD_STATUSES.map((leadStatus) => ({
    status: leadStatus,
    count: leads.filter(
      (lead) => !lead.archived_at && lead.status === leadStatus
    ).length,
  }));
  const largestStatus = Math.max(1, ...statusCounts.map((item) => item.count));

  function resetFilterPage(callback: () => void) {
    callback();
    setPage(1);
  }

  function updateLead(updatedLead: LeadRecord) {
    setLeads((current) =>
      current.map((lead) => (lead.id === updatedLead.id ? updatedLead : lead))
    );
    setSelectedLead(updatedLead);
  }

  function removeLead(id: string) {
    setLeads((current) => current.filter((lead) => lead.id !== id));
    setSelectedLead(null);
  }

  function exportCsv() {
    const headers = [
      "Name",
      "Email",
      "Country",
      "Audience",
      "Sources",
      "Status",
      "Priority",
      "Owner",
      "Follow up",
      "Created",
      "Notes",
    ];
    const ownerNames = new Map(
      admins.map((admin) => [admin.id, admin.display_name])
    );
    const rows = filteredLeads.map((lead) => [
      lead.full_name,
      lead.email,
      lead.country,
      lead.audience_role,
      lead.sources.join(" + "),
      lead.status,
      lead.priority,
      lead.assigned_admin_id
        ? ownerNames.get(lead.assigned_admin_id) ?? ""
        : "",
      lead.follow_up_at ?? "",
      lead.created_at,
      lead.internal_notes ?? "",
    ]);
    const csv = [headers, ...rows]
      .map((row) => row.map(csvCell).join(","))
      .join("\n");
    const url = URL.createObjectURL(new Blob([csv], { type: "text/csv" }));
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.download = `kwanpay-leads-${now.slice(0, 10)}.csv`;
    anchor.click();
    URL.revokeObjectURL(url);
  }

  return (
    <div className="space-y-8">
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-5">
        <StatCard
          title="Active members"
          value={metrics.active}
          helper={`${metrics.archived} archived`}
        />
        <StatCard title="Early access" value={metrics.waitlist} helper="Waitlist signups" />
        <StatCard title="Demo requests" value={metrics.demo} helper="Sales conversations" />
        <StatCard title="Cross-funnel rate" value={`${metrics.conversion}%`} helper={`${metrics.both} appear in both`} />
        <StatCard title="Overdue follow-ups" value={metrics.overdue} helper="Needs attention" />
      </div>

      <section className="grid gap-6 xl:grid-cols-[1.6fr_1fr]">
        <div>
          <LeadFilters
            search={search}
            source={source}
            status={status}
            owner={owner}
            archive={archive}
            pageSize={pageSize}
            admins={admins}
            onSearchChange={(value) =>
              resetFilterPage(() => setSearch(value))
            }
            onSourceChange={(value) =>
              resetFilterPage(() => setSource(value))
            }
            onStatusChange={(value) =>
              resetFilterPage(() => setStatus(value))
            }
            onOwnerChange={(value) =>
              resetFilterPage(() => setOwner(value))
            }
            onArchiveChange={(value) =>
              resetFilterPage(() => setArchive(value))
            }
            onPageSizeChange={(value) =>
              resetFilterPage(() => setPageSize(value))
            }
            onExport={exportCsv}
          />
        </div>
        <div className="rounded-3xl border border-slate-200 bg-white p-6">
          <h2 className="text-lg font-bold text-[#1E2340]">Pipeline status</h2>
          <div className="mt-5 space-y-3">
            {statusCounts.map((item) => (
              <div key={item.status}>
                <div className="flex justify-between text-xs capitalize text-slate-500">
                  <span>{item.status.replace("_", " ")}</span>
                  <span>{item.count}</span>
                </div>
                <div className="mt-1 h-2 rounded-full bg-slate-100">
                  <div
                    className="h-2 rounded-full bg-[#D98E3B]"
                    style={{ width: `${(item.count / largestStatus) * 100}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
        <LeadsTable
          leads={visibleLeads}
          admins={admins}
          now={now}
          onSelect={setSelectedLead}
        />
        <Pagination
          page={currentPage}
          pageCount={pageCount}
          total={filteredLeads.length}
          onPageChange={setPage}
        />
      </section>

      <AdminUsersPanel
        currentAdmin={currentAdmin}
        users={admins}
        onUsersChange={setAdmins}
      />

      {selectedLead && (
        <LeadPanel
          key={selectedLead.id}
          lead={selectedLead}
          admins={admins}
          canEdit={hasAdminRole(currentAdmin.role, "operator")}
          canDelete={currentAdmin.role === "owner"}
          onClose={() => setSelectedLead(null)}
          onDeleted={removeLead}
          onUpdated={updateLead}
        />
      )}
    </div>
  );
}
