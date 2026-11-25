import Link from "next/link";

import LegalPage from "@/components/LegalPage";
import { pageMetadata } from "@/lib/page-metadata";
import { CONTACT_EMAIL, LEGAL_ENTITY } from "@/lib/site";

export const metadata = pageMetadata({
  title: "Terms of Use",
  description: "The terms that apply when you use the KwanPay website.",
  path: "/terms",
});

export default function TermsPage() {
  return (
    <LegalPage
      title="Terms of Use"
      updated="November 25, 2026"
      intro={
        <p>
          These terms apply to your use of this website, operated by{" "}
          {LEGAL_ENTITY}. By using the site you agree to them. Use of the
          KwanPay app and wallet will be governed by separate terms that you
          accept when you create an account.
        </p>
      }
      sections={[
        {
          heading: "Private beta",
          body: (
            <p>
              KwanPay is in private beta. Features, availability, supported
              countries and timelines described on this site, including the{" "}
              <Link href="/roadmap">roadmap</Link>, are plans and may change.
              Joining early access does not guarantee access by a particular
              date.
            </p>
          ),
        },
        {
          heading: "No financial services through this website",
          body: (
            <p>
              This website is for information and sign-ups only. It does not
              hold funds, process payments or provide financial, investment or
              legal advice.
            </p>
          ),
        },
        {
          heading: "Acceptable use",
          body: (
            <p>
              Please submit only accurate information about yourself, and do
              not attempt to disrupt the site, access areas you are not
              authorized to use, or submit automated or bulk requests.
            </p>
          ),
        },
        {
          heading: "Intellectual property",
          body: (
            <p>
              The KwanPay name, logo, designs and content on this site belong
              to {LEGAL_ENTITY} and may not be used without our permission.
            </p>
          ),
        },
        {
          heading: "Liability",
          body: (
            <p>
              The site is provided &ldquo;as is&rdquo;. To the extent permitted
              by law, we are not liable for losses arising from your use of the
              site or reliance on its content.
            </p>
          ),
        },
        {
          heading: "Contact",
          body: (
            <p>
              Questions about these terms? Email{" "}
              <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>.
            </p>
          ),
        },
      ]}
    />
  );
}
