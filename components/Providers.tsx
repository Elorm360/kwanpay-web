import type { ReactNode } from "react";

/** App-wide providers. Kept as a seam for future context (analytics, theme). */
export default function Providers({ children }: { children: ReactNode }) {
  return <>{children}</>;
}
