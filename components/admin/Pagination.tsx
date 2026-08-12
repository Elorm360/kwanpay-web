"use client";

type Props = {
  page: number;
  pageCount: number;
  total: number;
  onPageChange: (page: number) => void;
};

export default function Pagination({
  page,
  pageCount,
  total,
  onPageChange,
}: Props) {
  if (pageCount <= 1) return null;

  return (
    <div className="flex items-center justify-between border-t border-slate-200 px-6 py-4">
      <p className="text-sm text-slate-500">{total} matching leads</p>
      <div className="flex items-center gap-3">
        <button
          type="button"
          disabled={page === 1}
          onClick={() => onPageChange(page - 1)}
          className="rounded-full border border-slate-300 px-4 py-2 text-sm font-semibold disabled:opacity-40"
        >
          Previous
        </button>
        <span className="text-sm text-slate-500">
          {page} / {pageCount}
        </span>
        <button
          type="button"
          disabled={page === pageCount}
          onClick={() => onPageChange(page + 1)}
          className="rounded-full border border-slate-300 px-4 py-2 text-sm font-semibold disabled:opacity-40"
        >
          Next
        </button>
      </div>
    </div>
  );
}
