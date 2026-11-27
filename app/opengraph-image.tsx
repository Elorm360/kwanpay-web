import { ImageResponse } from "next/og";

export const alt = "KwanPay: pay for your whole trip in Ghana from one wallet.";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

// Same mark as components/Logo.tsx and the app icon.
function Mark() {
  return (
    <svg width="76" height="76" viewBox="0 0 64 64">
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

export default function OpengraphImage() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: "72px 80px",
          background: "#1E2340",
          color: "white",
          fontFamily: "sans-serif",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 22 }}>
          <Mark />
          <div style={{ display: "flex", fontSize: 46, fontWeight: 800 }}>
            <span>Kwan</span>
            <span style={{ color: "#D98E3B" }}>Pay</span>
          </div>
        </div>

        <div style={{ display: "flex", flexDirection: "column", maxWidth: 960 }}>
          <div style={{ fontSize: 78, fontWeight: 800, lineHeight: 1.06, letterSpacing: -2 }}>
            Pay for your whole trip in Ghana from one wallet.
          </div>
        </div>

        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            fontSize: 26,
            color: "rgba(255,255,255,0.7)",
          }}
        >
          <span>Tours, stays and rides · Built with TransVista Africa</span>
          <span
            style={{
              padding: "10px 22px",
              borderRadius: 999,
              background: "#D98E3B",
              color: "#1E2340",
              fontSize: 22,
              fontWeight: 700,
            }}
          >
            Private beta
          </span>
        </div>
      </div>
    ),
    size
  );
}
