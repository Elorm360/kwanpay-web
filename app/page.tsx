import { getListings } from "@/services/listings";

export default async function Home() {
  const listings = await getListings();

  return (
    <main className="min-h-screen bg-[#050505] text-white overflow-hidden">

     {/* NAVBAR */}

<header className="fixed top-0 left-0 right-0 z-50">

  <div className="max-w-7xl mx-auto mt-5 px-6">

    <div className="backdrop-blur-2xl bg-white/80 border border-white/40 shadow-xl rounded-full px-7 py-4 flex items-center justify-between">

      {/* Logo */}

      <div>

        <h1 className="text-2xl font-bold text-slate-900">
          TransVista
        </h1>

      </div>

     {/* Navigation */}

<nav className="hidden md:flex items-center gap-8">

  <a
    href="#featured"
    className="text-slate-600 hover:text-blue-600 transition font-medium relative after:absolute after:left-0 after:-bottom-1 after:h-[2px] after:w-0 after:bg-blue-600 after:transition-all hover:after:w-full"
  >
    Stays
  </a>

  <a
    href="#explore"
    className="text-slate-600 hover:text-blue-600 transition font-medium relative after:absolute after:left-0 after:-bottom-1 after:h-[2px] after:w-0 after:bg-blue-600 after:transition-all hover:after:w-full"
  >
    Explore
  </a>

  <a
    href="#experience"
    className="text-slate-600 hover:text-blue-600 transition font-medium relative after:absolute after:left-0 after:-bottom-1 after:h-[2px] after:w-0 after:bg-blue-600 after:transition-all hover:after:w-full"
  >
    Experience
  </a>

  <a
    href="#contact"
    className="text-slate-600 hover:text-blue-600 transition font-medium relative after:absolute after:left-0 after:-bottom-1 after:h-[2px] after:w-0 after:bg-blue-600 after:transition-all hover:after:w-full"
  >
    Contact
  </a>

</nav>

      {/* Right Side */}

      <div className="flex items-center gap-4">

        <select
          className="rounded-full border border-slate-200 px-4 py-2 bg-white text-slate-700 outline-none hover:border-blue-500 transition"
        >
          <option>USD</option>
          <option>GHS</option>
          <option>NGN</option>
          <option>KES</option>
          <option>ZAR</option>
          <option>EUR</option>
        </select>

        <button
          className="rounded-full bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 font-semibold transition shadow-lg"
        >
          Join Waitlist
        </button>

      </div>

    </div>

  </div>

</header>

   {/* HERO */}
<section className="relative overflow-hidden bg-gradient-to-br from-blue-700 via-sky-600 to-cyan-500 text-white">

  {/* Background glow */}
  <div className="absolute -top-40 -right-32 w-[500px] h-[500px] bg-white/10 rounded-full blur-3xl" />
  <div className="absolute bottom-0 left-0 w-[400px] h-[400px] bg-cyan-300/20 rounded-full blur-3xl" />

  <div className="relative max-w-7xl mx-auto px-6 pt-40 pb-32 grid lg:grid-cols-2 gap-16 items-center">

    {/* LEFT SIDE */}
    <div>

      <div className="inline-flex items-center gap-2 rounded-full bg-white/15 backdrop-blur-md px-5 py-2 text-sm mb-8">
        🚀 Powered by Stellar Blockchain
      </div>

      <h1 className="text-6xl lg:text-7xl font-extrabold leading-tight">
        Travel Africa
        <span className="block text-cyan-200">
          Without Borders
        </span>
      </h1>

      <p className="mt-8 text-xl text-white/90 max-w-xl leading-relaxed">
        Book accommodations across Africa and pay securely using
        Stellar-powered cross-border payments.
      </p>

      <div className="mt-10 flex flex-wrap gap-5">

        <a
          href="#featured"
          className="px-8 py-4 rounded-full bg-white text-blue-700 font-semibold hover:scale-105 transition"
        >
          Explore Stays
        </a>

        <button className="px-8 py-4 rounded-full border border-white/40 hover:bg-white/10 transition">
          Become a Host
        </button>

      </div>

      <div className="mt-14 flex gap-12">

        <div>
          <h2 className="text-3xl font-bold">20+</h2>
          <p className="text-white/80 text-sm">
            Future Countries
          </p>
        </div>

        <div>
          <h2 className="text-3xl font-bold">24/7</h2>
          <p className="text-white/80 text-sm">
            Secure Payments
          </p>
        </div>

        <div>
          <h2 className="text-3xl font-bold">USDC</h2>
          <p className="text-white/80 text-sm">
            Borderless Settlement
          </p>
        </div>

      </div>

    </div>

    {/* RIGHT SIDE */}
    <div className="flex justify-center">

      <div className="bg-white rounded-[32px] shadow-2xl overflow-hidden w-[360px]">

        <img
          src="https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1200&auto=format&fit=crop"
          alt="Luxury Stay"
          className="h-64 w-full object-cover"
        />

        <div className="p-6 text-slate-900">

          <h3 className="text-2xl font-bold">
            Beach House
          </h3>

          <p className="text-slate-500 mt-2">
            📍 Cape Coast, Ghana
          </p>

          <div className="mt-6 flex justify-between items-center">

            <div>

              <p className="text-sm text-slate-500">
                Pay with
              </p>

              <h4 className="text-lg font-bold text-blue-600">
                Stellar USDC
              </h4>

            </div>

            <div className="text-right">

              <p className="text-sm text-slate-500">
                From
              </p>

              <h4 className="text-2xl font-bold">
                $80
              </h4>

            </div>

          </div>

          <button className="mt-8 w-full rounded-full bg-blue-600 text-white py-4 font-semibold hover:bg-blue-700 transition">
            Book Now
          </button>

        </div>

      </div>

    </div>

  </div>

</section>
      
     {/* FEATURED STAYS */}
<section className="py-28 px-6 bg-gradient-to-b from-[#F8FAFC] to-white text-slate-900">

  <div className="max-w-7xl mx-auto">

    <div className="flex items-center justify-between mb-12">

      <div>

        <p className="uppercase tracking-[0.25em] text-blue-600 text-sm font-semibold">
          Discover
        </p>

        <h2 className="text-5xl font-bold mt-3">
          Featured Stays
        </h2>

        <p className="text-slate-500 mt-4 max-w-xl">
          Book verified accommodations across Africa and pay securely using
          Stellar-powered cross-border payments.
        </p>

      </div>

      <button className="hidden md:block px-6 py-3 rounded-full bg-blue-600 text-white hover:bg-blue-700 transition">
        Explore All →
      </button>

    </div>

    {listings && listings.length > 0 ? (

      <div className="grid md:grid-cols-3 gap-8">

        {listings.map((item: any) => (

         <a
  key={item.id}
  href={`/listing/${item.id}`}
  className="group overflow-hidden rounded-3xl bg-white shadow-lg hover:shadow-2xl transition-all duration-500 hover:-translate-y-2"
>

  <div className="relative overflow-hidden">

    <img
      src={
        item.image_url ||
        "https://images.unsplash.com/photo-1576485290814-1c72aa4bbb8b?q=80&w=1200&auto=format&fit=crop"
      }
      alt={item.title}
      className="h-64 w-full object-cover transition duration-700 group-hover:scale-110"
    />

    <div className="absolute top-5 left-5">

      <span className="rounded-full bg-white/90 px-4 py-2 text-sm font-semibold text-slate-800 shadow">

        Featured

      </span>

    </div>

    <div className="absolute top-5 right-5">

      <span className="rounded-full bg-blue-600 px-3 py-2 text-white text-sm">

        ★ 4.9

      </span>

    </div>

  </div>

  <div className="p-6">

    <h3 className="text-2xl font-bold text-slate-900">
      {item.title}
    </h3>

    <p className="mt-2 text-slate-500">
      📍 {item.location}
    </p>

    <div className="mt-6 flex items-center justify-between">

      <div>

        <p className="text-3xl font-bold text-blue-600">
          ${item.price_per_night}
        </p>

        <p className="text-slate-500">
          per night
        </p>

      </div>

      <span className="rounded-full bg-blue-600 px-5 py-3 text-white font-semibold transition group-hover:bg-blue-700">

        View Stay →

      </span>

    </div>

  </div>

</a>

        ))}

      </div>

    ) : (

      <div className="rounded-3xl border border-dashed border-slate-300 p-20 text-center">

        <h3 className="text-2xl font-bold">
          No Listings Yet
        </h3>

        <p className="mt-4 text-slate-500">
          Your properties from Supabase will appear here.
        </p>

      </div>

    )}

  </div>

</section>
      
      {/* HOW IT WORKS */}
<section className="py-28 px-6 bg-white text-slate-900">

  <div className="max-w-7xl mx-auto">

    <div className="text-center max-w-3xl mx-auto">

      <p className="uppercase tracking-[0.3em] text-blue-600 font-semibold">
        HOW IT WORKS
      </p>

      <h2 className="text-5xl font-bold mt-4">
        Cross-Border Payments Made Simple
      </h2>

      <p className="mt-6 text-slate-500 text-lg">
        TransVista enables travelers to book verified accommodations across Africa
        while paying securely using Stellar-powered blockchain payments.
      </p>

    </div>

    <div className="grid lg:grid-cols-4 gap-8 mt-20">

      {/* STEP 1 */}

      <div className="relative">

        <div className="w-16 h-16 rounded-full bg-blue-600 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
          1
        </div>

        <h3 className="mt-8 text-2xl font-bold">
          Choose a Stay
        </h3>

        <p className="mt-4 text-slate-500 leading-7">
          Browse verified accommodations from trusted hosts across Africa.
        </p>

      </div>

      {/* STEP 2 */}

      <div>

        <div className="w-16 h-16 rounded-full bg-cyan-500 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
          2
        </div>

        <h3 className="mt-8 text-2xl font-bold">
          Pay in Your Currency
        </h3>

        <p className="mt-4 text-slate-500 leading-7">
          Travelers can see prices in their preferred currency before making payment.
        </p>

      </div>

      {/* STEP 3 */}

      <div>

        <div className="w-16 h-16 rounded-full bg-indigo-600 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
          3
        </div>

        <h3 className="mt-8 text-2xl font-bold">
          Stellar Handles Settlement
        </h3>

        <p className="mt-4 text-slate-500 leading-7">
          Payments are securely settled using Stellar and USDC, making cross-border transactions fast and transparent.
        </p>

      </div>

      {/* STEP 4 */}

      <div>

        <div className="w-16 h-16 rounded-full bg-emerald-500 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
          4
        </div>

        <h3 className="mt-8 text-2xl font-bold">
          Host Gets Paid
        </h3>

        <p className="mt-4 text-slate-500 leading-7">
          Hosts receive secure settlement while travelers enjoy a seamless booking experience.
        </p>

      </div>

    </div>

    {/* TRUST SECTION */}

    <div className="mt-24 grid md:grid-cols-4 gap-6">

      <div className="rounded-3xl bg-slate-50 p-8 border border-slate-200">

        <h3 className="font-bold text-xl">
          🌍 Borderless
        </h3>

        <p className="mt-3 text-slate-500">
          Travel across Africa without worrying about payment barriers.
        </p>

      </div>

      <div className="rounded-3xl bg-slate-50 p-8 border border-slate-200">

        <h3 className="font-bold text-xl">
          ⚡ Instant
        </h3>

        <p className="mt-3 text-slate-500">
          Fast settlement powered by Stellar blockchain technology.
        </p>

      </div>

      <div className="rounded-3xl bg-slate-50 p-8 border border-slate-200">

        <h3 className="font-bold text-xl">
          🔒 Secure
        </h3>

        <p className="mt-3 text-slate-500">
          Transparent transactions with trusted infrastructure.
        </p>

      </div>

      <div className="rounded-3xl bg-slate-50 p-8 border border-slate-200">

        <h3 className="font-bold text-xl">
          ✅ Verified
        </h3>

        <p className="mt-3 text-slate-500">
          Carefully curated hosts and accommodations.
        </p>

      </div>

    </div>

  </div>

</section>

      {/* EXPLORE AFRICA */}

<section className="py-28 px-6 bg-slate-50">

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
