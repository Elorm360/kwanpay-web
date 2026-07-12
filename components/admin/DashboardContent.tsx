"use client";

import { useMemo, useState } from "react";
import WaitlistTable from "./WaitlistTable";

type Person = {
  id: number;
  full_name: string;
  email: string;
  company?: string;
  country: string;
  created_at?: string;
  // Admin UI expects `role` to exist (matches WaitlistTable prop typing)
  role: string;
};


export default function DashboardContent({
  people,
}: {
  people: Person[];
}) {
  const [search, setSearch] = useState("");
  const [role, setRole] = useState("All");

  const filteredPeople = useMemo(() => {
    return people.filter((person) => {
      const q = search.toLowerCase();

      const matchesSearch =
        person.full_name.toLowerCase().includes(q) ||
        person.email.toLowerCase().includes(q) ||
        (person.company?.toLowerCase().includes(q) ?? false) ||
        person.country.toLowerCase().includes(q);

      // If backend does not provide role yet, keep UI selectable without breaking.
      const matchesRole =
        role === "All" || ("role" in person && (person.role ?? "") === role);


      return matchesSearch && matchesRole;
    });
  }, [people, search, role]);

  return (
    <>
      <div className="mb-8 flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <input
          type="text"
          placeholder="Search by name or email..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full md:w-96 rounded-2xl border border-slate-300 px-5 py-3 focus:outline-none focus:ring-2 focus:ring-amber-500"
        />

        <select
          value={role}
          onChange={(e) => setRole(e.target.value)}
          className="rounded-2xl border border-slate-300 px-5 py-3"
        >
          <option>All</option>
          <option>Traveler</option>
          <option>Tourism Operator</option>
          <option>Platform Owner</option>
          <option>Investor</option>
          <option>Other</option>
        </select>
      </div>

      <WaitlistTable people={filteredPeople} />
    </>
  );
}

