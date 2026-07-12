const BRAND = {
  indigo: "#1E2340",
};

type Person = {
  id: number;
  full_name: string;
  email: string;
  country: string;
  role: string;
  created_at?: string;
};

export default function WaitlistTable({
  people,
}: {
  people: Person[];
}) {
  return (
    <div className="rounded-3xl bg-white shadow-xl overflow-hidden border border-slate-200">

      <div className="px-8 py-6 border-b border-slate-200">

        <h2
          className="text-2xl font-bold"
          style={{ color: BRAND.indigo }}
        >
          Recent Signups
        </h2>

      </div>

      <div className="mt-10 overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-xl">
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead style={{ background: BRAND.indigo }}>
              <tr className="text-left text-white">
                <th className="px-6 py-5 font-semibold">Name</th>
                <th className="px-6 py-5 font-semibold">Email</th>
                <th className="px-6 py-5 font-semibold">Role</th>
                <th className="px-6 py-5 font-semibold">Country</th>
                <th className="px-6 py-5 font-semibold">Joined</th>
              </tr>
            </thead>

            <tbody>
              {people.map((person) => (
                <tr
                  key={person.id}
                  className="border-b border-slate-100 hover:bg-slate-50 transition"
                >
                  {/* Name */}
                  <td className="px-6 py-5">
                    <div className="flex items-center gap-4">
                      <div
                        className="flex h-12 w-12 items-center justify-center rounded-full font-bold text-white"
                        style={{ background: "#F59E0B" }}
                      >
                        {person.full_name?.charAt(0).toUpperCase()}
                      </div>

                      <div>
                        <p
                          className="font-semibold"
                          style={{ color: BRAND.indigo }}
                        >
                          {person.full_name}
                        </p>
                      </div>
                    </div>
                  </td>

                  {/* Email */}
                  <td className="px-6 py-5 text-slate-600">{person.email}</td>

                  {/* Role */}
                  <td className="px-6 py-5">
                    <span
                      className="rounded-full px-4 py-2 text-sm font-semibold"
                      style={{ background: "#FFF6EB", color: "#F59E0B" }}
                    >
                      {person.role}
                    </span>
                  </td>

                  {/* Country */}
                  <td className="px-6 py-5 text-slate-600">{person.country}</td>

                  {/* Joined */}
                  <td className="px-6 py-5 text-slate-500">
                    {person.created_at
                      ? new Date(person.created_at).toLocaleDateString("en-GB", {
                          day: "numeric",
                          month: "short",
                          year: "numeric",
                        })
                      : "—"}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}