import { ImageResponse } from "next/og";

export const alt = "KwanPay — One Wallet. Every Journey. Across Africa.";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

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
          background:
            "radial-gradient(circle at 85% 20%, rgba(217,142,59,0.35), transparent 45%), linear-gradient(135deg, #1E2340, #13162B)",
          color: "white",
          fontFamily: "sans-serif",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
          <div
            style={{
              width: 72,
              height: 72,
              borderRadius: 20,
              background: "rgba(255,255,255,0.08)",
              border: "1px solid rgba(255,255,255,0.15)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none">
              <path
                d="M6 18C10 12 14 12 18 6"
                stroke="#D98E3B"
                strokeWidth="2.5"
                strokeLinecap="round"
              />
              <circle cx="18" cy="6" r="2" fill="#D98E3B" />
            </svg>
          </div>
          <div style={{ display: "flex", fontSize: 44, fontWeight: 900 }}>
            Kwan<span style={{ color: "#D98E3B" }}>Pay</span>
          </div>
        </div>

        <div style={{ display: "flex", flexDirection: "column" }}>
          <div style={{ fontSize: 84, fontWeight: 900, lineHeight: 1.05 }}>
            One Wallet.
          </div>
          <div style={{ fontSize: 84, fontWeight: 900, lineHeight: 1.05 }}>
            Every Journey.
          </div>
          <div
            style={{
              fontSize: 84,
              fontWeight: 900,
              lineHeight: 1.05,
              color: "#D98E3B",
            }}
          >
            Across Africa.
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
          <span>Travel payments for travelers and tourism businesses</span>
          <span
            style={{
              padding: "10px 22px",
              borderRadius: 999,
              border: "1px solid rgba(217,142,59,0.6)",
              color: "#D98E3B",
              fontSize: 22,
              fontWeight: 700,
              letterSpacing: 3,
            }}
          >
            PRIVATE BETA
          </span>
        </div>
      </div>
    ),
    size
  );
}
