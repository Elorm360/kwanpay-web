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

  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault();

    setLoading(true);

    const res = await fetch("/api/admin/login", {
      method: "POST",
      body: JSON.stringify({ password }),
    });

    const data = await res.json();

    setLoading(false);

    if (data.success) {
      router.push("/admin");
    } else {
      alert("Incorrect password");
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
          Enter your administrator password.
        </p>

        <form
          onSubmit={handleLogin}
          className="mt-10 space-y-6"
        >

          <input
            type="password"
            placeholder="Password"
            className="w-full rounded-2xl border border-slate-300 px-5 py-4"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />

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