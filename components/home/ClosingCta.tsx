import { ButtonLink } from "@/components/ui/Button";

export default function ClosingCta() {
  return (
    <section id="join" className="bg-ink px-6 py-20 md:py-24">
      <div className="mx-auto flex max-w-6xl flex-col items-start gap-8 md:flex-row md:items-center md:justify-between">
        <div>
          <h2 className="text-balance text-3xl font-extrabold tracking-tight text-white md:text-4xl">
            Be among the first to use KwanPay in Ghana.
          </h2>
          <p className="mt-3 text-white/70">
            Early access is free. We&apos;ll invite you as we open the beta.
          </p>
        </div>
        <div className="flex flex-wrap gap-3">
          <ButtonLink href="/waitlist" variant="accent">
            Join early access
          </ButtonLink>
          <ButtonLink href="/demo" variant="onDark">
            Request a demo
          </ButtonLink>
        </div>
      </div>
    </section>
  );
}
