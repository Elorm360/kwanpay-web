import type { ReactNode } from "react";

/**
 * Formerly a 3D mouse-tilt wrapper. The effect was removed as part of the
 * design pass (gimmicky, and invisible on touch devices); the component is
 * kept as a plain wrapper so existing layouts keep their structure.
 */
export default function TiltCard({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
  maxTilt?: number;
}) {
  return <div className={className}>{children}</div>;
}
