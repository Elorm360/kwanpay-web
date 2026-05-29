import { createClient } from "@supabase/supabase-js";

export default async function ListingPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );

  const { data, error } = await supabase
    .from("listings")
    .select("*")
    .eq("id", params.id)
    .single();

  if (error || !data) {
    return (
      <div className="min-h-screen flex items-center justify-center text-white">
        <div className="text-center">
          <h2 className="text-2xl font-bold">Error loading listing</h2>
          <p className="text-white/60 mt-2">
            {error?.message || "Listing not found"}
          </p>
        </div>
      </div>
    );
  }

  return (
    <main className="min-h-screen bg-[#050505] text-white p-10">

      <div className="max-w-4xl mx-auto">

        {/* IMAGE */}
        <div className="rounded-2xl overflow-hidden border border-white/10">
          <img
            src={
              data.image_url ||
              "https://images.unsplash.com/photo-1566073771259-6a8506099945"
            }
            className="w-full h-[400px] object-cover"
          />
        </div>

        {/* DETAILS */}
        <h1 className="text-4xl font-bold mt-8">
          {data.title}
        </h1>

        <p className="text-white/60 mt-2">
          {data.location}
        </p>

        <p className="text-2xl font-bold mt-6">
          ${data.price_per_night} / night
        </p>

        <p className="mt-6 text-white/70">
          {data.description || "No description available yet."}
        </p>

        {/* BOOK BUTTON */}
        <button className="mt-10 px-8 py-4 bg-[#D4AF37] text-black font-semibold rounded-2xl">
          Book Now
        </button>

      </div>

    </main>
  );
}
