import { supabase } from "@/lib/supabase";
import BookingForm from "@/components/BookingForm";

export default async function ListingPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  const { data, error } = await supabase
    .from("listings")
    .select("*")
    .eq("id", id)
    .single();

  if (error) {
    return (
      <div className="min-h-screen bg-black text-white p-10">
        <h1 className="text-2xl font-bold">Supabase Error</h1>

        <pre className="mt-4 text-red-400">
          {JSON.stringify(error, null, 2)}
        </pre>
      </div>
    );
  }

  if (!data) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-black text-white">
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
            alt={data.title}
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

        {/* About */}

<div className="mt-12">

  <h2 className="text-3xl font-bold">
    About this stay
  </h2>

  <p className="mt-6 text-white/70 leading-8">

    Experience comfort, convenience and authentic African hospitality.

    This property is ideal for business travellers, families and tourists looking
    to explore the surrounding attractions while enjoying a secure booking
    experience powered by TransVista.

  </p>

</div>

{/* Amenities */}

<div className="grid md:grid-cols-2 gap-5 mt-12">

  <div className="rounded-2xl border border-white/10 p-5">
    🏖 Beachfront Access
  </div>

  <div className="rounded-2xl border border-white/10 p-5">
    📶 High-Speed Wi-Fi
  </div>

  <div className="rounded-2xl border border-white/10 p-5">
    🚗 Free Parking
  </div>

  <div className="rounded-2xl border border-white/10 p-5">
    🔒 Secure Booking
  </div>

</div>

<div className="mt-16">

  <BookingForm listingId={data.id} />

</div>

      </div>
    </main>
  );
}
