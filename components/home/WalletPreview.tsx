import { ArrowDownLeft, ArrowUpRight, Plus, RefreshCw, Send, Store } from "lucide-react";

const actions = [
  { icon: Plus, label: "Add" },
  { icon: Send, label: "Send" },
  { icon: Store, label: "Pay" },
  { icon: RefreshCw, label: "Convert" },
];

const activity = [
  { icon: Store, title: "Cape Coast Castle tour", meta: "Payment · Today", amount: "−GHS 350.00", out: true },
  { icon: ArrowDownLeft, title: "From Akosua M.", meta: "Transfer · Yesterday", amount: "+GHS 200.00", out: false },
  { icon: ArrowUpRight, title: "Accra–Ho shuttle", meta: "Payment · Mon", amount: "−GHS 120.00", out: true },
];

/** Home screen of the KwanPay app, mirroring the real layout with sample data. */
export function WalletPreview() {
  return (
    <div className="px-4 pb-6 pt-12 text-left">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-[11px] text-muted">Good morning</p>
          <p className="text-[15px] font-bold text-ink">Ama Owusu</p>
        </div>
        <span className="flex h-9 w-9 items-center justify-center rounded-full bg-ink text-xs font-bold text-white">
          AO
        </span>
      </div>

      <div className="mt-4 rounded-3xl bg-ink p-5 text-white">
        <p className="text-[11px] text-white/60">Total balance</p>
        <p className="mt-1 text-[26px] font-extrabold tracking-tight tabular-nums">GHS 1,240.00</p>
        <p className="text-[11px] text-white/60 tabular-nums">≈ USD 81.70</p>
        <div className="mt-4 flex gap-2 text-[11px]">
          <span className="rounded-full bg-white/10 px-2.5 py-1">GHS</span>
          <span className="rounded-full bg-white/10 px-2.5 py-1 text-white/70">USD</span>
          <span className="rounded-full bg-white/10 px-2.5 py-1 text-white/70">NGN</span>
        </div>
      </div>

      <div className="mt-4 grid grid-cols-4 gap-2">
        {actions.map(({ icon: Icon, label }) => (
          <div key={label} className="flex flex-col items-center gap-1.5">
            <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-ink shadow-card">
              <Icon size={18} strokeWidth={2.2} aria-hidden />
            </span>
            <span className="text-[11px] font-medium text-charcoal">{label}</span>
          </div>
        ))}
      </div>

      <p className="mt-5 text-[12px] font-semibold text-ink">Recent activity</p>
      <ul className="mt-2 space-y-2">
        {activity.map(({ icon: Icon, title, meta, amount, out }) => (
          <li key={title} className="flex items-center gap-3 rounded-2xl bg-white p-2.5">
            <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-amber-tint text-amber-deep">
              <Icon size={15} aria-hidden />
            </span>
            <span className="min-w-0 flex-1">
              <span className="block truncate text-[12px] font-semibold text-ink">{title}</span>
              <span className="block text-[10px] text-muted">{meta}</span>
            </span>
            <span
              className={`text-[12px] font-semibold tabular-nums ${out ? "text-charcoal" : "text-success"}`}
            >
              {amount}
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}
