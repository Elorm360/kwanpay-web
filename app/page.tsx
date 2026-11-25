import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import TrustStrip from "@/components/TrustStrip";
import Problem from "@/components/Problem";
import HowItWorks from "@/components/HowItWorks";
import ForTravelers from "@/components/ForTravelers";
import ForPlatforms from "@/components/ForPlatforms";
import PaymentInfrastructure from "@/components/PaymentInfrastructure";
import FAQ from "@/components/FAQ";
import FinalCTA from "@/components/FinalCTA";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <>
      <Navbar />
      <main id="main">
        <Hero />
        <TrustStrip />
        <Problem />
        <HowItWorks />
        <ForTravelers />
        <ForPlatforms />
        <PaymentInfrastructure />
        <FAQ />
        <FinalCTA />
      </main>
      <Footer />
    </>
  );
}
