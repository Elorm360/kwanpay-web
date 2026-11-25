import { NextResponse } from "next/server";

import { getCurrentAdmin } from "@/lib/admin-auth";
import { KYC_PHOTO_LINK_SECONDS, type KycPhotoLinks } from "@/lib/kyc-admin";
import { getSupabaseAdmin } from "@/lib/supabaseAdmin";

const UUID = /^[0-9a-f-]{36}$/i;

/** Short-lived links to one submission's ID photos, for operators and up. */
export async function GET(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin("operator");
  if (!admin) {
    return NextResponse.json({ error: "Unauthorized." }, { status: 401 });
  }

  const { id } = await params;
  if (!UUID.test(id)) {
    return NextResponse.json({ error: "Submission not found." }, { status: 404 });
  }

  const supabase = getSupabaseAdmin();
  const { data: submission, error } = await supabase
    .from("kyc_submissions")
    .select("front_path, back_path, selfie_path")
    .eq("id", id)
    .maybeSingle();

  if (error || !submission) {
    return NextResponse.json({ error: "Submission not found." }, { status: 404 });
  }

  const paths = [
    submission.front_path,
    submission.back_path,
    submission.selfie_path,
  ].filter((path): path is string => Boolean(path));

  const { data: signed, error: signError } = await supabase.storage
    .from("kyc-documents")
    .createSignedUrls(paths, KYC_PHOTO_LINK_SECONDS);

  if (signError) {
    console.error("KYC PHOTO LINK ERROR:", signError);
    return NextResponse.json(
      { error: "Unable to load the photos." },
      { status: 500 }
    );
  }

  const urlFor = (path: string | null) =>
    path ? signed?.find((item) => item.path === path)?.signedUrl ?? null : null;

  const photos: KycPhotoLinks = {
    front: urlFor(submission.front_path),
    back: urlFor(submission.back_path),
    selfie: urlFor(submission.selfie_path),
  };

  return NextResponse.json(
    { photos },
    { headers: { "Cache-Control": "no-store" } }
  );
}
