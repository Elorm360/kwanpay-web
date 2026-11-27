"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

import { adminPasswordProblem } from "@/lib/admin-password";

type Mode = "signin" | "request" | "reset";

const inputClass =
  "w-full rounded-2xl border border-slate-300 px-5 py-4 outline-none focus:border-[#1E2340]";
const primaryClass =
  "w-full rounded-full bg-[#D98E3B] py-4 font-semibold text-[#1E2340] disabled:opacity-60";
const linkClass =
  "text-sm font-semibold text-[#1E2340] underline-offset-4 hover:underline";

async function post(url: string, body: unknown) {
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const data = await res.json().catch(() => ({}));
  return { ok: res.ok && data.success, data };
}

export default function AdminLogin() {
  const router = useRouter();

  const [mode, setMode] = useState<Mode>("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [code, setCode] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);

  function go(next: Mode) {
    setMode(next);
    setError(null);
    setNotice(null);
  }

  async function run(task: () => Promise<void>) {
    setError(null);
    setLoading(true);
    try {
      await task();
    } catch {
      setError("Unable to reach the server. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  function handleLogin(e: React.FormEvent) {
    e.preventDefault();
    void run(async () => {
      const { ok, data } = await post("/api/admin/login", { email, password });
      if (ok) {
        router.push("/admin");
        router.refresh();
        return;
      }
      setError(data.error ?? "Unable to sign in.");
    });
  }

  function handleRequest(e: React.FormEvent) {
    e.preventDefault();
    void run(async () => {
      const { ok, data } = await post("/api/admin/password/request", { email });
      if (!ok) {
        setError(data.error ?? "Unable to send a code.");
        return;
      }
      setMode("reset");
      setNotice(data.message);
    });
  }

  function handleReset(e: React.FormEvent) {
    e.preventDefault();
    const problem = adminPasswordProblem(newPassword, email);
    if (problem) return setError(problem);
    if (newPassword !== confirmPassword) {
      return setError("The two passwords do not match.");
    }
    void run(async () => {
      const { ok, data } = await post("/api/admin/password/reset", {
        email,
        code,
        password: newPassword,
      });
      if (!ok) {
        setError(data.error ?? "Unable to change the password.");
        return;
      }
      setPassword("");
      setCode("");
      setNewPassword("");
      setConfirmPassword("");
      setMode("signin");
      setNotice("Password changed. Sign in with your new password.");
    });
  }

  const title = {
    signin: "KwanPay Admin",
    request: "Reset your password",
    reset: "Choose a new password",
  }[mode];

  const intro = {
    signin: "Sign in with your administrator account.",
    request:
      "Enter your administrator email and we will send you a code to set a new password.",
    reset: "Enter the code from the email and your new password.",
  }[mode];

  return (
    <main className="flex min-h-screen items-center justify-center bg-[#EDEFF0] px-6">
      <div className="w-full max-w-md rounded-3xl bg-white p-8 shadow-2xl sm:p-10">
        <h1 className="text-center text-4xl font-black text-[#1E2340]">
          {title}
        </h1>
        <p className="mt-3 text-center text-slate-500">{intro}</p>

        {notice && (
          <p
            role="status"
            className="mt-6 rounded-2xl bg-emerald-50 px-4 py-3 text-sm text-emerald-800"
          >
            {notice}
          </p>
        )}

        {mode === "signin" && (
          <form onSubmit={handleLogin} className="mt-8 space-y-5">
            <input
              type="email"
              placeholder="Email address"
              aria-label="Administrator email"
              autoComplete="email"
              required
              className={inputClass}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <input
              type="password"
              placeholder="Password"
              aria-label="Administrator password"
              autoComplete="current-password"
              required
              className={inputClass}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            {error && (
              <p role="alert" className="text-sm font-medium text-red-600">
                {error}
              </p>
            )}
            <button disabled={loading} className={primaryClass}>
              {loading ? "Signing in…" : "Sign in"}
            </button>
            <p className="text-center">
              <button type="button" onClick={() => go("request")} className={linkClass}>
                Forgot password?
              </button>
            </p>
          </form>
        )}

        {mode === "request" && (
          <form onSubmit={handleRequest} className="mt-8 space-y-5">
            <input
              type="email"
              placeholder="Email address"
              aria-label="Administrator email"
              autoComplete="email"
              required
              className={inputClass}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            {error && (
              <p role="alert" className="text-sm font-medium text-red-600">
                {error}
              </p>
            )}
            <button disabled={loading} className={primaryClass}>
              {loading ? "Sending…" : "Send code"}
            </button>
            <p className="text-center">
              <button type="button" onClick={() => go("signin")} className={linkClass}>
                Back to sign in
              </button>
            </p>
          </form>
        )}

        {mode === "reset" && (
          <form onSubmit={handleReset} className="mt-8 space-y-5">
            <p className="text-center text-sm text-slate-600">
              Code sent to <span className="font-semibold">{email}</span>
            </p>
            <input
              inputMode="numeric"
              placeholder="Code from the email"
              aria-label="Reset code"
              autoComplete="one-time-code"
              required
              maxLength={10}
              className={`${inputClass} text-center font-mono tracking-[0.3em]`}
              value={code}
              onChange={(e) => setCode(e.target.value.replace(/\D/g, ""))}
            />
            <input
              type="password"
              placeholder="New password"
              aria-label="New password"
              autoComplete="new-password"
              required
              className={inputClass}
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
            />
            <input
              type="password"
              placeholder="New password again"
              aria-label="Confirm new password"
              autoComplete="new-password"
              required
              className={inputClass}
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
            />
            <p className="text-xs text-slate-500">
              At least 12 characters, with letters and a number.
            </p>
            {error && (
              <p role="alert" className="text-sm font-medium text-red-600">
                {error}
              </p>
            )}
            <button disabled={loading} className={primaryClass}>
              {loading ? "Saving…" : "Set new password"}
            </button>
            <p className="flex justify-center gap-6">
              <button type="button" onClick={() => go("request")} className={linkClass}>
                Send a new code
              </button>
              <button type="button" onClick={() => go("signin")} className={linkClass}>
                Back to sign in
              </button>
            </p>
          </form>
        )}
      </div>
    </main>
  );
}
