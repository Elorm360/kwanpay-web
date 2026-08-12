"use client";

import { useState } from "react";

import {
  ADMIN_ROLES,
  type AdminRole,
  type AdminUser,
} from "@/lib/admin-types";

export default function AdminUsersPanel({
  currentAdmin,
  users,
  onUsersChange,
}: {
  currentAdmin: AdminUser;
  users: AdminUser[];
  onUsersChange: (users: AdminUser[]) => void;
}) {
  const [email, setEmail] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole] = useState<AdminRole>("operator");
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  if (currentAdmin.role !== "owner") return null;

  async function createUser(event: React.FormEvent) {
    event.preventDefault();
    setSaving(true);
    setError(null);

    const response = await fetch("/api/admin/users", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email,
        display_name: displayName,
        password,
        role,
      }),
    });
    const data = await response.json();

    if (!response.ok) {
      setError(data.error ?? "Unable to add administrator.");
      setSaving(false);
      return;
    }

    onUsersChange([...users, data.user]);
    setEmail("");
    setDisplayName("");
    setPassword("");
    setRole("operator");
    setSaving(false);
  }

  async function updateUser(id: string, changes: Partial<AdminUser>) {
    setError(null);
    const response = await fetch(`/api/admin/users/${id}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(changes),
    });
    const data = await response.json();

    if (!response.ok) {
      setError(data.error ?? "Unable to update administrator.");
      return;
    }

    onUsersChange(users.map((user) => (user.id === id ? data.user : user)));
  }

  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-6 sm:p-8">
      <div>
        <p className="text-xs font-bold uppercase tracking-[0.2em] text-[#D98E3B]">
          Access management
        </p>
        <h2 className="mt-2 text-2xl font-black text-[#1E2340]">
          Administrator accounts
        </h2>
      </div>

      <div className="mt-6 overflow-x-auto">
        <table className="min-w-full text-sm">
          <thead className="text-left text-slate-400">
            <tr>
              <th className="pb-3 font-medium">Administrator</th>
              <th className="pb-3 font-medium">Role</th>
              <th className="pb-3 font-medium">Access</th>
              <th className="pb-3 font-medium">Last login</th>
            </tr>
          </thead>
          <tbody>
            {users.map((user) => (
              <tr key={user.id} className="border-t border-slate-100">
                <td className="py-4 pr-5">
                  <p className="font-semibold text-slate-700">
                    {user.display_name}
                  </p>
                  <p className="text-xs text-slate-400">{user.email}</p>
                </td>
                <td className="py-4 pr-5">
                  <select
                    value={user.role}
                    disabled={user.id === currentAdmin.id}
                    onChange={(event) =>
                      updateUser(user.id, {
                        role: event.target.value as AdminRole,
                      })
                    }
                    className="rounded-xl border border-slate-300 px-3 py-2 capitalize disabled:opacity-60"
                  >
                    {ADMIN_ROLES.map((adminRole) => (
                      <option key={adminRole} value={adminRole}>
                        {adminRole}
                      </option>
                    ))}
                  </select>
                </td>
                <td className="py-4 pr-5">
                  <button
                    type="button"
                    disabled={user.id === currentAdmin.id}
                    onClick={() =>
                      updateUser(user.id, { is_active: !user.is_active })
                    }
                    className={`rounded-full px-3 py-1.5 text-xs font-semibold ${
                      user.is_active
                        ? "bg-emerald-50 text-emerald-700"
                        : "bg-slate-100 text-slate-500"
                    } disabled:opacity-60`}
                  >
                    {user.is_active ? "Active" : "Disabled"}
                  </button>
                </td>
                <td className="py-4 text-slate-500">
                  {user.last_login_at
                    ? new Date(user.last_login_at).toLocaleDateString()
                    : "Never"}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <form
        onSubmit={createUser}
        className="mt-8 grid gap-3 border-t border-slate-200 pt-6 md:grid-cols-2 xl:grid-cols-5"
      >
        <input
          value={displayName}
          onChange={(event) => setDisplayName(event.target.value)}
          placeholder="Display name"
          required
          className="rounded-2xl border border-slate-300 px-4 py-3"
        />
        <input
          type="email"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          placeholder="Email address"
          required
          className="rounded-2xl border border-slate-300 px-4 py-3"
        />
        <input
          type="password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          placeholder="Temporary password"
          minLength={12}
          required
          className="rounded-2xl border border-slate-300 px-4 py-3"
        />
        <select
          value={role}
          onChange={(event) => setRole(event.target.value as AdminRole)}
          className="rounded-2xl border border-slate-300 px-4 py-3 capitalize"
        >
          {ADMIN_ROLES.map((adminRole) => (
            <option key={adminRole} value={adminRole}>
              {adminRole}
            </option>
          ))}
        </select>
        <button
          disabled={saving}
          className="rounded-full bg-[#D98E3B] px-5 py-3 font-semibold text-white disabled:opacity-50"
        >
          {saving ? "Adding..." : "Add admin"}
        </button>
      </form>
      {error && <p className="mt-4 text-sm font-medium text-red-600">{error}</p>}
    </section>
  );
}
