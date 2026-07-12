import { createClient } from "@supabase/supabase-js";

// Server-side client for RLS/authenticated inserts.
// Note: this uses service-role and bypasses RLS.
// Use only if you want to bypass RLS for server writes.

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceRoleKey) {
  throw new Error("Missing Supabase service role environment variables");
}

export const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey);

