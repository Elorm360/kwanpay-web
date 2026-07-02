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

       <div className="relative overflow-hidden rounded-[32px] shadow-2xl">

  <img
    src={
      data.image_url ||
      "https://images.unsplash.com/photo-1566073771259-6a8506099945"
    }
    alt={data.title}
    className="w-full h-[520px] object-cover transition duration-700 hover:scale-105"
  />

  <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/10 to-transparent" />

  <div className="absolute bottom-8 left-8">

    <span className="bg-blue-600 text-white px-5 py-2 rounded-full font-semibold shadow-lg">

      📍 {data.location}

    </span>

  </div>

  <div className="absolute top-8 right-8">

    <span className="bg-white text-slate-900 px-5 py-2 rounded-full font-bold shadow-lg">

      ★ 4.9

    </span>

  </div>

</div>

       <div className="mt-10 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-8">

  <div>

    <h1 className="text-5xl font-extrabold tracking-tight">
      {data.title}
    </h1>

    <p className="mt-4 text-xl text-white/70">
      Luxury stay in {data.location}
    </p>

  </div>

  <div className="rounded-3xl bg-blue-600 px-8 py-6 shadow-xl">

    <p className="text-sm uppercase tracking-wider text-blue-100">
      Starting From
    </p>

    <h2 className="text-4xl font-bold">
      ${data.price_per_night}
    </h2>

    <p className="text-blue-100">
      per night
    </p>

  </div>

</div>

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
