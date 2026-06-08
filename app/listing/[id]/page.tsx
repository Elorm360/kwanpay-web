import { supabase } from "@/lib/supabase";

import BookingForm from "@/components/BookingForm";

export default async function ListingPage({
  params,
}: {
  params: { id: string };
}) {
  if (!supabase) {
    return (
      <div className="min-h-screen flex items-center justify-center text-white">
        Supabase not configured
      </div>
    );
  }

  const { data, error } = await supabase
    .from("listings")
    .select("*")
    .eq("id", params.id)
    .single();

  if (error || !data) {
    return (
      <div className="min-h-screen flex items-center justify-center text-white">
        Listing not found
      </div>
    );
  }

  return (
    <main className="min-h-screen bg-[#050505] text-white p-10">

      <div className="max-w-4xl mx-auto">

        <div className="rounded-2xl overflow-hidden border border-white/10">
          <img
            src={
              data.image_url ||
              "https://images.unsplash.com/photo-1566073771259-6a8506099945"
            }
            className="w-full h-[400px] object-cover"
          />
        </div>

        <h1 className="text-4xl font-bold mt-8">
          {data.title}
        </h1>

        <p className="text-white/60 mt-2">
          {data.location}
        </p>

        <p className="text-2xl font-bold mt-6">
          ${data.price_per_night} / night
        </p>

        <BookingForm listingId={data.id} />

      </div>

    </main>
  );
}
