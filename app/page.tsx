import { getListings } from "@/services/listings";

export default async function Home() {
  const listings = await getListings();

  return (
    <main className="min-h-screen bg-[#050505] text-white overflow-hidden">

      {/* NAVBAR */}
      <header className="fixed top-0 left-0 w-full z-50 backdrop-blur-xl border-b border-white/10 bg-black/40">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <h1 className="text-2xl font-bold">TransVista</h1>

          <button className="px-5 py-2 rounded-full bg-white text-black font-medium">
            Join Waitlist
          </button>
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
            className="group rounded-3xl overflow-hidden bg-white border border-slate-200 shadow-sm hover:shadow-2xl hover:-translate-y-2 transition duration-500"
          >

            <div className="relative overflow-hidden">

              <img
                src={
                  item.image_url ||
                  "https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1200&auto=format&fit=crop"
                }
                className="h-72 w-full object-cover group-hover:scale-110 transition duration-700"
                alt={item.title}
              />

              <div className="absolute top-4 left-4 bg-white px-3 py-1 rounded-full text-sm font-semibold shadow">
                ⭐ Featured
              </div>

            </div>

            <div className="p-6">

              <h3 className="text-2xl font-bold">
                {item.title}
              </h3>

              <p className="mt-2 text-slate-500">
                📍 {item.location}
              </p>

              <div className="mt-6 flex items-center justify-between">

                <div>

                  <p className="text-sm text-slate-400">
                    Starting from
                  </p>

                  <h4 className="text-2xl font-bold text-blue-600">
                    ${item.price_per_night}
                  </h4>

                </div>

                <div className="px-4 py-2 rounded-full bg-slate-100 group-hover:bg-blue-600 group-hover:text-white transition">
                  View →
                </div>

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

      {/* WHY CHOOSE TRANSVISTA */}

<section className="py-28 px-6 bg-gradient-to-b from-white to-slate-100">

  <div className="max-w-7xl mx-auto">

    <div className="text-center">

      <p className="uppercase tracking-[0.3em] text-blue-600 font-semibold">
        WHY TRANSVISTA
      </p>

      <h2 className="text-5xl font-bold mt-4 text-slate-900">
        Travel Payments Reimagined
      </h2>

      <p className="mt-6 text-lg text-slate-500 max-w-3xl mx-auto">
        We're building Africa's next-generation travel payment platform—
        combining secure bookings with fast, transparent cross-border payments.
      </p>

    </div>

    <div className="mt-20 grid lg:grid-cols-2 gap-10">

      {/* Traditional */}

      <div className="rounded-3xl bg-red-50 border border-red-100 p-10">

        <h3 className="text-3xl font-bold text-red-600">
          Traditional Booking
        </h3>

        <div className="mt-10 space-y-6">

          <div>❌ Multiple bank charges</div>

          <div>❌ Slow international transfers</div>

          <div>❌ Currency conversion confusion</div>

          <div>❌ Delayed host settlement</div>

          <div>❌ Limited payment options</div>

        </div>

      </div>

      {/* TransVista */}

      <div className="rounded-3xl bg-blue-600 text-white p-10 shadow-2xl">

        <h3 className="text-3xl font-bold">
          With TransVista
        </h3>

        <div className="mt-10 space-y-6">

          <div>✅ Local currency display</div>

          <div>✅ Stellar-powered settlement</div>

          <div>✅ Secure USDC payments</div>

          <div>✅ Verified hosts</div>

          <div>✅ Faster cross-border travel payments</div>

        </div>

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
      <footer className="bg-slate-900 text-slate-300 py-16 px-6 border-t border-slate-800">

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
