import Navigation from "./components/Navigation";
import Hero from "./components/Hero";
import ProblemSolution from "./components/ProblemSolution";
import Features from "./components/Features";
import BeforeAfter from "./components/BeforeAfter";
import HowItWorks from "./components/HowItWorks";
import Pricing from "./components/Pricing";
import FAQ from "./components/FAQ";
import Testimonials from "./components/Testimonials";
import TrustBar from "./components/TrustBar";
import Footer from "./components/Footer";
import MobileFloatingCTA from "./components/MobileFloatingCTA";

export default function Home() {
  return (
    <div className="min-h-screen">
      <Navigation />
      <main>
        <Hero />
        <ProblemSolution />
        <Features />
        <BeforeAfter />
        <HowItWorks />
        <Pricing />
        <FAQ />
        <Testimonials />
      </main>
      <TrustBar />
      <Footer />
      <MobileFloatingCTA />
    </div>
  );
}
