/** Site-wide constants shared by metadata, sitemap, structured data and UI. */

function resolveSiteUrl() {
  const explicit = process.env.NEXT_PUBLIC_SITE_URL?.trim();
  if (explicit) return explicit.replace(/\/+$/, "");

  // Set automatically on Vercel to the production domain.
  const vercel = process.env.VERCEL_PROJECT_PRODUCTION_URL?.trim();
  if (vercel) return `https://${vercel}`;

  return "https://kwanpay.app";
}

export const SITE_URL = resolveSiteUrl();
export const SITE_NAME = "KwanPay";
export const SITE_TITLE = "KwanPay — Africa's Travel Wallet";
export const SITE_DESCRIPTION =
  "One wallet. Every journey. Across Africa. KwanPay helps travelers pay for transport, tours, hotels and experiences across Africa using one secure digital wallet, and helps tourism businesses get paid faster.";
export const CONTACT_EMAIL = "contact@kwanpay.app";
export const LEGAL_ENTITY = "KwanPay Technologies Ltd.";

export const PARTNER = {
  name: "TransVista Africa",
  legalName: "TransVista Africa Ltd",
  url: "https://www.transvistaafrica.com",
} as const;
