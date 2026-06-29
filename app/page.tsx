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
<section className="relative overflow-hidden bg-gradient-to-b from-blue-50 via-white to-slate-50 pt-36 pb-24">

  <div className="absolute -top-20 left-1/2 -translate-x-1/2 h-[500px] w-[500px] rounded-full bg-blue-200 blur-3xl opacity-40"></div>

  <div className="relative max-w-7xl mx-auto px-6">

    <div className="text-center">

      <span className="inline-flex items-center rounded-full bg-blue-100 px-4 py-2 text-sm font-medium text-blue-700">
        Powered by Stellar Blockchain
      </span>

      <h1 className="mt-8 text-5xl md:text-7xl font-extrabold tracking-tight text-slate-900">
        Travel Africa
        <span className="block text-blue-600">
          Without Borders
        </span>
      </h1>

      <p className="mt-8 max-w-3xl mx-auto text-lg text-slate-600">
        Discover stays, tours and experiences across Africa with secure,
        borderless payments powered by Stellar.
      </p>

      <div className="mt-10 flex flex-wrap justify-center gap-4">

        <button className="rounded-xl bg-blue-600 px-8 py-4 font-semibold text-white hover:bg-blue-700 transition">
          Explore Stays
        </button>

        <button className="rounded-xl border border-slate-300 bg-white px-8 py-4 font-semibold text-slate-700 hover:bg-slate-100 transition">
          Become a Host
        </button>

      </div>

      <div className="mt-14 flex flex-wrap justify-center gap-10 text-center">

        <div>
          <p className="text-3xl">🌍</p>
          <h3 className="font-bold text-slate-900 mt-2">
            15+ Destinations
          </h3>
        </div>

        <div>
          <p className="text-3xl">⚡</p>
          <h3 className="font-bold text-slate-900 mt-2">
            Instant Settlement
          </h3>
        </div>

        <div>
          <p className="text-3xl">🔒</p>
          <h3 className="font-bold text-slate-900 mt-2">
            Secure Payments
          </h3>
        </div>

      </div>

    </div>

    {/* Search Card */}

    <div className="mt-20 max-w-5xl mx-auto rounded-3xl bg-white shadow-2xl border border-slate-200 p-8">

      <div className="grid md:grid-cols-5 gap-5">

        <div>
          <label className="text-sm text-slate-500">
            Destination
          </label>

          <select className="mt-2 w-full rounded-xl border p-3">
            <option>Accra</option>
            <option>Nairobi</option>
            <option>Cape Town</option>
            <option>Zanzibar</option>
          </select>
        </div>

        <div>
          <label className="text-sm text-slate-500">
            Check In
          </label>

          <input
            type="date"
            className="mt-2 w-full rounded-xl border p-3"
          />
        </div>

        <div>
          <label className="text-sm text-slate-500">
            Check Out
          </label>

          <input
            type="date"
            className="mt-2 w-full rounded-xl border p-3"
          />
        </div>

        <div>
          <label className="text-sm text-slate-500">
            Currency
          </label>

          <select className="mt-2 w-full rounded-xl border p-3">
            <option>USD</option>
            <option>GHS</option>
            <option>KES</option>
            <option>NGN</option>
            <option>EUR</option>
            <option>GBP</option>
          </select>
        </div>

        <div className="flex items-end">

          <button className="w-full rounded-xl bg-teal-500 py-3 font-semibold text-white hover:bg-teal-600 transition">
            Explore →
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
      
      {/* FEATURES */}
      <section className="py-28 px-6 border-t border-white/10">
        <div className="max-w-7xl mx-auto text-center">

          <h2 className="text-4xl font-bold">
            The Future of African Tourism
          </h2>

          <p className="mt-6 text-white/60 max-w-2xl mx-auto">
            Blockchain-powered travel marketplace.
          </p>

          <div className="grid md:grid-cols-3 gap-8 mt-20">

            <div className="p-8 rounded-3xl border border-white/10 bg-white/5">
              <h3 className="text-xl font-semibold">Borderless Payments</h3>
              <p className="mt-3 text-white/60">
                Fast USDC transactions via Stellar.
              </p>
            </div>

            <div className="p-8 rounded-3xl border border-white/10 bg-white/5">
              <h3 className="text-xl font-semibold">Trusted Hosts</h3>
              <p className="mt-3 text-white/60">
                Verified stays across Africa.
              </p>
            </div>

            <div className="p-8 rounded-3xl border border-white/10 bg-white/5">
              <h3 className="text-xl font-semibold">Instant Booking</h3>
              <p className="mt-3 text-white/60">
                Seamless booking experience.
              </p>
            </div>

          </div>
        </div>
      </section>

      {/* FOOTER */}
      <footer className="border-t border-white/10 py-10 px-6 text-center text-white/50">
        © {new Date().getFullYear()} TransVista. Powered by Stellar.
      </footer>

    </main>
  );
}
