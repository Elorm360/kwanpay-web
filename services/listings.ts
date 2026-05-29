import { supabase } from "@/lib/supabase";

export async function getListings() {
  const { data, error } = await supabase
    .from("listings")
    .select("*");

  if (error) {
    console.log("Supabase error:", error);
    return [];
  }

  return data || [];
}
