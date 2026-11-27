/** The KwanPay mark, identical to the app icon (kwanpay_app/assets/images/kwanpay_mark.svg). */
export function LogoMark({ size = 36, className = "" }: { size?: number; className?: string }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 64 64"
      aria-hidden
      className={className}
      xmlns="http://www.w3.org/2000/svg"
    >
      <rect width="64" height="64" rx="16" fill="#2A3154" />
      <path
        d="M16 50C18 34 30 40 34 28C37 18 44 16 48 16"
        fill="none"
        stroke="#D98E3B"
        strokeWidth="5.5"
        strokeLinecap="round"
      />
      <circle cx="16" cy="50" r="4.5" fill="#D98E3B" />
      <circle cx="48" cy="16" r="6" fill="none" stroke="#D98E3B" strokeWidth="3.5" />
    </svg>
  );
}

/** Mark plus wordmark. `onDark` switches the "Kwan" half to white. */
export function Logo({ onDark = false, size = 36 }: { onDark?: boolean; size?: number }) {
  return (
    <span className="inline-flex items-center gap-2.5">
      <LogoMark size={size} />
      <span className={`text-xl font-extrabold tracking-tight ${onDark ? "text-white" : "text-ink"}`}>
        Kwan<span className="text-amber">Pay</span>
      </span>
    </span>
  );
}
