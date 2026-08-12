"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

const BRAND = {
  indigo: "#1E2340",
  amber: "#D98E3B",
  paper: "#EDEFF0",
};

export default function AdminLogin() {
  const router = useRouter();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const res = await fetch("/api/admin/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        router.push("/admin");
        router.refresh();
        return;
      }

      setError(data.error ?? "Unable to sign in.");
    } catch {
      setError("Unable to reach the server. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main
      className="min-h-screen flex items-center justify-center px-6"
      style={{ background: BRAND.paper }}
    >
      <div className="w-full max-w-md rounded-3xl bg-white p-10 shadow-2xl">

        <h1
          className="text-4xl font-black text-center"
          style={{ color: BRAND.indigo }}
        >
          KwanPay Admin
        </h1>

        <p className="mt-3 text-center text-slate-500">
          Sign in with your administrator account.
        </p>

        <form
          onSubmit={handleLogin}
          className="mt-10 space-y-6"
        >
          <input
            type="email"
            placeholder="Email address"
            aria-label="Administrator email"
            autoComplete="email"
            required
            className="w-full rounded-2xl border border-slate-300 px-5 py-4"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />

          <input
            type="password"
            placeholder="Password"
            aria-label="Administrator password"
            autoComplete="current-password"
            required
            className="w-full rounded-2xl border border-slate-300 px-5 py-4"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />

          {error && (
            <p role="alert" className="text-sm font-medium text-red-600">
              {error}
            </p>
          )}

          <button
            disabled={loading}
            className="w-full rounded-full py-4 text-white font-semibold"
            style={{
              background: BRAND.amber,
            }}
          >
            {loading ? "Signing In..." : "Sign In"}
          </button>

        </form>

      </div>
    </main>
  );
}