import Navbar from "@/components/Navbar";
import HomeHero from "@/components/home/HomeHero";
import PaymentFlow from "@/components/home/PaymentFlow";
import Audiences from "@/components/home/Audiences";
import TrustFacts from "@/components/home/TrustFacts";
import StartingPoint from "@/components/home/StartingPoint";
import FAQ from "@/components/FAQ";
import ClosingCta from "@/components/home/ClosingCta";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <>
      <Navbar />
      <main id="main">
        <HomeHero />
        <PaymentFlow />
        <Audiences />
        <TrustFacts />
        <StartingPoint />
        <FAQ />
        <ClosingCta />
      </main>
      <Footer />
    </>
  );
}
