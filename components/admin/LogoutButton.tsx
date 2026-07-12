"use client";

import { useRouter } from "next/navigation";

const BRAND = {
  amber: "#D98E3B",
};

export default function LogoutButton() {
  const router = useRouter();

  async function logout() {
    await fetch("/api/admin/logout", {
      method: "POST",
    });

    router.push("/admin/login");
    router.refresh();
  }

  return (
    <button
      onClick={logout}
      className="rounded-full px-5 py-2 text-white font-semibold transition-all duration-300 hover:scale-105"
      style={{
        background: BRAND.amber,
      }}
    >
      Logout
    </button>
  );
}