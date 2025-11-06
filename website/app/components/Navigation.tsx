"use client";

import { useState } from "react";
import Link from "next/link";

export default function Navigation() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-sm border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <div className="flex items-center">
            <Link href="/" className="flex items-center space-x-2">
              <div className="w-10 h-10 bg-[#1976D2] rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-xl">P</span>
              </div>
              <span className="text-xl font-bold text-gray-900">PlombiPro</span>
            </Link>
          </div>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            <Link href="#features" className="text-gray-700 hover:text-[#1976D2] transition-colors">
              Fonctionnalités
            </Link>
            <Link href="#how-it-works" className="text-gray-700 hover:text-[#1976D2] transition-colors">
              Comment ça marche
            </Link>
            <Link href="#pricing" className="text-gray-700 hover:text-[#1976D2] transition-colors">
              Tarifs
            </Link>
            <Link href="#testimonials" className="text-gray-700 hover:text-[#1976D2] transition-colors">
              Témoignages
            </Link>
          </div>

          {/* CTA Buttons */}
          <div className="hidden md:flex items-center space-x-4">
            <Link
              href="#"
              className="text-gray-700 hover:text-[#1976D2] transition-colors font-medium"
            >
              Connexion
            </Link>
            <Link
              href="#"
              className="bg-[#1976D2] text-white px-6 py-2.5 rounded-lg hover:bg-[#1565C0] transition-colors font-medium"
            >
              Essai gratuit
            </Link>
          </div>

          {/* Mobile menu button */}
          <button
            className="md:hidden p-2 rounded-md text-gray-700 hover:text-[#1976D2] hover:bg-gray-100"
            onClick={() => setIsMenuOpen(!isMenuOpen)}
            aria-label="Menu"
          >
            <svg
              className="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              {isMenuOpen ? (
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              ) : (
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 6h16M4 12h16M4 18h16"
                />
              )}
            </svg>
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      {isMenuOpen && (
        <div className="md:hidden border-t border-gray-200 bg-white">
          <div className="px-2 pt-2 pb-3 space-y-1">
            <Link
              href="#features"
              className="block px-3 py-2 rounded-md text-gray-700 hover:text-[#1976D2] hover:bg-gray-50"
              onClick={() => setIsMenuOpen(false)}
            >
              Fonctionnalités
            </Link>
            <Link
              href="#how-it-works"
              className="block px-3 py-2 rounded-md text-gray-700 hover:text-[#1976D2] hover:bg-gray-50"
              onClick={() => setIsMenuOpen(false)}
            >
              Comment ça marche
            </Link>
            <Link
              href="#pricing"
              className="block px-3 py-2 rounded-md text-gray-700 hover:text-[#1976D2] hover:bg-gray-50"
              onClick={() => setIsMenuOpen(false)}
            >
              Tarifs
            </Link>
            <Link
              href="#testimonials"
              className="block px-3 py-2 rounded-md text-gray-700 hover:text-[#1976D2] hover:bg-gray-50"
              onClick={() => setIsMenuOpen(false)}
            >
              Témoignages
            </Link>
            <div className="pt-4 flex flex-col space-y-2">
              <Link
                href="#"
                className="block px-3 py-2 rounded-md text-center text-gray-700 hover:text-[#1976D2] hover:bg-gray-50 font-medium"
              >
                Connexion
              </Link>
              <Link
                href="#"
                className="block px-3 py-2 rounded-md text-center bg-[#1976D2] text-white hover:bg-[#1565C0] font-medium"
              >
                Essai gratuit
              </Link>
            </div>
          </div>
        </div>
      )}
    </nav>
  );
}
