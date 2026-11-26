"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";

import {
  KYC_DOCUMENT_LABELS,
  KYC_REJECTION_REASONS,
  maskDocumentNumber,
  type KycPhotoLinks,
  type KycStatus,
  type KycSubmission,
} from "@/lib/kyc-admin";

const TIER_NAMES = ["Basic", "Phone verified", "ID verified", "Full"];

const TABS: { key: KycStatus; label: string }[] = [
  { key: "pending", label: "Waiting" },
  { key: "approved", label: "Approved" },
  { key: "rejected", label: "Rejected" },
];

function waited(from: string, now: string) {
  const minutes = Math.max(
    0,
    Math.round((new Date(now).getTime() - new Date(from).getTime()) / 60_000)
  );
  if (minutes < 60) return `${minutes} min`;
  const hours = Math.round(minutes / 60);
  if (hours < 48) return `${hours} h`;
  return `${Math.round(hours / 24)} days`;
}

function formatDate(value: string | null) {
  if (!value) return "";
  return new Intl.DateTimeFormat("en-GB", {
    day: "numeric",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(value));
}

export default function KycQueue({
  initialSubmissions,
  now,
}: {
  initialSubmissions: KycSubmission[];
  now: string;
}) {
  const router = useRouter();
  const [submissions, setSubmissions] = useState(initialSubmissions);
  const [tab, setTab] = useState<KycStatus>("pending");
  const [search, setSearch] = useState("");
  const [selectedId, setSelectedId] = useState<string | null>(
    initialSubmissions.find((s) => s.status === "pending")?.id ?? null
  );

  const counts = useMemo(
    () =>
      Object.fromEntries(
        TABS.map((t) => [
          t.key,
          submissions.filter((s) => s.status === t.key).length,
        ])
      ) as Record<KycStatus, number>,
    [submissions]
  );

  const visible = useMemo(() => {
    const query = search.trim().toLowerCase();
    return submissions.filter(
      (s) =>
        s.status === tab &&
        (!query ||
          [s.full_name, s.email].some((v) => v?.toLowerCase().includes(query)))
    );
  }, [search, submissions, tab]);

  const selected = submissions.find((s) => s.id === selectedId) ?? null;

  function applyDecision(updated: Partial<KycSubmission> & { id: string }) {
    const next = submissions.map((s) =>
      s.id === updated.id
        ? {
            ...s,
            ...updated,
            current_tier:
              updated.status === "approved"
                ? Math.max(s.current_tier, s.target_tier)
                : s.current_tier,
          }
        : s
    );
    setSubmissions(next);
    // Re-render the server header so the waiting count on the tab is right.
    router.refresh();
    // Move straight on to the next person waiting.
    setSelectedId(
      next.find((s) => s.status === "pending" && s.id !== updated.id)?.id ??
        updated.id
    );
  }

  return (
    <div className="grid gap-6 xl:grid-cols-[minmax(0,1fr)_minmax(0,1.4fr)]">
      <section className="rounded-3xl border border-slate-200 bg-white p-4 sm:p-6">
        <div className="flex flex-wrap gap-2" role="tablist" aria-label="Status">
          {TABS.map((t) => (
            <button
              key={t.key}
              role="tab"
              aria-selected={tab === t.key}
              onClick={() => setTab(t.key)}
              className={`rounded-full px-4 py-2 text-sm font-semibold transition-colors ${
                tab === t.key
                  ? "bg-[#1E2340] text-white"
                  : "bg-slate-100 text-slate-600 hover:bg-slate-200"
              }`}
            >
              {t.label} <span className="opacity-70">{counts[t.key]}</span>
            </button>
          ))}
        </div>

        <label className="mt-4 block">
          <span className="sr-only">Search by name or email</span>
          <input
            type="search"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by name or email"
            className="w-full rounded-2xl border border-slate-200 px-4 py-3 text-sm outline-none focus:border-[#1E2340]"
          />
        </label>

        {visible.length === 0 ? (
          <p className="mt-10 pb-6 text-center text-sm text-slate-500">
            {tab === "pending"
              ? "Nobody is waiting. New ID submissions from the app show up here."
              : "Nothing here yet."}
          </p>
        ) : (
          <ul className="mt-4 divide-y divide-slate-100">
            {visible.map((s) => (
              <li key={s.id}>
                <button
                  onClick={() => setSelectedId(s.id)}
                  aria-current={s.id === selectedId ? "true" : undefined}
                  className={`flex w-full items-center gap-4 rounded-2xl px-3 py-3 text-left transition-colors ${
                    s.id === selectedId ? "bg-[#EDEFF0]" : "hover:bg-slate-50"
                  }`}
                >
                  <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-[#1E2340] text-sm font-bold text-white">
                    {(s.full_name ?? s.email ?? "?").slice(0, 1).toUpperCase()}
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block truncate font-semibold text-[#1E2340]">
                      {s.full_name || "No name on profile"}
                    </span>
                    <span className="block truncate text-xs text-slate-500">
                      {KYC_DOCUMENT_LABELS[s.document_type] ?? s.document_type}{" "}
                      {maskDocumentNumber(s.document_number)}
                    </span>
                  </span>
                  <span className="shrink-0 text-xs text-slate-500">
                    {s.status === "pending"
                      ? `waiting ${waited(s.created_at, now)}`
                      : formatDate(s.reviewed_at)}
                  </span>
                </button>
              </li>
            ))}
          </ul>
        )}
      </section>

      {selected ? (
        <ReviewPanel
          key={selected.id}
          submission={selected}
          onDecided={applyDecision}
        />
      ) : (
        <section className="hidden rounded-3xl border border-dashed border-slate-300 p-10 text-center text-slate-500 xl:block">
          Pick someone from the list to see their documents.
        </section>
      )}
    </div>
  );
}

function ReviewPanel({
  submission,
  onDecided,
}: {
  submission: KycSubmission;
  onDecided: (updated: Partial<KycSubmission> & { id: string }) => void;
}) {
  const [photos, setPhotos] = useState<KycPhotoLinks | null>(null);
  const [photoError, setPhotoError] = useState<string | null>(null);
  const [mode, setMode] = useState<"idle" | "approve" | "reject">("idle");
  const [reason, setReason] = useState<string>(KYC_REJECTION_REASONS[0]);
  const [customReason, setCustomReason] = useState("");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function loadPhotos() {
    setPhotoError(null);
    const response = await fetch(`/api/admin/kyc/${submission.id}/photos`, {
      cache: "no-store",
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) {
      setPhotoError(data.error ?? "Unable to load the photos.");
      return;
    }
    setPhotos(data.photos);
  }

  useEffect(() => {
    void loadPhotos();
    // Links are fetched once per submission; the panel remounts per id.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function decide(approve: boolean) {
    setSaving(true);
    setError(null);
    const finalReason = reason === "other" ? customReason.trim() : reason;
    const response = await fetch(`/api/admin/kyc/${submission.id}/review`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ approve, reason: approve ? undefined : finalReason }),
    });
    const data = await response.json().catch(() => ({}));
    setSaving(false);
    if (!response.ok) {
      setError(data.error ?? "Unable to save the decision.");
      return;
    }
    onDecided(data.submission);
  }

  const pending = submission.status === "pending";
  const docLabel =
    KYC_DOCUMENT_LABELS[submission.document_type] ?? submission.document_type;

  return (
    <section
      aria-label={`Documents from ${submission.full_name ?? "user"}`}
      className="rounded-3xl border border-slate-200 bg-white p-6 sm:p-8"
    >
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div className="min-w-0">
          <h2 className="truncate text-2xl font-black text-[#1E2340]">
            {submission.full_name || "No name on profile"}
          </h2>
          <p className="mt-1 truncate text-sm text-slate-500">
            {submission.email ?? "No email"}
          </p>
        </div>
        <StatusPill status={submission.status} />
      </div>

      <dl className="mt-6 grid gap-4 text-sm sm:grid-cols-3">
        <Fact label="Document" value={docLabel} />
        <Fact
          label="Number entered"
          value={<span className="font-mono">{submission.document_number}</span>}
        />
        <Fact
          label="Account level"
          value={`${TIER_NAMES[submission.current_tier] ?? submission.current_tier} → ${
            TIER_NAMES[submission.target_tier] ?? submission.target_tier
          }`}
        />
        <Fact label="Sent" value={formatDate(submission.created_at)} />
        {submission.reviewed_at ? (
          <Fact label="Decided" value={formatDate(submission.reviewed_at)} />
        ) : null}
      </dl>

      <div className="mt-8 grid gap-4 sm:grid-cols-3">
        <Photo
          label={submission.document_type === "passport" ? "Photo page" : "Front"}
          src={photos?.front}
        />
        {submission.has_back ? <Photo label="Back" src={photos?.back} /> : null}
        <Photo label="Selfie" src={photos?.selfie} />
      </div>
      {photoError ? (
        <p className="mt-3 text-sm text-red-600">
          {photoError}{" "}
          <button onClick={loadPhotos} className="font-semibold underline">
            Try again
          </button>
        </p>
      ) : (
        <p className="mt-3 text-xs text-slate-500">
          Photo links expire after five minutes.{" "}
          <button onClick={loadPhotos} className="font-semibold underline">
            Reload photos
          </button>
        </p>
      )}

      {pending ? (
        <>
          <div className="mt-8 rounded-2xl bg-[#EDEFF0] p-5 text-sm leading-6 text-slate-700">
            <p className="font-semibold text-[#1E2340]">Before approving, check</p>
            <ul className="mt-2 list-disc space-y-1 pl-5">
              <li>The name on the ID matches the profile name above.</li>
              <li>The number on the ID matches the number entered.</li>
              <li>The document is in date and every corner is visible.</li>
              <li>The selfie is the same person as the ID photo.</li>
            </ul>
          </div>

          {mode === "reject" ? (
            <fieldset className="mt-6">
              <legend className="text-sm font-semibold text-[#1E2340]">
                Reason the user will see
              </legend>
              <div className="mt-3 space-y-2">
                {[...KYC_REJECTION_REASONS, "other"].map((option) => (
                  <label
                    key={option}
                    className="flex cursor-pointer items-start gap-3 rounded-xl border border-slate-200 p-3 text-sm hover:bg-slate-50"
                  >
                    <input
                      type="radio"
                      name="reason"
                      value={option}
                      checked={reason === option}
                      onChange={() => setReason(option)}
                      className="mt-1"
                    />
                    <span>{option === "other" ? "Something else" : option}</span>
                  </label>
                ))}
              </div>
              {reason === "other" ? (
                <textarea
                  value={customReason}
                  onChange={(e) => setCustomReason(e.target.value)}
                  maxLength={300}
                  rows={3}
                  placeholder="Write what the user needs to fix"
                  className="mt-3 w-full rounded-2xl border border-slate-200 p-3 text-sm outline-none focus:border-[#1E2340]"
                />
              ) : null}
            </fieldset>
          ) : null}

          {error ? <p className="mt-4 text-sm text-red-600">{error}</p> : null}

          <div className="mt-6 flex flex-wrap gap-3">
            {mode === "idle" ? (
              <>
                <button
                  onClick={() => setMode("approve")}
                  className="rounded-full bg-[#1E2340] px-6 py-3 text-sm font-semibold text-white hover:bg-[#2A3154]"
                >
                  Approve
                </button>
                <button
                  onClick={() => setMode("reject")}
                  className="rounded-full border border-slate-300 px-6 py-3 text-sm font-semibold text-[#1E2340] hover:bg-slate-50"
                >
                  Reject
                </button>
              </>
            ) : (
              <>
                <button
                  disabled={
                    saving ||
                    (mode === "reject" &&
                      reason === "other" &&
                      customReason.trim().length < 5)
                  }
                  onClick={() => decide(mode === "approve")}
                  className={`rounded-full px-6 py-3 text-sm font-semibold disabled:opacity-50 ${
                    mode === "approve"
                      ? "bg-[#1E8E5A] text-white"
                      : "bg-[#D14343] text-white"
                  }`}
                >
                  {saving
                    ? "Saving…"
                    : mode === "approve"
                      ? `Confirm: raise to ${TIER_NAMES[submission.target_tier]}`
                      : "Confirm rejection"}
                </button>
                <button
                  disabled={saving}
                  onClick={() => {
                    setMode("idle");
                    setError(null);
                  }}
                  className="rounded-full px-6 py-3 text-sm font-semibold text-slate-600 hover:bg-slate-100"
                >
                  Cancel
                </button>
              </>
            )}
          </div>
        </>
      ) : submission.rejection_reason ? (
        <p className="mt-8 rounded-2xl bg-red-50 p-4 text-sm text-red-700">
          Told the user: {submission.rejection_reason}
        </p>
      ) : null}
    </section>
  );
}

function Fact({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div>
      <dt className="text-xs uppercase tracking-wide text-slate-500">{label}</dt>
      <dd className="mt-1 font-semibold text-[#1E2340]">{value}</dd>
    </div>
  );
}

function StatusPill({ status }: { status: KycStatus }) {
  const style = {
    pending: "bg-[#D98E3B]/15 text-[#8A5317]",
    approved: "bg-emerald-50 text-emerald-700",
    rejected: "bg-red-50 text-red-700",
  }[status];
  const label = { pending: "Waiting", approved: "Approved", rejected: "Rejected" }[
    status
  ];
  return (
    <span className={`rounded-full px-3 py-1 text-xs font-bold ${style}`}>
      {label}
    </span>
  );
}

function Photo({ label, src }: { label: string; src?: string | null }) {
  return (
    <figure className="overflow-hidden rounded-2xl border border-slate-200 bg-slate-50">
      <div className="flex aspect-[4/3] items-center justify-center">
        {src ? (
          <a href={src} target="_blank" rel="noreferrer noopener" className="block h-full w-full">
            {/* Signed, expiring storage links: next/image would cache them. */}
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={src}
              alt={`${label} of the ID document`}
              referrerPolicy="no-referrer"
              className="h-full w-full object-contain"
            />
          </a>
        ) : (
          <span className="px-4 text-center text-xs text-slate-400">
            {src === null
              ? "Photo not available. Reject and ask for a new one."
              : "Loading…"}
          </span>
        )}
      </div>
      <figcaption className="border-t border-slate-200 px-3 py-2 text-xs font-semibold text-slate-600">
        {label}
      </figcaption>
    </figure>
  );
}
