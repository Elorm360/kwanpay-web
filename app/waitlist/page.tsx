"use client";

import { useState } from "react";
import Link from "next/link";
import ToastNotification from "@/components/ToastNotification";


const BRAND = {
  indigo: "#1E2340",
  amber: "#D98E3B",
  paper: "#EDEFF0",
};

export default function WaitlistPage() {
  const [loading, setLoading] = useState(false);

  const [toast, setToast] = useState({
    open: false,
    kind: "success" as "success" | "error",
    title: "",
    messageLines: [] as string[],
  });


  const [form, setForm] = useState({
    full_name: "",
    email: "",
    country: "",
    role: "Traveler",
    company: "",
    message: "",
  });

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    setLoading(true);

    try {
      const res = await fetch("/api/waitlist", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(form),
      });

      type WaitlistResponse = { success?: boolean; error?: string };
      let data: WaitlistResponse | null = null;
      try {
        data = (await res.json()) as WaitlistResponse;
      } catch {
        data = null;
      }

      if (res.ok && data?.success) {
        setToast({
          open: true,
          kind: "success",
          title: "Early Access Requested",
          messageLines: [
            "Thank you for joining the KwanPay waitlist.",
            "We'll keep you updated.",
          ],
        });

        setForm({
          full_name: "",
          email: "",
          country: "",
          role: "Traveler",
          company: "",
          message: "",
        });
      } else {
        setToast({
          open: true,
          kind: "error",
          title: "Request failed",
          messageLines: [data?.error ?? "Something went wrong."],
        });
      }
    } catch (err) {
      console.error(err);

      setToast({
        open: true,
        kind: "error",
        title: "Request failed",
        messageLines: ["Something went wrong."],
      });
    }

    setLoading(false);
  }; 


  return (
    <>
      <ToastNotification
        open={toast.open}
        kind={toast.kind}
        title={toast.title}
        messageLines={toast.messageLines}
        onClose={() => setToast((t) => ({ ...t, open: false }))}
      />

      <main
        className="min-h-screen flex items-center justify-center px-6 py-20"
        style={{ background: BRAND.paper }}
      >
        <div className="w-full max-w-3xl">
          <div className="text-center">
            <div
              className="w-16 h-16 rounded-3xl mx-auto flex items-center justify-center"
              style={{
                background: BRAND.indigo,
              }}
            >
            <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
              <path
                d="M6 18C10 12 14 12 18 6"
                stroke={BRAND.amber}
                strokeWidth="2.5"
                strokeLinecap="round"
              />
              <circle cx="18" cy="6" r="2" fill={BRAND.amber} />
            </svg>
          </div>

          <h1
            className="mt-8 text-5xl font-black"
            style={{ color: BRAND.indigo }}
          >
            Join Early Access
          </h1>

          <p className="mt-6 text-lg text-slate-600 leading-8">
            Be among the first travelers, tourism businesses and platforms helping shape the future of cross-border tourism payments in Africa.
          </p>
        </div>

        <div className="mt-14 bg-white rounded-[32px] shadow-2xl border border-slate-200 p-10">
          <form
            onSubmit={handleSubmit}
            className="space-y-7"
          >
            <div>
              <label className="block mb-2 font-medium text-slate-700">
                Full Name
              </label>
              <input
                type="text"
                placeholder="John Doe"
                value={form.full_name}
                onChange={(e) =>
                  setForm({
                    ...form,
                    full_name: e.target.value,
                  })
                }
                className="w-full rounded-2xl border border-slate-300 px-5 py-4 focus:outline-none focus:ring-2"
              />
            </div>

            <div>
              <label className="block mb-2 font-medium text-slate-700">
                Email Address
              </label>
              <input
                type="email"
                placeholder="john@example.com"
                value={form.email}
                onChange={(e) =>
                  setForm({
                    ...form,
                    email: e.target.value,
                  })
                }
                className="w-full rounded-2xl border border-slate-300 px-5 py-4 focus:outline-none focus:ring-2"
              />
            </div>

            <div>
              <label className="block mb-2 font-medium text-slate-700">
                Country
              </label>
              <input
                type="text"
                placeholder="Ghana"
                value={form.country}
                onChange={(e) =>
                  setForm({
                    ...form,
                    country: e.target.value,
                  })
                }
                className="w-full rounded-2xl border border-slate-300 px-5 py-4 focus:outline-none focus:ring-2"
              />
            </div>

            <div>
              <label className="block mb-2 font-medium text-slate-700">
                I am a...
              </label>
              <select
                value={form.role}
                onChange={(e) =>
                  setForm({
                    ...form,
                    role: e.target.value,
                  })
                }
                className="w-full rounded-2xl border border-slate-300 px-5 py-4"
              >
                <option>Traveler</option>
                <option>Tourism Operator</option>
                <option>Platform Owner</option>
                <option>Investor</option>
                <option>Other</option>
              </select>
            </div>

            <div>
              <label className="block mb-2 font-medium text-slate-700">
                Company (Optional)
              </label>
              <input
                type="text"
                placeholder="Company name"
                value={form.company}
                onChange={(e) =>
                  setForm({
                    ...form,
                    company: e.target.value,
                  })
                }
                className="w-full rounded-2xl border border-slate-300 px-5 py-4"
              />
            </div>

            <div>
              <label className="block mb-2 font-medium text-slate-700">
                How would you use KwanPay?
              </label>
              <textarea
                rows={5}
                placeholder="Tell us a little about yourself..."
                value={form.message}
                onChange={(e) =>
                  setForm({
                    ...form,
                    message: e.target.value,
                  })
                }
                className="w-full rounded-2xl border border-slate-300 px-5 py-4"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full rounded-full py-4 text-lg font-semibold text-white transition-all duration-300 hover:scale-[1.02]"
              style={{ background: BRAND.amber }}
            >
              {loading ? "Submitting..." : "Request Early Access"}
            </button>
          </form>
        </div>

        <div className="text-center mt-10">
          <Link href="/" className="text-slate-500 hover:underline">
             Back to Home
          </Link>
        </div>
      </div>
    </main>
    </>
  );
}


