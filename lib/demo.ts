import { supabase } from "@/lib/supabase";

export type DemoRequestData = {
  full_name: string;
  email: string;
  country: string;
  user_type: string;
  company?: string | null;
  message?: string | null;
};

export async function submitDemo(data: DemoRequestData) {
  const { error } = await supabase.from("demo_requests").insert([data]);

  if (error) {
    throw error;
  }

  return true;
}
