import { supabaseAdmin } from "@/lib/supabaseAdmin";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
  try {
    const body = await req.json();

    const { error } = await supabaseAdmin
      .from("waitlist")
      .insert([
        {
          full_name: body.full_name,
          email: body.email,
          country: body.country,
          user_type: body.role ?? body.user_type,
          company: body.company,
          message: body.message,
        },
      ]);

    if (error) {
      console.error("WAITLIST INSERT ERROR:", error);

      return NextResponse.json(
        {
          success: false,
          error: error.message,
        },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
    });
  } catch (err) {
    console.error(err);

    return NextResponse.json(
      {
        success: false,
      },
      { status: 500 }
    );
  }
}

// Export a named GET handler to satisfy Next.js route validator
export async function GET() {
  return NextResponse.json({
    success: false,
    error: "Method not allowed",
  });
}

