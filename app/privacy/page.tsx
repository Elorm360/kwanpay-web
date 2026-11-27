import LegalPage from "@/components/LegalPage";
import { pageMetadata } from "@/lib/page-metadata";
import { CONTACT_EMAIL, LEGAL_ENTITY } from "@/lib/site";

export const metadata = pageMetadata({
  title: "Privacy Policy",
  description:
    "How KwanPay collects, uses and protects the information you share through our website.",
  path: "/privacy",
});

export default function PrivacyPage() {
  return (
    <LegalPage
      title="Privacy Policy"
      updated="November 25, 2026"
      intro={
        <p>
          This policy explains how {LEGAL_ENTITY} (&ldquo;KwanPay&rdquo;,
          &ldquo;we&rdquo;) handles information you share through this website,
          including our early access and demo request forms. The KwanPay app
          will have its own privacy notice covering wallet and payment data.
        </p>
      }
      sections={[
        {
          heading: "Information we collect",
          body: (
            <>
              <p>When you join early access or request a demo, we collect:</p>
              <ul>
                <li>Your full name and email address</li>
                <li>Your country and whether you are a traveler, business, investor, partner or developer</li>
                <li>Your company name and message, if you choose to provide them</li>
              </ul>
              <p>
                Our hosting provider also processes standard technical data,
                such as IP address and browser type, to deliver and secure the
                site. We do not use advertising trackers on this website.
              </p>
            </>
          ),
        },
        {
          heading: "How we use it",
          body: (
            <ul>
              <li>To contact you about early access, demos and product updates you asked for</li>
              <li>To understand which countries and customer groups to prioritize</li>
              <li>To prevent spam and abuse of our forms</li>
            </ul>
          ),
        },
        {
          heading: "Sharing",
          body: (
            <p>
              We do not sell your information. We share it only with service
              providers that help us run the website and store data (such as our
              hosting and database providers), under agreements that limit their
              use of it, or when required by law.
            </p>
          ),
        },
        {
          heading: "Storage and security",
          body: (
            <p>
              Submissions are stored in a secured database. Only authorized
              KwanPay team members with individual accounts can view them, and
              changes are recorded in an audit log.
            </p>
          ),
        },
        {
          heading: "Retention",
          body: (
            <p>
              We keep your details while early access and launch communications
              are relevant to you, and delete them when you ask us to or when
              they are no longer needed.
            </p>
          ),
        },
        {
          heading: "Your choices",
          body: (
            <p>
              You can ask us to access, correct or delete your information, or
              to stop contacting you, at any time by emailing{" "}
              <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>.
            </p>
          ),
        },
        {
          heading: "Changes",
          body: (
            <p>
              We will update this page if our practices change and revise the
              date above.
            </p>
          ),
        },
      ]}
    />
  );
}
