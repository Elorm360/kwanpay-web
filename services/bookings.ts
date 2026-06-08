import { supabase } from "@/lib/supabase";

export async function createBooking(data: {
  listing_id: number;
  full_name: string;
  email: string;
  phone: string;
  check_in: string;
  check_out: string;
  guests: number;
}) {
  if (!supabase) {
    throw new Error("Supabase not configured");
  }

  const { error } = await supabase
    .from("bookings")
    .insert([
      {
        ...data,
        status: "pending",
      },
    ]);

  if (error) {
    throw error;
  }

  return true;
}
