import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

import {
  ADMIN_SESSION_COOKIE,
  verifyAdminSessionToken,
} from "@/lib/admin-session";

export async function proxy(request: NextRequest) {
  if (request.nextUrl.hostname === "transvista-landing.vercel.app") {
    const destination = request.nextUrl.clone();
    destination.hostname = "kwanpay.vercel.app";
    destination.protocol = "https:";
    destination.port = "";

    return NextResponse.redirect(destination, 308);
  }

  const isAdminPath = request.nextUrl.pathname.startsWith("/admin");
  if (!isAdminPath) return NextResponse.next();

  const isLoginPage = request.nextUrl.pathname === "/admin/login";
  const session = await verifyAdminSessionToken(
    request.cookies.get(ADMIN_SESSION_COOKIE)?.value,
    process.env.ADMIN_SESSION_SECRET
  );

  if (isLoginPage) {
    return session
      ? NextResponse.redirect(new URL("/admin", request.url))
      : NextResponse.next();
  }

  if (!session) {
    return NextResponse.redirect(new URL("/admin/login", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|icon.svg|robots.txt|sitemap.xml).*)",
  ],
};
