"use client";

import { useEffect, useState } from "react";
import { AnimatePresence, motion } from "framer-motion";

type ToastKind = "success" | "error";

export type ToastNotificationProps = {
  open: boolean;
  kind: ToastKind;
  title: string;
  messageLines?: string[];
  durationMs?: number;
  onClose: () => void;
};

export default function ToastNotification({
  open,
  kind,
  title,
  messageLines,
  durationMs = 5000,
  onClose,
}: ToastNotificationProps) {
  // Keep this component purely controlled by `open` to avoid sync state updates warnings.
  const [timerId, setTimerId] = useState<number | null>(null);

  useEffect(() => {
    if (!open) return;

    const id = window.setTimeout(() => {
      onClose();
    }, durationMs);

    setTimerId(id);

    return () => {
      window.clearTimeout(id);
    };
  }, [open, durationMs, onClose]);

  const palette =
    kind === "success"
      ? {
          bg: "bg-white",
          border: "border-green-200",
          bar: "bg-green-500",
          text: "text-green-700",
          icon: (
            <svg
              width="18"
              height="18"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M20 6L9 17L4 12"
                stroke="#16a34a"
                strokeWidth="2.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          ),
        }
      : {
          bg: "bg-white",
          border: "border-red-200",
          bar: "bg-red-500",
          text: "text-red-700",
          icon: (
            <svg
              width="18"
              height="18"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M18 6L6 18"
                stroke="#dc2626"
                strokeWidth="2.5"
                strokeLinecap="round"
              />
              <path
                d="M6 6L18 18"
                stroke="#dc2626"
                strokeWidth="2.5"
                strokeLinecap="round"
              />
            </svg>
          ),
        };

  return (
    <div className="fixed top-5 right-5 z-[60] w-[360px] max-w-[calc(100vw-2rem)]">
      <AnimatePresence>
        {open && (
          <motion.div
            role="status"
            aria-live="polite"
            initial={{ opacity: 0, y: -16, x: 40, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, x: 0, scale: 1 }}
            exit={{ opacity: 0, x: 60, scale: 0.95, transition: { duration: 0.25 } }}
            transition={{ type: "spring", stiffness: 300, damping: 26 }}
            className={`relative rounded-2xl shadow-xl border ${palette.border} ${palette.bg} overflow-hidden`}
          >
            <div className={`h-1 w-full ${palette.bar}`} />

            <div className="p-4">
              <div className="flex items-start gap-3">
                <div className="mt-0.5">{palette.icon}</div>
                <div className="flex-1">
                  <div className={`font-bold ${palette.text}`}>{title}</div>
                  {messageLines?.length ? (
                    <div className="mt-1 text-sm text-slate-600 leading-6">
                      {messageLines.map((line, idx) => (
                        <p key={idx}>{line}</p>
                      ))}
                    </div>
                  ) : null}
                </div>

                <button
                  type="button"
                  onClick={onClose}
                  className="ml-2 rounded-lg px-2 py-1 text-slate-500 hover:text-slate-700 hover:bg-slate-50"
                  aria-label="Close notification"
                >
                  <svg
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="M18 6L6 18"
                      stroke="currentColor"
                      strokeWidth="2.5"
                      strokeLinecap="round"
                    />
                    <path
                      d="M6 6L18 18"
                      stroke="currentColor"
                      strokeWidth="2.5"
                      strokeLinecap="round"
                    />
                  </svg>
                </button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

