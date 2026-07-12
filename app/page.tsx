import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import Problem from "@/components/Problem";
import HowItWorks from "@/components/HowItWorks";
import ForTravelers from "@/components/ForTravelers";
import ForPlatforms from "@/components/ForPlatforms";
import PaymentInfrastructure from "@/components/PaymentInfrastructure";
import FinalCTA from "@/components/FinalCTA";
import Footer from "@/components/Footer";


export default function Home() {
  return (
    <>
      <Navbar />
      <Hero />
      <Problem />
      <HowItWorks />
      <ForTravelers />
      <ForPlatforms />
      <PaymentInfrastructure />
      <FinalCTA />
      <Footer />
    </>
  );
}

