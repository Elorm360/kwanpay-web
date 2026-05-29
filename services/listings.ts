import { supabase } from "@/lib/supabase";

export async function getListings() {
  if (!supabase) {
    return [];
  }

  const { data, error } = await supabase
    .from("listings")
    .select("*");

  if (error) {
    console.error(error);
    return [];
  }

  return data;
}
