type FormCardProps = {
  children: React.ReactNode;
};

/**
 * Shared premium card wrapper used across the onboarding funnel
 * (Demo, Waitlist, Contact). Presentational only — page handles motion.
 */
export default function FormCard({ children }: FormCardProps) {
  return (
    <div className="bg-white rounded-[32px] shadow-2xl border border-slate-200 p-7 md:p-10">
      {children}
    </div>
  );
}

