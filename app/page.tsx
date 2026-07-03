import { getListings } from "@/services/listings";

const BRAND = {
  indigo: "#1E2340",
  charcoal: "#24262B",
  amber: "#D98E3B",
  paper: "#EDEFF0",
};

export default async function Home() {
  const listings = await getListings();

  return (
<main
  className="min-h-screen overflow-hidden text-slate-900"
  style={{
    background: BRAND.paper,
  }}
>  
     {/* NAVBAR */}

<header className="fixed top-0 left-0 right-0 z-50">

  <div className="max-w-7xl mx-auto mt-5 px-6">

    <div className="backdrop-blur-2xl bg-white/80 border border-white/40 shadow-xl rounded-full px-7 py-4 flex items-center justify-between">

      {/* Logo */}

<div className="flex items-center gap-4">

  <div
    className="h-11 w-11 rounded-2xl flex items-center justify-center shadow-lg"
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

    <h1
      className="text-2xl font-extrabold tracking-tight"
      style={{ color: BRAND.indigo }}
    >
      Kwan<span style={{ color: BRAND.amber }}>Pay</span>
    </h1>

    <p className="text-xs text-slate-500">
      The path your payment takes.
    </p>

  </div>

</div>

    {/* Navigation */}

<nav className="hidden lg:flex items-center gap-10 text-slate-600 font-medium">

  <a
    href="#hero"
    className="hover:text-blue-600 transition"
  >
    Discover
  </a>

  <a
    href="#featured"
    className="hover:text-blue-600 transition"
  >
    Stays
  </a>

  <a
    href="#explore"
    className="hover:text-blue-600 transition"
  >
    Explore Africa
  </a>

  <a
    href="#how-it-works"
    className="hover:text-blue-600 transition"
  >
    How It Works
  </a>

</nav>

    <div className="flex items-center gap-4">

  <select
    className="rounded-full border border-slate-200 bg-white px-4 py-2 text-sm text-slate-700 shadow-sm hover:border-blue-500 transition"
  >
    <option>USD 🇺🇸</option>
    <option>GHS 🇬🇭</option>
    <option>KES 🇰🇪</option>
    <option>NGN 🇳🇬</option>
    <option>ZAR 🇿🇦</option>
    <option>EUR 🇪🇺</option>
    <option>GBP 🇬🇧</option>
  </select>

  <button
  className="rounded-full px-6 py-3 font-semibold shadow-lg transition-all duration-300 hover:scale-105"
  style={{
    background: BRAND.amber,
    color: "white",
  }}
>
  Request Early Access
</button>

</div>

    </div>

  </div>

</header>

  {/* HERO */}
<section className="relative pt-44 pb-32 px-6 overflow-hidden">

 {/* Background Effects */}

<div
  className="absolute -top-40 left-1/2 -translate-x-1/2 w-[900px] h-[900px] rounded-full blur-[220px] opacity-20"
  style={{ background: BRAND.indigo }}
></div>

<div
  className="absolute top-40 -left-32 w-[350px] h-[350px] rounded-full blur-[140px] opacity-20"
  style={{ background: BRAND.amber }}
></div>

<div
  className="absolute bottom-0 right-0 w-[400px] h-[400px] rounded-full blur-[170px] opacity-10"
  style={{ background: BRAND.indigo }}
></div>

  <div className="relative max-w-5xl mx-auto text-center">

    {/* small label */}
    <p
      className="uppercase tracking-[0.3em] font-semibold text-sm"
      style={{ color: BRAND.amber }}
    >
      Cross-Border Payment Infrastructure
    </p>

    {/* headline */}
    <h1
      className="text-6xl md:text-8xl font-black tracking-tight leading-[1.05] mt-6"
      style={{ color: BRAND.indigo }}
    >
      Powering payments for African tourism — without the friction.
    </h1>

    {/* subtext */}
    <p
    className="mt-8 text-xl leading-9 text-slate-600 max-w-3xl mx-auto"
      >
      KwanPay lets travelers pay any tourism business in Africa from anywhere in the world.
      Fast settlement. Low cost. Built on Stellar.
    </p>

    {/* CTA buttons */}
    <div className="mt-10 flex items-center justify-center gap-4 flex-wrap">

      <button
        className="rounded-full px-6 py-3 font-semibold shadow-lg transition-all duration-300 hover:scale-105"
        style={{
          background: BRAND.amber,
          color: "white",
        }}
      >
        Request Early Access →
      </button>

      <a
        href="#how-it-works"
        className="text-sm font-medium hover:underline"
        style={{ color: BRAND.indigo }}
      >
        See how it works ↓
      </a>

    </div>

{/* PAYMENT FLOW */}

<div className="mt-24 max-w-5xl mx-auto">

  <div className="flex flex-col md:flex-row items-center justify-center gap-6">

    {/* Step 1 */}

    <div className="rounded-3xl bg-white p-8 shadow-xl border border-slate-200 hover:-translate-y-2 transition-all duration-300">

      <div
        className="w-12 h-12 rounded-2xl flex items-center justify-center text-white font-bold"
        style={{ background: BRAND.amber }}
      >
        1
      </div>

      <h3
        className="text-2xl font-bold mt-6"
        style={{ color: BRAND.indigo }}
      >
        Traveler Pays
      </h3>

      <p className="mt-4 text-slate-600 leading-7">
        The traveler pays from anywhere in the world using their preferred
        payment method and currency.
      </p>

    </div>

    {/* Arrow */}

    <div className="hidden md:flex justify-center text-5xl text-slate-300">
      →
    </div>

    {/* Step 2 */}

    <div className="rounded-3xl bg-white p-8 shadow-xl border border-slate-200 hover:-translate-y-2 transition-all duration-300">

      <div
        className="w-12 h-12 rounded-2xl flex items-center justify-center text-white font-bold"
        style={{ background: BRAND.amber }}
      >
        2
      </div>

      <h3
        className="text-2xl font-bold mt-6"
        style={{ color: BRAND.indigo }}
      >
        KwanPay + Stellar
      </h3>

      <p className="mt-4 text-slate-600 leading-7">
        KwanPay securely routes and settles the payment over the Stellar
        network with speed and transparency.
      </p>

    </div>

    {/* Arrow */}

    <div className="hidden md:flex justify-center text-5xl text-slate-300">
      →
    </div>

    {/* Step 3 */}

    <div className="rounded-3xl bg-white p-8 shadow-xl border border-slate-200 hover:-translate-y-2 transition-all duration-300">

      <div
        className="w-12 h-12 rounded-2xl flex items-center justify-center text-white font-bold"
        style={{ background: BRAND.amber }}
      >
        3
      </div>

      <h3
        className="text-2xl font-bold mt-6"
        style={{ color: BRAND.indigo }}
      >
        Operator Receives Funds
      </h3>

      <p className="mt-4 text-slate-600 leading-7">
        The tourism business receives settlement quickly, improving cash flow
        and reducing cross-border payment friction.
      </p>

    </div>

  </div>


</section>
      
    {/* PROBLEM SECTION */}
<section className="py-28 px-6 bg-white">

  <div className="max-w-6xl mx-auto">

    {/* label */}
    <p
      className="uppercase tracking-[0.3em] text-sm font-semibold text-center"
      style={{ color: BRAND.amber }}
    >
      The Problem
    </p>

    {/* title */}
    <h2
      className="text-4xl md:text-5xl font-bold text-center mt-4"
      style={{ color: BRAND.indigo }}
    >
      Cross-border travel payments are still broken
    </h2>

    <p className="text-center mt-6 text-slate-600 max-w-2xl mx-auto">
      Despite global travel growth, sending money to African tourism businesses is still slow, expensive, and unreliable.
    </p>

    {/* cards */}
    <div className="grid md:grid-cols-3 gap-8 mt-16">

      <div className="p-8 rounded-2xl border border-slate-200 bg-[#F7F7F7] hover:shadow-lg transition">
        <h3 className="font-semibold text-lg" style={{ color: BRAND.indigo }}>
          High Fees
        </h3>
        <p className="mt-3 text-slate-600">
          International payments often lose 5–10% in banking and conversion fees.
        </p>
      </div>

      <div className="p-8 rounded-2xl border border-slate-200 bg-[#F7F7F7] hover:shadow-lg transition">
        <h3 className="font-semibold text-lg" style={{ color: BRAND.indigo }}>
          Slow Settlement
        </h3>
        <p className="mt-3 text-slate-600">
          Transfers take 3–5 days, delaying bookings and cash flow for operators.
        </p>
      </div>

      <div className="p-8 rounded-2xl border border-slate-200 bg-[#F7F7F7] hover:shadow-lg transition">
        <h3 className="font-semibold text-lg" style={{ color: BRAND.indigo }}>
          Limited Access
        </h3>
        <p className="mt-3 text-slate-600">
          Many African operators cannot reliably accept global cards or payments.
        </p>
      </div>

    </div>

  </div>

</section>
      
    {/* HOW IT WORKS */}

<section
  id="how-it-works"
  className="py-32 px-6"
  style={{ background: BRAND.indigo }}
>

  <div className="max-w-6xl mx-auto">

    <div className="text-center">

      <p
        className="uppercase tracking-[0.3em] text-sm font-semibold"
        style={{ color: BRAND.amber }}
      >
        HOW IT WORKS
      </p>

      <h2 className="text-5xl font-bold mt-5 text-white">
        One payment.
        <br />
        One path.
      </h2>

      <p className="mt-6 text-slate-300 max-w-3xl mx-auto text-lg">
        KwanPay connects travelers and African tourism businesses through a
        faster, more transparent payment infrastructure powered by Stellar.
      </p>

    </div>

    <div className="mt-24 grid lg:grid-cols-3 gap-8">

      {/* Step 1 */}

      <div className="rounded-3xl bg-white/5 border border-white/10 p-10 backdrop-blur-lg hover:-translate-y-2 transition duration-500">

        <div
          className="h-14 w-14 rounded-2xl flex items-center justify-center text-xl font-bold"
          style={{
            background: BRAND.amber,
            color: "white",
          }}
        >
          1
        </div>

        <h3 className="text-2xl font-bold text-white mt-8">
          Traveler Pays
        </h3>

        <p className="mt-4 text-slate-300">
          A traveler pays from anywhere in the world using their preferred
          currency.
        </p>

      </div>

      {/* Step 2 */}

      <div className="rounded-3xl bg-white/5 border border-white/10 p-10 backdrop-blur-lg hover:-translate-y-2 transition duration-500">

        <div
          className="h-14 w-14 rounded-2xl flex items-center justify-center text-xl font-bold"
          style={{
            background: BRAND.amber,
            color: "white",
          }}
        >
          2
        </div>

        <h3 className="text-2xl font-bold text-white mt-8">
          Stellar Settlement
        </h3>

        <p className="mt-4 text-slate-300">
          KwanPay routes and settles the payment securely over the Stellar
          network within minutes.
        </p>

      </div>

      {/* Step 3 */}

      <div className="rounded-3xl bg-white/5 border border-white/10 p-10 backdrop-blur-lg hover:-translate-y-2 transition duration-500">

        <div
          className="h-14 w-14 rounded-2xl flex items-center justify-center text-xl font-bold"
          style={{
            background: BRAND.amber,
            color: "white",
          }}
        >
          3
        </div>

        <h3 className="text-2xl font-bold text-white mt-8">
          Operator Receives Funds
        </h3>

        <p className="mt-4 text-slate-300">
          Tourism businesses receive settlement quickly, reducing delays,
          uncertainty and unnecessary costs.
        </p>

      </div>

    </div>

  </div>

</section>

      {/* EXPLORE AFRICA */}

<section
  id="explore"
  className="py-28 px-6 bg-slate-50"
>
  <div className="max-w-7xl mx-auto">

    <div className="text-center">

      <p className="uppercase tracking-[0.3em] text-blue-600 font-semibold">
        EXPLORE AFRICA
      </p>

      <h2 className="text-5xl font-bold mt-4 text-slate-900">
        Your Next African Adventure Starts Here
      </h2>

      <p className="mt-6 max-w-3xl mx-auto text-slate-500 text-lg">
        From tropical beaches and historic castles to wildlife safaris and vibrant cities,
        discover unforgettable destinations across Africa.
      </p>

    </div>

    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mt-20">

      {/* Ghana */}

      <div className="group overflow-hidden rounded-3xl bg-white shadow hover:shadow-2xl transition duration-500">

        <img
          src="https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?q=80&w=1200&auto=format&fit=crop"
          className="h-72 w-full object-cover group-hover:scale-110 transition duration-700"
          alt="Cape Coast"
        />

        <div className="p-8">

          <h3 className="text-2xl font-bold text-slate-900">
            🇬🇭 Cape Coast
          </h3>

          <p className="mt-3 text-slate-500">
            Historic castles, golden beaches and rich Ghanaian culture.
          </p>

        </div>

      </div>

      {/* Zanzibar */}

      <div className="group overflow-hidden rounded-3xl bg-white shadow hover:shadow-2xl transition duration-500">

        <img
          src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1200&auto=format&fit=crop"
          className="h-72 w-full object-cover group-hover:scale-110 transition duration-700"
          alt="Zanzibar"
        />

        <div className="p-8">

          <h3 className="text-2xl font-bold text-slate-900">
            🇹🇿 Zanzibar
          </h3>

          <p className="mt-3 text-slate-500">
            Crystal-clear waters, white sand beaches and island luxury.
          </p>

        </div>

      </div>

      {/* Cape Town */}

      <div className="group overflow-hidden rounded-3xl bg-white shadow hover:shadow-2xl transition duration-500">

        <img
          src="https://images.unsplash.com/photo-1576485290814-1c72aa4bbb8b?q=80&w=1200&auto=format&fit=crop"
          className="h-72 w-full object-cover group-hover:scale-110 transition duration-700"
          alt="Cape Town"
        />

        <div className="p-8">

          <h3 className="text-2xl font-bold text-slate-900">
            🇿🇦 Cape Town
          </h3>

          <p className="mt-3 text-slate-500">
            Mountains, oceans and one of Africa's most iconic skylines.
          </p>

        </div>

      </div>

      {/* Marrakech */}

      <div className="group overflow-hidden rounded-3xl bg-white shadow hover:shadow-2xl transition duration-500">

        <img
          src="https://images.unsplash.com/photo-1597212618440-806262de4f6b?q=80&w=1200&auto=format&fit=crop"
          className="h-72 w-full object-cover group-hover:scale-110 transition duration-700"
          alt="Marrakech"
        />

        <div className="p-8">

          <h3 className="text-2xl font-bold text-slate-900">
            🇲🇦 Marrakech
          </h3>

          <p className="mt-3 text-slate-500">
            Colorful markets, luxury riads and centuries of history.
          </p>

        </div>

      </div>

      {/* Nairobi */}

      <div className="group overflow-hidden rounded-3xl bg-white shadow hover:shadow-2xl transition duration-500">

        <img
          src="https://images.unsplash.com/photo-1521295121783-8a321d551ad2?q=80&w=1200&auto=format&fit=crop"
          className="h-72 w-full object-cover group-hover:scale-110 transition duration-700"
          alt="Nairobi"
        />

        <div className="p-8">

          <h3 className="text-2xl font-bold text-slate-900">
            🇰🇪 Nairobi
          </h3>

          <p className="mt-3 text-slate-500">
            Wildlife, innovation and vibrant city life all in one destination.
          </p>

        </div>

      </div>

      {/* Kigali */}

      <div className="group overflow-hidden rounded-3xl bg-white shadow hover:shadow-2xl transition duration-500">

        <img
          src="https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=1200&auto=format&fit=crop"
          className="h-72 w-full object-cover group-hover:scale-110 transition duration-700"
          alt="Kigali"
        />

        <div className="p-8">

          <h3 className="text-2xl font-bold text-slate-900">
            🇷🇼 Kigali
          </h3>

          <p className="mt-3 text-slate-500">
            One of Africa's cleanest, safest and fastest-growing cities.
          </p>

        </div>

      </div>

    </div>

  </div>

</section>

      {/* THE TRANSVISTA EXPERIENCE */}

<section className="py-32 px-6 bg-white">

  <div className="max-w-7xl mx-auto">

    <div className="text-center">

      <p className="uppercase tracking-[0.35em] text-blue-600 font-semibold">
        THE TRANSVISTA EXPERIENCE
      </p>

      <h2 className="text-5xl md:text-6xl font-bold mt-5 text-slate-900">
        Travel Across Africa
        <br />
        Without Payment Barriers
      </h2>

      <p className="mt-8 max-w-3xl mx-auto text-slate-500 text-xl leading-relaxed">
        From choosing your destination to paying securely and arriving with confidence,
        TransVista creates one seamless travel experience powered by Stellar.
      </p>

    </div>

    <div className="mt-24 grid lg:grid-cols-5 gap-8">

      {/* Step 1 */}

      <div className="group text-center">

        <div className="w-24 h-24 mx-auto rounded-full bg-blue-100 flex items-center justify-center text-5xl transition duration-500 group-hover:scale-110">
          🌍
        </div>

        <h3 className="mt-8 text-2xl font-bold text-slate-900">
          Explore
        </h3>

        <p className="mt-4 text-slate-500">
          Discover stays, tours and experiences across Africa.
        </p>

      </div>

      {/* Step 2 */}

      <div className="group text-center">

        <div className="w-24 h-24 mx-auto rounded-full bg-cyan-100 flex items-center justify-center text-5xl transition duration-500 group-hover:scale-110">
          🏡
        </div>

        <h3 className="mt-8 text-2xl font-bold text-slate-900">
          Reserve
        </h3>

        <p className="mt-4 text-slate-500">
          Choose verified accommodation with instant booking.
        </p>

      </div>

      {/* Step 3 */}

      <div className="group text-center">

        <div className="w-24 h-24 mx-auto rounded-full bg-green-100 flex items-center justify-center text-5xl transition duration-500 group-hover:scale-110">
          💱
        </div>

        <h3 className="mt-8 text-2xl font-bold text-slate-900">
          Pay
        </h3>

        <p className="mt-4 text-slate-500">
          View prices in your preferred currency while Stellar handles secure settlement.
        </p>

      </div>

      {/* Step 4 */}

      <div className="group text-center">

        <div className="w-24 h-24 mx-auto rounded-full bg-yellow-100 flex items-center justify-center text-5xl transition duration-500 group-hover:scale-110">
          ⚡
        </div>

        <h3 className="mt-8 text-2xl font-bold text-slate-900">
          Confirm
        </h3>

        <p className="mt-4 text-slate-500">
          Receive fast confirmation with transparent payment tracking.
        </p>

      </div>

      {/* Step 5 */}

      <div className="group text-center">

        <div className="w-24 h-24 mx-auto rounded-full bg-purple-100 flex items-center justify-center text-5xl transition duration-500 group-hover:scale-110">
          ✈️
        </div>

        <h3 className="mt-8 text-2xl font-bold text-slate-900">
          Travel
        </h3>

        <p className="mt-4 text-slate-500">
          Enjoy your African adventure with confidence.
        </p>

      </div>

    </div>

  </div>

</section>
      {/* FINAL CTA */}

<section className="py-32 px-6 bg-gradient-to-r from-blue-700 via-sky-600 to-cyan-500 text-white">

  <div className="max-w-5xl mx-auto text-center">

    <h2 className="text-6xl font-bold">
      Ready to Travel Africa?
    </h2>

    <p className="mt-8 text-xl text-white/90">
      Experience secure cross-border travel payments powered by Stellar.
    </p>

    <div className="mt-12 flex justify-center gap-6 flex-wrap">

      <a
        href="#featured"
        className="px-8 py-4 rounded-full bg-white text-blue-700 font-semibold hover:scale-105 transition"
      >
        Explore Stays
      </a>

      <button className="px-8 py-4 rounded-full border border-white hover:bg-white/10 transition">
        Become a Host
      </button>

    </div>

  </div>

</section>

      {/* FOOTER */}
<footer
  id="contact"
  className="bg-slate-900 text-slate-300 py-16 px-6 border-t border-slate-800"
>
  <div className="max-w-7xl mx-auto grid md:grid-cols-3 gap-10">

    <div>
      <h2 className="text-3xl font-bold text-white">
        TransVista
      </h2>

      <p className="mt-4 text-slate-400">
        Travel Africa Without Borders.
      </p>

      <p className="mt-2 text-slate-500">
        Cross-border travel payments powered by Stellar.
      </p>
    </div>

    <div>
      <h3 className="text-white font-semibold mb-4">
        Platform
      </h3>

      <ul className="space-y-2 text-slate-400">
        <li>Explore Stays</li>
        <li>Become a Host</li>
        <li>Payments</li>
      </ul>
    </div>

    <div className="md:text-right">
      <h3 className="text-white font-semibold mb-4">
        Technology
      </h3>

      <p>Powered by Stellar</p>

      <p className="mt-6 text-slate-500">
        © {new Date().getFullYear()} TransVista Africa Ltd.
      </p>
    </div>

  </div>

</footer>
    </main>
  );
}
