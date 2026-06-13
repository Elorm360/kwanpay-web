import { NextResponse } from "next/server";
import { createBooking } from "@/services/bookings";

export async function POST(req: Request) {
  try {
    const body = await req.json();

    await createBooking(body);

    return NextResponse.json({
      success: true,
    });
  } catch (error) {
    return NextResponse.json(
      {
        success: false,
        error,
      },
      { status: 500 }
    );
  }
}
