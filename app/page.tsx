export default function Home() {
  return (
    <div className="min-h-screen bg-black text-white flex flex-col">
      
      {/* NAV */}
      <header className="flex justify-between items-center px-6 py-5 border-b border-white/10">
        <h1 className="text-xl font-bold">TransVista</h1>
        <button className="px-4 py-2 bg-white text-black rounded-xl">
          Join Waitlist
        </button>
      </header>

      {/* HERO */}
      <main className="flex-1 flex flex-col items-center justify-center text-center px-6">
        <h1 className="text-5xl font-bold max-w-3xl">
          Travel Africa Without Borders
        </h1>

        <p className="mt-6 text-white/70 max-w-2xl">
          A blockchain-powered tourism platform enabling seamless bookings and instant cross-border payments across Africa using Stellar USDC.
        </p>

        <div className="mt-8 flex gap-3">
          <input
            className="px-4 py-3 rounded-xl bg-white/10 border border-white/20"
            placeholder="Enter email"
          />
          <button className="px-6 py-3 bg-white text-black rounded-xl font-semibold">
            Get Access
          </button>
        </div>
      </main>

      {/* FEATURES */}
      <section className="grid md:grid-cols-3 gap-6 px-10 py-16">
        <div className="p-6 bg-white/5 rounded-2xl border border-white/10">
          <h3 className="font-bold">Borderless Payments</h3>
          <p className="text-white/60 text-sm mt-2">
            Pay instantly using Stellar USDC.
          </p>
        </div>

        <div className="p-6 bg-white/5 rounded-2xl border border-white/10">
          <h3 className="font-bold">Trusted Bookings</h3>
          <p className="text-white/60 text-sm mt-2">
            Verified tourism providers across Africa.
          </p>
        </div>

        <div className="p-6 bg-white/5 rounded-2xl border border-white/10">
          <h3 className="font-bold">Real Utility</h3>
          <p className="text-white/60 text-sm mt-2">
            Built for real-world tourism adoption.
          </p>
        </div>
      </section>

      {/* FOOTER */}
      <footer className="text-center py-6 text-white/40 text-sm border-t border-white/10">
        © {new Date().getFullYear()} TransVista
      </footer>

    </div>
  );
}
