import { supabase } from "@/lib/supabase";

export async function getListings() {
  const { data, error } = await supabase
    .from("listings")
    .select("*");

  if (error) {
    console.error("Supabase error:", error);
    return [];
  }

  return data;
}
