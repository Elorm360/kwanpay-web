import { getListings } from "@/services/listings";

export default async function Home() {
  const listings = await getListings();

  return (
    <main className="min-h-screen bg-[#050505] text-white overflow-hidden">

      {/* NAVBAR */}
      <header className="fixed top-0 left-0 w-full z-50 backdrop-blur-xl border-b border-white/10 bg-black/40">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <h1 className="text-2xl font-bold">TransVista</h1>

          <button className="px-5 py-2 rounded-full bg-white text-black font-medium hover:scale-105 transition">
            Join Waitlist
          </button>
        </div>
      </header>

      {/* HERO SECTION */}
      <section className="relative pt-40 pb-28 px-6">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[700px] h-[700px] bg-blue-500/20 blur-[180px] rounded-full" />

        <div className="relative max-w-7xl mx-auto text-center">
          <h1 className="text-5xl md:text-7xl font-bold">
            Travel Africa{" "}
            <span className="block text-[#D4AF37]">
              Without Borders
            </span>
          </h1>

          <p className="mt-8 text-lg text-white/70 max-w-2xl mx-auto">
            Book stays, tours, and transport across Africa using fast,
            borderless Stellar USDC payments.
          </p>

          <div className="mt-10 flex justify-center gap-4">
            <button className="px-8 py-4 rounded-2xl bg-[#D4AF37] text-black font-semibold">
              Explore Stays
            </button>

            <button className="px-8 py-4 rounded-2xl border border-white/15 bg-white/5">
              Become a Host
            </button>
          </div>
        </div>
      </section>

      {/* FEATURED STAYS (SUPABASE DATA) */}
      <section className="py-20 px-6">
        <div className="max-w-7xl mx-auto">

          <h2 className="text-3xl font-bold mb-8">
            Featured Stays
          </h2>

          {listings && listings.length > 0 ? (
            <div className="grid md:grid-cols-3 gap-6">
              {listings.map((item: any) => (
                <div
                  key={item.id}
                  className="p-5 border border-white/10 rounded-2xl bg-white/5 hover:bg-white/10 transition"
                >
                  <h3 className="text-xl font-semibold">
                    {item.title}
                  </h3>

                  <p className="text-white/60">
                    {item.location}
                  </p>

                  <p className="mt-3 font-bold">
                    ${item.price_per_night} / night
                  </p>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-white/50">
              No listings found. Add data in Supabase table.
            </p>
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
            A blockchain-powered booking system built on Stellar.
          </p>

          <div className="grid md:grid-cols-3 gap-8 mt-20 text-left">

            <div className="p-8 rounded-3xl border border-white/10 bg-white/5">
              <h3 className="text-xl font-semibold">Borderless Payments</h3>
              <p className="mt-3 text-white/60">
                Instant USDC transactions via Stellar.
              </p>
            </div>

            <div className="p-8 rounded-3xl border border-white/10 bg-white/5">
              <h3 className="text-xl font-semibold">Trusted Hosts</h3>
              <p className="mt-3 text-white/60">
                Verified African accommodations.
              </p>
            </div>

            <div className="p-8 rounded-3xl border border-white/10 bg-white/5">
              <h3 className="text-xl font-semibold">Instant Booking</h3>
              <p className="mt-3 text-white/60">
                Seamless booking + payment flow.
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
