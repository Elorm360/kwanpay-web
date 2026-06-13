"use client";

import { useState } from "react";

export default function BookingPage({
  params,
}: {
  params: { id: string };
}) {
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [checkIn, setCheckIn] = useState("");
  const [checkOut, setCheckOut] = useState("");
  const [guests, setGuests] = useState(1);

  async function handleSubmit(e: any) {
    e.preventDefault();

    const response = await fetch("/api/bookings", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        listing_id: params.id,
        full_name: fullName,
        email,
        phone,
        check_in: checkIn,
        check_out: checkOut,
        guests,
      }),
    });

    const result = await response.json();

    if (result.success) {
      alert("Booking submitted successfully!");
    } else {
      alert("Booking failed");
    }
  }

  return (
    <main className="min-h-screen bg-[#050505] text-white p-10">
      <div className="max-w-xl mx-auto">

        <h1 className="text-4xl font-bold mb-8">
          Complete Your Booking
        </h1>

        <form
          onSubmit={handleSubmit}
          className="space-y-4"
        >
          <input
            type="text"
            placeholder="Full Name"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            className="w-full p-4 bg-black border border-white/10 rounded-xl"
          />

          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full p-4 bg-black border border-white/10 rounded-xl"
          />

          <input
            type="text"
            placeholder="Phone"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            className="w-full p-4 bg-black border border-white/10 rounded-xl"
          />

          <input
            type="date"
            value={checkIn}
            onChange={(e) => setCheckIn(e.target.value)}
            className="w-full p-4 bg-black border border-white/10 rounded-xl"
          />

          <input
            type="date"
            value={checkOut}
            onChange={(e) => setCheckOut(e.target.value)}
            className="w-full p-4 bg-black border border-white/10 rounded-xl"
          />

          <input
            type="number"
            value={guests}
            onChange={(e) => setGuests(Number(e.target.value))}
            className="w-full p-4 bg-black border border-white/10 rounded-xl"
          />

          <button
            type="submit"
            className="w-full p-4 bg-[#D4AF37] text-black rounded-xl font-bold"
          >
            Confirm Booking
          </button>
        </form>

      </div>
    </main>
  );
}
