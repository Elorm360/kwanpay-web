"use client";

import { useState } from "react";

import type { AdminUser } from "@/lib/admin-types";

export default function AdminUserPanel({
  currentAdmin,
  user,
  onClose,
  onDeleted,
  onUpdated,
}: {
  currentAdmin: AdminUser;
  user: AdminUser;
  onClose: () => void;
  onDeleted: (id: string) => Promise<boolean>;
  onUpdated: (id: string, changes: Partial<AdminUser>) => Promise<boolean>;
}) {
  const [copied, setCopied] = useState(false);
  const [confirmation, setConfirmation] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function copyEmail() {
    try {
      await navigator.clipboard.writeText(user.email);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 2000);
    } catch {
      setError("Unable to copy the email address.");
    }
  }

  async function toggleAccess() {
    setBusy(true);
    setError(null);
    const updated = await onUpdated(user.id, {
      is_active: !user.is_active,
    });
    if (!updated) setError("Unable to update administrator access.");
    setBusy(false);
  }

  async function deleteUser() {
    if (confirmation !== user.email) return;
    setBusy(true);
    setError(null);
    const deleted = await onDeleted(user.id);
    if (!deleted) setError("Unable to delete administrator.");
    setBusy(false);
  }

  const isCurrentAdmin = user.id === currentAdmin.id;

  return (
    <div className="fixed inset-0 z-50 flex justify-end bg-slate-950/30">
      <button
        type="button"
        aria-label="Close administrator details"
        className="flex-1 cursor-default"
        onClick={onClose}
      />
      <aside className="h-full w-full max-w-lg overflow-y-auto bg-white p-6 sm:p-8">
        <div className="flex items-start justify-between gap-6">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.2em] text-[#D98E3B]">
              Administrator details
            </p>
            <h2 className="mt-2 text-3xl font-black text-[#1E2340]">
              {user.display_name}
            </h2>
            <div className="mt-2 flex flex-wrap items-center gap-2">
              <a
                href={`mailto:${user.email}`}
                className="text-slate-500 underline-offset-4 hover:underline"
              >
                {user.email}
              </a>
              <button
                type="button"
                onClick={copyEmail}
                className="rounded-full border border-slate-300 px-3 py-1 text-xs font-semibold text-slate-600"
              >
                {copied ? "Copied" : "Copy email"}
              </button>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-full border border-slate-300 px-4 py-2 text-sm"
          >
            Close
          </button>
        </div>

        <dl className="mt-8 grid grid-cols-2 gap-4 rounded-2xl bg-slate-50 p-5 text-sm">
          <div>
            <dt className="text-slate-400">Role</dt>
            <dd className="mt-1 font-semibold capitalize text-slate-700">
              {user.role}
            </dd>
          </div>
          <div>
            <dt className="text-slate-400">Access</dt>
            <dd className="mt-1 font-semibold text-slate-700">
              {user.is_active ? "Active" : "Disabled"}
            </dd>
          </div>
          <div>
            <dt className="text-slate-400">Last login</dt>
            <dd className="mt-1 font-semibold text-slate-700">
              {user.last_login_at
                ? new Date(user.last_login_at).toLocaleString()
                : "Never"}
            </dd>
          </div>
          <div>
            <dt className="text-slate-400">Added</dt>
            <dd className="mt-1 font-semibold text-slate-700">
              {new Date(user.created_at).toLocaleString()}
            </dd>
          </div>
        </dl>

        <div className="mt-8 border-t border-slate-200 pt-8">
          <h3 className="text-lg font-bold text-[#1E2340]">
            Access management
          </h3>
          <p className="mt-2 text-sm leading-6 text-slate-500">
            Disable access without deleting the administrator or their
            assignment history.
          </p>
          <button
            type="button"
            disabled={busy || isCurrentAdmin}
            onClick={toggleAccess}
            className="mt-4 rounded-full border border-slate-300 px-5 py-2.5 text-sm font-semibold text-slate-700 disabled:opacity-40"
          >
            {user.is_active ? "Disable access" : "Restore access"}
          </button>
          {isCurrentAdmin && (
            <p className="mt-2 text-xs text-slate-500">
              You cannot disable or delete your own account.
            </p>
          )}
          {error && (
            <p className="mt-3 text-sm font-medium text-red-600">{error}</p>
          )}
        </div>

        {!isCurrentAdmin && (
          <div className="mt-8 rounded-2xl border border-red-200 bg-red-50 p-5">
            <h3 className="font-bold text-red-800">Delete permanently</h3>
            <p className="mt-2 text-sm leading-6 text-red-700">
              This removes the administrator account. Enter{" "}
              <strong>{user.email}</strong> to confirm.
            </p>
            <input
              type="email"
              value={confirmation}
              onChange={(event) => setConfirmation(event.target.value)}
              placeholder={user.email}
              className="mt-4 w-full rounded-xl border border-red-200 bg-white px-4 py-3 text-sm"
            />
            <button
              type="button"
              disabled={busy || confirmation !== user.email}
              onClick={deleteUser}
              className="mt-3 rounded-full bg-red-700 px-5 py-2.5 text-sm font-semibold text-white disabled:opacity-40"
            >
              Delete administrator permanently
            </button>
          </div>
        )}
      </aside>
    </div>
  );
}
