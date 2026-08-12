const BRAND = {
  indigo: "#1E2340",
  amber: "#D98E3B",
};

type Props = {
  title: string;
  value: number | string;
  helper?: string;
};

export default function StatCard({
  title,
  value,
  helper,
}: Props) {
  return (
    <div className="rounded-3xl bg-white border border-slate-200 p-6 shadow-sm">
      <div className="h-1 w-12 rounded-full" style={{ background: BRAND.amber }} />
      <p className="mt-5 text-sm text-slate-500">
        {title}
      </p>

      <h2
        className="mt-2 text-4xl font-black"
        style={{ color: BRAND.indigo }}
      >
        {value}
      </h2>
      {helper && <p className="mt-2 text-xs text-slate-400">{helper}</p>}
    </div>
  );
}