import Link from "next/link";
import { Compass } from "lucide-react";

import { BRAND } from "@/lib/brand";

export default function NotFound() {
  return (
    <main
      id="main"
      className="min-h-screen flex items-center justify-center px-6 py-20"
      style={{ background: BRAND.paper }}
    >
      <div className="max-w-lg text-center">
        <div
          className="mx-auto flex h-20 w-20 items-center justify-center rounded-3xl"
          style={{ background: "rgba(217,142,59,0.12)", color: BRAND.amber }}
        >
          <Compass size={36} aria-hidden />
        </div>
        <p
          className="mt-8 uppercase tracking-[0.35em] text-sm font-semibold"
          style={{ color: BRAND.amber }}
        >
          404
        </p>
        <h1
          className="mt-4 text-4xl md:text-5xl font-black tracking-tight"
          style={{ color: BRAND.indigo }}
        >
          This road doesn&apos;t lead anywhere.
        </h1>
        <p className="mt-6 text-lg leading-8 text-slate-600">
          The page you&apos;re looking for has moved or never existed. Let&apos;s
          get your journey back on track.
        </p>
        <div className="mt-10 flex flex-wrap justify-center gap-4">
          <Link
            href="/"
            className="rounded-full px-8 py-4 font-semibold text-white"
            style={{
              background: "linear-gradient(135deg, #D98E3B, #B56F28)",
              boxShadow: "0 10px 30px -8px rgba(217,142,59,.6)",
            }}
          >
            Back to Home
          </Link>
          <Link
            href="/waitlist"
            className="rounded-full px-8 py-4 font-semibold border-2 border-slate-300 bg-white/60"
            style={{ color: BRAND.indigo }}
          >
            Join Early Access
          </Link>
        </div>
      </div>
    </main>
  );
}
