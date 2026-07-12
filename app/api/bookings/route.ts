import { supabase } from "@/lib/supabase";
import { NextResponse } from "next/server";
import { z } from "zod";

const BookingSchema = z.object({
  listing_id: z.coerce.number().int().positive(),
  full_name: z.string().min(1).max(200),
  email: z.string().email().max(254),
  phone: z.string().min(3).max(50),
  check_in: z.string().min(1).max(40),
  check_out: z.string().min(1).max(40),
  guests: z.coerce.number().int().positive().max(50),
});

export async function POST(req: Request) {
  try {
    const body = BookingSchema.parse(await req.json());

    const { error } = await supabase
      .from("bookings")
      .insert([
        {
          listing_id: body.listing_id,
          full_name: body.full_name,
          email: body.email,
          phone: body.phone,
          check_in: body.check_in,
          check_out: body.check_out,
          guests: body.guests,
          status: "pending",
        },
      ]);

   if (error) {
  console.error("BOOKING INSERT ERROR:", error);

  return NextResponse.json(
    {
      success: false,
      error: error.message,
    },
    { status: 500 }
  );
}

    return NextResponse.json({ success: true });
  } catch (err) {
    console.error(err);

    return NextResponse.json(
      { success: false },
      { status: 500 }
    );
  }
}
