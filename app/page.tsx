import { getListings } from "@/services/listings";
export default async function Home() {
  const listings = await getListings();
  return (
    <main className="min-h-screen bg-[#050505] text-white overflow-hidden">

      {/* NAVBAR */}
      <header className="fixed top-0 left-0 w-full z-50 backdrop-blur-xl border-b border-white/10 bg-black/40">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <h1 className="text-2xl font-bold tracking-tight">
            TransVista
          </h1>

          <nav className="hidden md:flex gap-8 text-sm text-white/70">
            <a href="#features" className="hover:text-white transition">
              Features
            </a>
            <a href="#how" className="hover:text-white transition">
              How It Works
            </a>
            <a href="#stellar" className="hover:text-white transition">
              Stellar
            </a>
            <a href="#hosts" className="hover:text-white transition">
              Hosts
            </a>
          </nav>

          <button className="px-5 py-2 rounded-full bg-white text-black font-medium hover:scale-105 transition">
            Join Waitlist
          </button>
        </div>
      </header>

      {/* HERO SECTION */}
      <section className="relative pt-40 pb-28 px-6">
        <section className="py-20 px-6">
  <h2 className="text-3xl font-bold mb-8">
    Featured Stays
  </h2>

  <div className="grid md:grid-cols-3 gap-6">
    {listings?.map((item: any) => (
      <div
        key={item.id}
        className="p-5 border border-white/10 rounded-2xl bg-white/5"
      >
        <h3 className="text-xl font-semibold">
          {item.title}
        </h3>

        <p className="text-white/60">
          {item.location}
        </p>

        <p className="mt-2 font-bold">
          ${item.price_per_night} / night
        </p>
      </div>
    ))}
  </div>
</section>

        {/* Background Glow */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[700px] h-[700px] bg-blue-500/20 blur-[180px] rounded-full" />

        <div className="relative max-w-7xl mx-auto grid md:grid-cols-2 gap-16 items-center">

          {/* LEFT CONTENT */}
          <div>
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-white/10 bg-white/5 text-sm text-white/70 mb-6">
              Powered by Stellar Blockchain Infrastructure
            </div>

            <h1 className="text-5xl md:text-7xl font-bold leading-tight tracking-tight">
              Travel Africa
              <span className="block text-[#D4AF37]">
                Without Borders
              </span>
            </h1>

            <p className="mt-8 text-lg text-white/70 leading-relaxed max-w-xl">
              Book stays, tours, and transport across Africa using fast,
              borderless Stellar USDC payments.
            </p>

            <div className="mt-10 flex flex-wrap gap-4">
              <button className="px-8 py-4 rounded-2xl bg-[#D4AF37] text-black font-semibold hover:scale-105 transition">
                Explore Stays
              </button>

              <button className="px-8 py-4 rounded-2xl border border-white/15 bg-white/5 hover:bg-white/10 transition">
                Become a Host
              </button>
            </div>

            {/* Stats */}
            <div className="mt-14 flex gap-10">
              <div>
                <h3 className="text-3xl font-bold">Fast</h3>
                <p className="text-white/50 text-sm mt-1">
                  Stellar Transactions
                </p>
              </div>

              <div>
                <h3 className="text-3xl font-bold">Low Fees</h3>
                <p className="text-white/50 text-sm mt-1">
                  Borderless Payments
                </p>
              </div>

              <div>
                <h3 className="text-3xl font-bold">Africa</h3>
                <p className="text-white/50 text-sm mt-1">
                  Tourism Network
                </p>
              </div>
            </div>
          </div>

          {/* RIGHT VISUAL */}
          <div className="relative">

            {/* Mock Phone UI */}
            <div className="relative mx-auto w-[320px] rounded-[40px] border border-white/10 bg-white/5 backdrop-blur-2xl p-5 shadow-2xl">

              <div className="rounded-[28px] overflow-hidden bg-[#111111]">

                <img
                  src="https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1200&auto=format&fit=crop"
                  alt="Luxury Apartment"
                  className="h-56 w-full object-cover"
                />

                <div className="p-5">
                  <div className="flex items-center justify-between">
                    <div>
                      <h3 className="font-semibold text-lg">
                        Luxury Apartment
                      </h3>
                      <p className="text-sm text-white/50">
                        Accra, Ghana
                      </p>
                    </div>

                    <div className="text-right">
                      <h3 className="font-bold">$80</h3>
                      <p className="text-xs text-white/50">
                        per night
                      </p>
                    </div>
                  </div>

                  <div className="mt-5 p-4 rounded-2xl bg-black border border-white/10">
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="text-sm text-white/50">
                          Payment
                        </p>
                        <h4 className="font-semibold">
                          Stellar USDC
                        </h4>
                      </div>

                      <div className="h-10 w-10 rounded-full bg-[#D4AF37] flex items-center justify-center text-black font-bold">
                        $
                      </div>
                    </div>

                    <button className="mt-4 w-full py-3 rounded-xl bg-[#D4AF37] text-black font-semibold">
                      Pay Now
                    </button>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* TRUST BAR */}
      <section className="border-y border-white/10 bg-white/[0.03]">
        <div className="max-w-7xl mx-auto px-6 py-6 flex flex-wrap gap-8 justify-center text-sm text-white/50">
          <span>Powered by Stellar</span>
          <span>USDC Payments</span>
          <span>Borderless Transactions</span>
          <span>Fast Settlement</span>
          <span>Escrow Security</span>
        </div>
      </section>

      {/* FEATURES */}
      <section id="features" className="py-28 px-6">
        <div className="max-w-7xl mx-auto">

          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-4xl md:text-5xl font-bold">
              The Future of African Tourism
            </h2>

            <p className="mt-6 text-white/60">
              TransVista combines tourism infrastructure with blockchain-powered
              payments to simplify travel across Africa.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8 mt-20">

            <div className="p-8 rounded-3xl border border-white/10 bg-white/[0.03] hover:bg-white/[0.05] transition">
              <div className="h-14 w-14 rounded-2xl bg-[#D4AF37]/20 flex items-center justify-center text-2xl">
                🌍
              </div>

              <h3 className="mt-6 text-2xl font-semibold">
                Borderless Payments
              </h3>

              <p className="mt-4 text-white/60 leading-relaxed">
                Pay seamlessly across Africa using Stellar USDC with low fees
                and near-instant settlement.
              </p>
            </div>

            <div className="p-8 rounded-3xl border border-white/10 bg-white/[0.03] hover:bg-white/[0.05] transition">
              <div className="h-14 w-14 rounded-2xl bg-[#D4AF37]/20 flex items-center justify-center text-2xl">
                🏡
              </div>

              <h3 className="mt-6 text-2xl font-semibold">
                Trusted Hosts
              </h3>

              <p className="mt-4 text-white/60 leading-relaxed">
                Discover verified stays, tourism operators, and experiences
                across African destinations.
              </p>
            </div>

            <div className="p-8 rounded-3xl border border-white/10 bg-white/[0.03] hover:bg-white/[0.05] transition">
              <div className="h-14 w-14 rounded-2xl bg-[#D4AF37]/20 flex items-center justify-center text-2xl">
                ⚡
              </div>

              <h3 className="mt-6 text-2xl font-semibold">
                Instant Booking
              </h3>

              <p className="mt-4 text-white/60 leading-relaxed">
                Secure bookings and payments in one seamless experience powered
                by Stellar blockchain infrastructure.
              </p>
            </div>

          </div>
        </div>
      </section>

      {/* HOW IT WORKS */}
      <section id="how" className="py-28 px-6 border-t border-white/10">
        <div className="max-w-6xl mx-auto text-center">

          <h2 className="text-4xl md:text-5xl font-bold">
            How It Works
          </h2>

          <div className="grid md:grid-cols-4 gap-8 mt-20">

            {[
              "Discover",
              "Book",
              "Pay with Stellar",
              "Travel"
            ].map((step, index) => (
              <div
                key={index}
                className="relative p-8 rounded-3xl border border-white/10 bg-white/[0.03]"
              >
                <div className="h-12 w-12 rounded-full bg-[#D4AF37] text-black flex items-center justify-center font-bold mx-auto">
                  {index + 1}
                </div>

                <h3 className="mt-6 text-xl font-semibold">
                  {step}
                </h3>
              </div>
            ))}

          </div>
        </div>
      </section>

      {/* STELLAR SECTION */}
      <section id="stellar" className="py-28 px-6 border-t border-white/10">
        <div className="max-w-7xl mx-auto grid md:grid-cols-2 gap-20 items-center">

          <div>
            <h2 className="text-4xl md:text-5xl font-bold">
              Powered by Stellar
            </h2>

            <p className="mt-8 text-white/60 leading-relaxed text-lg">
              TransVista leverages Stellar blockchain infrastructure to power
              low-cost, cross-border tourism payments using USDC.
            </p>

            <p className="mt-6 text-white/60 leading-relaxed">
              Travelers can book accommodations and experiences across Africa
              while hosts receive secure payments quickly and efficiently.
            </p>
          </div>

          <div className="p-10 rounded-[32px] border border-white/10 bg-white/[0.03]">
            <div className="space-y-6">

              <div className="p-5 rounded-2xl bg-black border border-white/10">
                Traveler Wallet
              </div>

              <div className="text-center text-[#D4AF37] text-2xl">
                ↓
              </div>

              <div className="p-5 rounded-2xl bg-black border border-white/10">
                Stellar Network
              </div>

              <div className="text-center text-[#D4AF37] text-2xl">
                ↓
              </div>

              <div className="p-5 rounded-2xl bg-black border border-white/10">
                Secure Escrow
              </div>

              <div className="text-center text-[#D4AF37] text-2xl">
                ↓
              </div>

              <div className="p-5 rounded-2xl bg-black border border-white/10">
                Host Wallet
              </div>

            </div>
          </div>
        </div>
      </section>

      {/* HOST SECTION */}
      <section id="hosts" className="py-28 px-6 border-t border-white/10">
        <div className="max-w-7xl mx-auto">

          <div className="text-center max-w-2xl mx-auto">
            <h2 className="text-4xl md:text-5xl font-bold">
              Built for African Hosts
            </h2>

            <p className="mt-6 text-white/60">
              Enable global travelers to discover and pay for your properties
              instantly using Stellar-powered payments.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8 mt-20">

            <div className="p-8 rounded-3xl border border-white/10 bg-white/[0.03]">
              <h3 className="text-2xl font-semibold">
                Earn Globally
              </h3>

              <p className="mt-4 text-white/60">
                Reach international travelers across Africa and beyond.
              </p>
            </div>

            <div className="p-8 rounded-3xl border border-white/10 bg-white/[0.03]">
              <h3 className="text-2xl font-semibold">
                Low Fees
              </h3>

              <p className="mt-4 text-white/60">
                Avoid expensive payment processors and banking delays.
              </p>
            </div>

            <div className="p-8 rounded-3xl border border-white/10 bg-white/[0.03]">
              <h3 className="text-2xl font-semibold">
                Fast Settlements
              </h3>

              <p className="mt-4 text-white/60">
                Receive payments quickly through Stellar infrastructure.
              </p>
            </div>

          </div>
        </div>
      </section>

      {/* FUTURE VISION */}
      <section className="py-28 px-6 border-t border-white/10">
        <div className="max-w-5xl mx-auto text-center">

          <h2 className="text-4xl md:text-5xl font-bold">
            Building Africa’s Tourism Infrastructure
          </h2>

          <div className="grid md:grid-cols-3 gap-8 mt-20">

            <div className="p-8 rounded-3xl border border-white/10 bg-white/[0.03]">
              <h3 className="text-2xl font-bold text-[#D4AF37]">
                2026
              </h3>

              <p className="mt-4 text-white/60">
                Ghana MVP Launch
              </p>
            </div>

            <div className="p-8 rounded-3xl border border-white/10 bg-white/[0.03]">
              <h3 className="text-2xl font-bold text-[#D4AF37]">
                2027
              </h3>

              <p className="mt-4 text-white/60">
                West Africa Expansion
              </p>
            </div>

            <div className="p-8 rounded-3xl border border-white/10 bg-white/[0.03]">
              <h3 className="text-2xl font-bold text-[#D4AF37]">
                2028
              </h3>

              <p className="mt-4 text-white/60">
                Pan-African Tourism Network
              </p>
            </div>

          </div>
        </div>
      </section>

      {/* FINAL CTA */}
      <section className="py-32 px-6 border-t border-white/10">
        <div className="max-w-4xl mx-auto text-center">

          <h2 className="text-5xl md:text-6xl font-bold leading-tight">
            Ready to Explore Africa Differently?
          </h2>

          <p className="mt-8 text-xl text-white/60">
            Join the future of tourism powered by Stellar blockchain technology.
          </p>

          <div className="mt-12 flex flex-wrap gap-4 justify-center">
            <button className="px-8 py-4 rounded-2xl bg-[#D4AF37] text-black font-semibold hover:scale-105 transition">
              Join Waitlist
            </button>

            <button className="px-8 py-4 rounded-2xl border border-white/15 bg-white/5 hover:bg-white/10 transition">
              Become a Host
            </button>
          </div>

        </div>
      </section>

      {/* FOOTER */}
      <footer className="border-t border-white/10 py-10 px-6">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6">

          <div>
            <h3 className="text-xl font-bold">
              TransVista
            </h3>

            <p className="mt-2 text-sm text-white/50">
              Travel Africa Without Borders
            </p>
          </div>

          <div className="text-sm text-white/40">
            © {new Date().getFullYear()} TransVista. Powered by Stellar.
          </div>

        </div>
      </footer>

    </main>
  );
}
