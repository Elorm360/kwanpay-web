"use client";

import { BRAND } from "@/lib/brand";

export default function Footer() {
  return (
    <footer
      className="px-6 py-20"
      style={{
        background: BRAND.charcoal,
      }}
    >
      <div className="max-w-7xl mx-auto">
        <div className="grid lg:grid-cols-4 gap-12">
          {/* Brand */}
          <div>
            <div className="flex items-center gap-4">
              <div
                className="h-11 w-11 rounded-2xl flex items-center justify-center"
                style={{
                  background: BRAND.indigo,
                }}
              >
                <svg
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="none"
                >
                  <path
                    d="M6 18C10 12 14 12 18 6"
                    stroke={BRAND.amber}
                    strokeWidth="2.5"
                    strokeLinecap="round"
                  />
                  <circle
                    cx="18"
                    cy="6"
                    r="2"
                    fill={BRAND.amber}
                  />
                </svg>
              </div>

              <div>
                <h2
                  className="text-2xl font-black"
                  style={{ color: "white" }}
                >
                  Kwan
                  <span style={{ color: BRAND.amber }}>Pay</span>
                </h2>

                <p className="text-sm text-slate-400">
                  The path your payment takes.
                </p>
              </div>
            </div>

            <p className="mt-8 text-slate-400 leading-8">
              KwanPay is building cross-border payment infrastructure
              designed for African tourism platforms, operators,
              and global travelers.
            </p>
          </div>

          {/* Company */}
          <div>
            <h3 className="text-white font-bold mb-6">Company</h3>
            <ul className="space-y-4 text-slate-400">
              <li>About</li>
              <li>Contact</li>
              <li>Early Access</li>
            </ul>
          </div>

          {/* Platform */}
          <div>
            <h3 className="text-white font-bold mb-6">Platform</h3>
            <ul className="space-y-4 text-slate-400">
              <li>For Travelers</li>
              <li>For Platforms</li>
              <li>Integration</li>
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h3 className="text-white font-bold mb-6">Contact</h3>
            <p className="text-slate-400">hello@kwanpay.africa</p>
            <p className="mt-5 text-slate-500 text-sm leading-7">
              Product of
              <br />
              TransVista Africa Ltd.
            </p>
          </div>
        </div>

        <div className="border-t border-white/10 mt-20 pt-10 flex flex-col md:flex-row justify-between items-center gap-5">
          <p className="text-slate-500">
            © {new Date().getFullYear()} KwanPay. All rights reserved.
          </p>
          <p className="text-slate-500">Built in Ghana 🇬🇭 for African Tourism.</p>
        </div>
      </div>
    </footer>
  );
}

