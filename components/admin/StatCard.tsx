const BRAND = {
  indigo: "#1E2340",
  amber: "#D98E3B",
};

type Props = {
  title: string;
  value: number;
};

export default function StatCard({
  title,
  value,
}: Props) {
  return (
    <div className="rounded-3xl bg-white border border-slate-200 p-8 shadow-lg hover:shadow-xl transition">

      <div
        className="h-12 w-12 rounded-2xl flex items-center justify-center text-white font-bold"
        style={{ background: BRAND.amber }}
      >
        •
      </div>

      <p className="mt-6 text-slate-500">
        {title}
      </p>

      <h2
        className="mt-2 text-5xl font-black"
        style={{ color: BRAND.indigo }}
      >
        {value}
      </h2>

    </div>
  );
}