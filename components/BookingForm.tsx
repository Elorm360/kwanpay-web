"use client";

import { useState } from "react";

export default function BookingForm({
  listingId,
}: {
  listingId: number;
}) {
  const [loading, setLoading] = useState(false);

  async function handleSubmit(
    e: React.FormEvent<HTMLFormElement>
  ) {
    e.preventDefault();

    setLoading(true);

    const formData = new FormData(e.currentTarget);

    const response = await fetch("/api/bookings", {
      method: "POST",
      body: JSON.stringify({
        listing_id: listingId,
        full_name: formData.get("full_name"),
        email: formData.get("email"),
        phone: formData.get("phone"),
        check_in: formData.get("check_in"),
        check_out: formData.get("check_out"),
        guests: Number(formData.get("guests")),
      }),
    });

    setLoading(false);

    const result = await response.json();

if (response.ok) {
  alert("Booking submitted successfully!");
} else {
  alert(`Booking failed: ${result.error}`);
}
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="space-y-4 mt-10"
    >
      <input
        name="full_name"
        placeholder="Full Name"
        required
        className="w-full p-3 rounded-xl bg-black border border-white/10"
      />

      <input
        name="email"
        type="email"
        placeholder="Email"
        required
        className="w-full p-3 rounded-xl bg-black border border-white/10"
      />

      <input
        name="phone"
        placeholder="Phone"
        required
        className="w-full p-3 rounded-xl bg-black border border-white/10"
      />

      <input
        name="check_in"
        type="date"
        required
        className="w-full p-3 rounded-xl bg-black border border-white/10"
      />

      <input
        name="check_out"
        type="date"
        required
        className="w-full p-3 rounded-xl bg-black border border-white/10"
      />

      <input
        name="guests"
        type="number"
        min="1"
        defaultValue="1"
        required
        className="w-full p-3 rounded-xl bg-black border border-white/10"
      />

      <button
        type="submit"
        disabled={loading}
        className="w-full py-4 bg-[#D4AF37] text-black font-semibold rounded-2xl"
      >
        {loading ? "Submitting..." : "Reserve Booking"}
      </button>
    </form>
  );
}
