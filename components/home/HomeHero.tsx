import { ArrowRight } from "lucide-react";

import { ButtonLink } from "@/components/ui/Button";
import { PhoneFrame } from "@/components/ui/PhoneFrame";
import { WalletPreview } from "@/components/home/WalletPreview";
import { PARTNER } from "@/lib/site";

export default function HomeHero() {
  return (
    <section className="bg-paper px-6 pb-20 pt-32 md:pb-28 md:pt-40">
      <div className="mx-auto grid max-w-6xl items-center gap-14 lg:grid-cols-[1.15fr_0.85fr]">
        <div>
          <p className="inline-flex items-center gap-2 rounded-full border border-line bg-white px-3.5 py-1.5 text-sm font-medium text-charcoal">
            <span aria-hidden className="h-1.5 w-1.5 rounded-full bg-amber" />
            Private beta · Starting in Ghana
          </p>

          <h1 className="mt-6 text-balance text-[2.6rem] font-extrabold leading-[1.04] tracking-tight text-ink sm:text-6xl lg:text-[4.25rem]">
            Pay for your whole trip in Ghana from one wallet.
          </h1>

          <p className="mt-6 max-w-xl text-lg leading-8 text-charcoal/80">
            Hold cedis and dollars, pay tour operators, hotels and drivers
            directly, and send money to friends, without carrying cash or
            juggling cards.
          </p>

          <div className="mt-9 flex flex-wrap gap-3">
            <ButtonLink href="/waitlist" variant="accent">
              Join early access
            </ButtonLink>
            <ButtonLink href="/business" variant="secondary">
              For tourism businesses
              <ArrowRight size={16} aria-hidden />
            </ButtonLink>
          </div>

          <p className="mt-8 text-sm text-muted">
            Built with{" "}
            <a
              href={PARTNER.url}
              target="_blank"
              rel="noopener noreferrer"
              className="font-semibold text-ink underline decoration-line underline-offset-4 hover:decoration-ink"
            >
              {PARTNER.name}
            </a>
            , Ghana trip planners.
          </p>
        </div>

        <PhoneFrame
          label="The KwanPay app home screen: a GHS balance, quick actions and recent payments"
          caption="Illustrative example of the KwanPay app"
        >
          <WalletPreview />
        </PhoneFrame>
      </div>
    </section>
  );
}
