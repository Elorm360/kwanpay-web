import { supabase } from "@/lib/supabase";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
  try {
    const body = await req.json();

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
      console.error(error);

      return NextResponse.json(
        { success: false },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
    });
  } catch (err) {
    console.error(err);

    return NextResponse.json(
      { success: false },
      { status: 500 }
    );
  }
}
