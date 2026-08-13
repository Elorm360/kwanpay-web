"use client";

import { useEffect, useState } from "react";

import {
  LEAD_PRIORITIES,
  LEAD_STATUSES,
  type AdminUser,
  type LeadAuditEvent,
  type LeadPriority,
  type LeadRecord,
  type LeadStatus,
} from "@/lib/admin-types";

function toLocalDateTime(value: string | null) {
  if (!value) return "";
  const date = new Date(value);
  const offset = date.getTimezoneOffset() * 60_000;
  return new Date(date.getTime() - offset).toISOString().slice(0, 16);
}

export default function LeadPanel({
  lead,
  admins,
  canEdit,
  canDelete,
  onClose,
  onDeleted,
  onUpdated,
}: {
  lead: LeadRecord;
  admins: AdminUser[];
  canEdit: boolean;
  canDelete: boolean;
  onClose: () => void;
  onDeleted: (id: string) => void;
  onUpdated: (lead: LeadRecord) => void;
}) {
  const [status, setStatus] = useState<LeadStatus>(lead.status);
  const [priority, setPriority] = useState<LeadPriority>(lead.priority);
  const [owner, setOwner] = useState(lead.assigned_admin_id ?? "");
  const [notes, setNotes] = useState(lead.internal_notes ?? "");
  const [followUp, setFollowUp] = useState(toLocalDateTime(lead.follow_up_at));
  const [events, setEvents] = useState<LeadAuditEvent[]>([]);
  const [saving, setSaving] = useState(false);
  const [managing, setManaging] = useState(false);
  const [copied, setCopied] = useState(false);
  const [deleteConfirmation, setDeleteConfirmation] = useState("");
  const [error, setError] = useState<string | null>(null);

  async function loadAudit() {
    const response = await fetch(`/api/admin/leads/${lead.id}/audit`);
    if (response.ok) {
      const data = await response.json();
      setEvents(data.events);
    }
  }

  useEffect(() => {
    void loadAudit();
    // The panel is keyed by lead id, so this runs once per selected lead.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [lead.id]);

  async function save() {
    setSaving(true);
    setError(null);

    const response = await fetch(`/api/admin/leads/${lead.id}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        status,
        priority,
        assigned_admin_id: owner || null,
        internal_notes: notes || null,
        follow_up_at: followUp ? new Date(followUp).toISOString() : null,
      }),
    });
    const data = await response.json();

    if (!response.ok) {
      setError(data.error ?? "Unable to save changes.");
      setSaving(false);
      return;
    }

    onUpdated(data.lead);
    await loadAudit();
    setSaving(false);
  }

  async function copyEmail() {
    try {
      await navigator.clipboard.writeText(lead.email);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 2000);
    } catch {
      setError("Unable to copy the email address.");
    }
  }

  async function setArchived(archived: boolean) {
    setManaging(true);
    setError(null);
    const response = await fetch(`/api/admin/leads/${lead.id}/archive`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ archived }),
    });
    const data = await response.json();

    if (!response.ok) {
      setError(
        data.error ?? (archived ? "Unable to archive lead." : "Unable to restore lead.")
      );
      setManaging(false);
      return;
    }

    onUpdated(data.lead);
    await loadAudit();
    setManaging(false);
  }

  async function deleteLead() {
    if (deleteConfirmation !== lead.email) return;

    setManaging(true);
    setError(null);
    const response = await fetch(`/api/admin/leads/${lead.id}`, {
      method: "DELETE",
    });
    const data = await response.json();

    if (!response.ok) {
      setError(data.error ?? "Unable to delete lead.");
      setManaging(false);
      return;
    }

    onDeleted(lead.id);
  }

  return (
    <div className="fixed inset-0 z-50 flex justify-end bg-slate-950/30">
      <button
        type="button"
        aria-label="Close lead details"
        className="flex-1 cursor-default"
        onClick={onClose}
      />
      <aside className="h-full w-full max-w-xl overflow-y-auto bg-white p-6 sm:p-8">
        <div className="flex items-start justify-between gap-6">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.2em] text-[#D98E3B]">
              Lead details
            </p>
            <h2 className="mt-2 text-3xl font-black text-[#1E2340]">
              {lead.full_name}
            </h2>
            <div className="mt-2 flex flex-wrap items-center gap-2">
              <a
                href={`mailto:${lead.email}`}
                className="text-slate-500 underline-offset-4 hover:underline"
              >
                {lead.email}
              </a>
              <button
                type="button"
                onClick={copyEmail}
                className="rounded-full border border-slate-300 px-3 py-1 text-xs font-semibold text-slate-600"
              >
                {copied ? "Copied" : "Copy email"}
              </button>
            </div>
            {lead.archived_at && (
              <p className="mt-3 text-sm font-semibold text-slate-500">
                Archived {new Date(lead.archived_at).toLocaleString()}
              </p>
            )}
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-full border border-slate-300 px-4 py-2 text-sm"
          >
            Close
          </button>
        </div>

        <div className="mt-8 grid grid-cols-2 gap-4 rounded-2xl bg-slate-50 p-5 text-sm">
          <div>
            <p className="text-slate-400">Country</p>
            <p className="mt-1 font-semibold text-slate-700">{lead.country}</p>
          </div>
          <div>
            <p className="text-slate-400">Audience</p>
            <p className="mt-1 font-semibold text-slate-700">
              {lead.audience_role}
            </p>
          </div>
          {lead.company && (
            <div className="col-span-2">
              <p className="text-slate-400">Company</p>
              <p className="mt-1 font-semibold text-slate-700">{lead.company}</p>
            </div>
          )}
          {lead.message && (
            <div className="col-span-2">
              <p className="text-slate-400">Request message</p>
              <p className="mt-1 leading-6 text-slate-700">{lead.message}</p>
            </div>
          )}
        </div>

        <div className="mt-8 space-y-5">
          <div className="grid gap-4 sm:grid-cols-2">
            <label className="text-sm font-semibold text-slate-700">
              Status
              <select
                value={status}
                disabled={!canEdit}
                onChange={(event) => setStatus(event.target.value as LeadStatus)}
                className="mt-2 w-full rounded-2xl border border-slate-300 px-4 py-3 font-normal"
              >
                {LEAD_STATUSES.map((value) => (
                  <option key={value} value={value}>
                    {value.replace("_", " ")}
                  </option>
                ))}
              </select>
            </label>
            <label className="text-sm font-semibold text-slate-700">
              Priority
              <select
                value={priority}
                disabled={!canEdit}
                onChange={(event) =>
                  setPriority(event.target.value as LeadPriority)
                }
                className="mt-2 w-full rounded-2xl border border-slate-300 px-4 py-3 font-normal"
              >
                {LEAD_PRIORITIES.map((value) => (
                  <option key={value} value={value}>
                    {value}
                  </option>
                ))}
              </select>
            </label>
          </div>

          <label className="block text-sm font-semibold text-slate-700">
            Owner
            <select
              value={owner}
              disabled={!canEdit}
              onChange={(event) => setOwner(event.target.value)}
              className="mt-2 w-full rounded-2xl border border-slate-300 px-4 py-3 font-normal"
            >
              <option value="">Unassigned</option>
              {admins
                .filter((admin) => admin.is_active)
                .map((admin) => (
                  <option key={admin.id} value={admin.id}>
                    {admin.display_name}
                  </option>
                ))}
            </select>
          </label>

          <label className="block text-sm font-semibold text-slate-700">
            Follow-up
            <input
              type="datetime-local"
              value={followUp}
              disabled={!canEdit}
              onChange={(event) => setFollowUp(event.target.value)}
              className="mt-2 w-full rounded-2xl border border-slate-300 px-4 py-3 font-normal"
            />
          </label>

          <label className="block text-sm font-semibold text-slate-700">
            Internal notes
            <textarea
              rows={5}
              value={notes}
              disabled={!canEdit}
              onChange={(event) => setNotes(event.target.value)}
              placeholder="Record context, next steps, and conversation notes."
              className="mt-2 w-full resize-y rounded-2xl border border-slate-300 px-4 py-3 font-normal"
            />
          </label>

          {error && <p className="text-sm font-medium text-red-600">{error}</p>}
          {canEdit && (
            <button
              type="button"
              disabled={saving}
              onClick={save}
              className="rounded-full bg-[#D98E3B] px-6 py-3 font-semibold text-white disabled:opacity-50"
            >
              {saving ? "Saving..." : "Save changes"}
            </button>
          )}
        </div>

        <div className="mt-10 border-t border-slate-200 pt-8">
          <h3 className="text-lg font-bold text-[#1E2340]">Activity history</h3>
          <div className="mt-5 space-y-4">
            {events.map((event) => (
              <div key={event.id} className="border-l-2 border-slate-200 pl-4">
                <p className="text-sm font-semibold capitalize text-slate-700">
                  {event.action.replaceAll("_", " ")}
                </p>
                <p className="mt-1 text-xs text-slate-500">
                  {event.actor_admin_id
                    ? admins.find(
                        (admin) => admin.id === event.actor_admin_id
                      )?.display_name ?? "Former administrator"
                    : "Website submission"}
                  {Object.keys(event.changes).length
                    ? ` · ${Object.keys(event.changes)
                        .map((field) => field.replaceAll("_", " "))
                        .join(", ")}`
                    : ""}
                </p>
                <p className="mt-1 text-xs text-slate-400">
                  {new Date(event.created_at).toLocaleString()}
                </p>
              </div>
            ))}
            {events.length === 0 && (
              <p className="text-sm text-slate-500">No activity recorded yet.</p>
            )}
          </div>
        </div>

        {canEdit && (
          <div className="mt-10 border-t border-slate-200 pt-8">
            <h3 className="text-lg font-bold text-[#1E2340]">
              Member management
            </h3>
            <p className="mt-2 text-sm leading-6 text-slate-500">
              Archive members to remove them from the active list while keeping
              their history.
            </p>
            <button
              type="button"
              disabled={managing}
              onClick={() => setArchived(!lead.archived_at)}
              className="mt-4 rounded-full border border-slate-300 px-5 py-2.5 text-sm font-semibold text-slate-700 disabled:opacity-50"
            >
              {managing
                ? "Updating..."
                : lead.archived_at
                  ? "Restore member"
                  : "Archive member"}
            </button>
          </div>
        )}

        {canDelete && (
          <div className="mt-8 rounded-2xl border border-red-200 bg-red-50 p-5">
            <h3 className="font-bold text-red-800">Delete permanently</h3>
            <p className="mt-2 text-sm leading-6 text-red-700">
              This removes the member and their activity history. Enter{" "}
              <strong>{lead.email}</strong> to confirm.
            </p>
            <input
              type="email"
              value={deleteConfirmation}
              onChange={(event) => setDeleteConfirmation(event.target.value)}
              placeholder={lead.email}
              className="mt-4 w-full rounded-xl border border-red-200 bg-white px-4 py-3 text-sm"
            />
            <button
              type="button"
              disabled={managing || deleteConfirmation !== lead.email}
              onClick={deleteLead}
              className="mt-3 rounded-full bg-red-700 px-5 py-2.5 text-sm font-semibold text-white disabled:opacity-40"
            >
              Delete member permanently
            </button>
          </div>
        )}
      </aside>
    </div>
  );
}
