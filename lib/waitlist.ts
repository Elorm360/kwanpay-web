import { supabase } from "@/lib/supabase";

export type WaitlistRequestData = {
  full_name: string;
  email: string;
  country: string;
  role: string;
};

export async function submitWaitlist(data: WaitlistRequestData) {
  const { error } = await supabase.from("early_access").insert([data]);

  if (error) {
    throw error;
  }

  return true;
}

