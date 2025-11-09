"use client";

import { useState, useEffect } from "react";
import Link from "next/link";

export default function MobileFloatingCTA() {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      // Show CTA after scrolling 300px
      if (window.scrollY > 300) {
        setIsVisible(true);
      } else {
        setIsVisible(false);
      }
    };

    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  if (!isVisible) return null;

  return (
    <div className="fixed bottom-4 left-4 right-4 z-50 md:hidden">
      <Link
        href="#pricing"
        className="block w-full bg-gradient-to-r from-[#FF6F00] to-[#E65100] text-white text-center px-6 py-4 rounded-full font-bold text-lg shadow-2xl hover:shadow-3xl transition-all transform hover:scale-105"
      >
        Essayer gratuitement (sans CB)
      </Link>
    </div>
  );
}
