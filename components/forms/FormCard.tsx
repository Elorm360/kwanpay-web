/** Card that holds a form (waitlist, demo request). */
export default function FormCard({ children }: { children: React.ReactNode }) {
  return (
    <div className="rounded-sheet border border-line bg-white p-6 shadow-card md:p-10">
      {children}
    </div>
  );
}
