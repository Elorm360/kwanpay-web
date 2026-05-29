import { supabase } from "@/lib/supabase";

export async function getListings() {
  const { data, error } = await supabase
    .from("listings")
    .select("*");

  if (error) {
    console.log(error);
    return [];
  }

  return data;
}
