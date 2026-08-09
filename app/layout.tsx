import type { Metadata, Viewport } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import Providers from "@/components/Providers";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

const SITE_URL = "https://kwanpay.app";
const SITE_TITLE = "KwanPay — Africa's Travel Wallet";
const SITE_DESCRIPTION =
  "One wallet. Every journey. Across Africa. KwanPay helps travelers pay for transport, tours, hotels and experiences across Africa using one secure digital wallet, and helps tourism businesses get paid faster.";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: SITE_TITLE,
    template: "%s — KwanPay",
  },
  description: SITE_DESCRIPTION,
  keywords: [
    "KwanPay",
    "Africa travel payments",
    "travel wallet",
    "digital wallet Africa",
    "tourism payments",
    "Stellar payments",
    "cross-border payments Africa",
  ],
  applicationName: "KwanPay",
  authors: [{ name: "KwanPay Technologies Ltd." }],
  openGraph: {
    type: "website",
    url: SITE_URL,
    siteName: "KwanPay",
    title: SITE_TITLE,
    description: SITE_DESCRIPTION,
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: SITE_TITLE,
    description: SITE_DESCRIPTION,
  },
  icons: {
    icon: "/icon.svg",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export const viewport: Viewport = {
  themeColor: "#1E2340",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
