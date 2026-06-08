import { createClient } from "@supabase/supabase-js";

const supabaseUrl =
  process.env.NEXT_PUBLIC_SUPABASE_URl;

const supabaseAnonKey =
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!superbaseUrl || !superbaseAnonKey) {
  throw new Error("Missing superbase environment variables");
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
