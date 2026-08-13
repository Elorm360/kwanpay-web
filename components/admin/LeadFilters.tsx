"use client";

import { LEAD_STATUSES, type AdminUser } from "@/lib/admin-types";

type Props = {
  search: string;
  source: string;
  status: string;
  owner: string;
  archive: string;
  pageSize: number;
  admins: AdminUser[];
  onSearchChange: (value: string) => void;
  onSourceChange: (value: string) => void;
  onStatusChange: (value: string) => void;
  onOwnerChange: (value: string) => void;
  onArchiveChange: (value: string) => void;
  onPageSizeChange: (value: number) => void;
  onExport: () => void;
};

const inputClass =
  "rounded-2xl border border-slate-300 bg-white px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500";

export default function LeadFilters(props: Props) {
  return (
    <div className="grid gap-3 rounded-3xl border border-slate-200 bg-white p-5 lg:grid-cols-[minmax(220px,2fr)_repeat(5,minmax(130px,1fr))_auto]">
      <input
        type="search"
        value={props.search}
        onChange={(event) => props.onSearchChange(event.target.value)}
        placeholder="Search name, email, company..."
        aria-label="Search leads"
        className={inputClass}
      />
      <select
        value={props.source}
        onChange={(event) => props.onSourceChange(event.target.value)}
        aria-label="Filter by source"
        className={inputClass}
      >
        <option value="all">All sources</option>
        <option value="waitlist">Early access</option>
        <option value="demo">Demo requests</option>
        <option value="both">Both sources</option>
      </select>
      <select
        value={props.status}
        onChange={(event) => props.onStatusChange(event.target.value)}
        aria-label="Filter by status"
        className={inputClass}
      >
        <option value="all">All statuses</option>
        {LEAD_STATUSES.map((status) => (
          <option key={status} value={status}>
            {status.replace("_", " ")}
          </option>
        ))}
      </select>
      <select
        value={props.owner}
        onChange={(event) => props.onOwnerChange(event.target.value)}
        aria-label="Filter by owner"
        className={inputClass}
      >
        <option value="all">All owners</option>
        <option value="unassigned">Unassigned</option>
        {props.admins
          .filter((admin) => admin.is_active)
          .map((admin) => (
            <option key={admin.id} value={admin.id}>
              {admin.display_name}
            </option>
          ))}
      </select>
      <select
        value={props.archive}
        onChange={(event) => props.onArchiveChange(event.target.value)}
        aria-label="Filter by archive state"
        className={inputClass}
      >
        <option value="active">Active members</option>
        <option value="archived">Archived members</option>
        <option value="all">All members</option>
      </select>
      <select
        value={props.pageSize}
        onChange={(event) => props.onPageSizeChange(Number(event.target.value))}
        aria-label="Rows per page"
        className={inputClass}
      >
        {[10, 25, 50].map((size) => (
          <option key={size} value={size}>
            {size} rows
          </option>
        ))}
      </select>
      <button
        type="button"
        onClick={props.onExport}
        className="rounded-full bg-[#1E2340] px-5 py-3 text-sm font-semibold text-white"
      >
        Export CSV
      </button>
    </div>
  );
}
