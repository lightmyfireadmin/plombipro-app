"use client";

import Link from "next/link";
import { useState, useEffect } from "react";

export default function Hero() {
  const [countdown, setCountdown] = useState({ days: 0, hours: 0, minutes: 0 });
  const [spotsRemaining] = useState(327);

  // Countdown to Sept 1, 2026 compliance deadline
  useEffect(() => {
    const calculateCountdown = () => {
      const target = new Date("2026-09-01T00:00:00");
      const now = new Date();
      const diff = target.getTime() - now.getTime();

      if (diff > 0) {
        setCountdown({
          days: Math.floor(diff / (1000 * 60 * 60 * 24)),
          hours: Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)),
          minutes: Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60)),
        });
      }
    };

    // Calculate immediately on mount
    calculateCountdown();

    // Update every minute
    const interval = setInterval(calculateCountdown, 60000);

    return () => clearInterval(interval);
  }, []);

  return (
    <section className="relative bg-gradient-to-br from-[#1976D2] via-[#1565C0] to-[#0D47A1] text-white pt-24 sm:pt-32 pb-16 sm:pb-24 overflow-hidden">
      {/* Animated Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute inset-0" style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
        }} />
      </div>

      {/* Floating gradient orbs for depth */}
      <div className="absolute top-20 left-10 w-72 h-72 bg-blue-400 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob"></div>
      <div className="absolute top-40 right-10 w-72 h-72 bg-purple-400 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-2000"></div>
      <div className="absolute -bottom-8 left-40 w-72 h-72 bg-pink-400 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-4000"></div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left Column - Text Content */}
          <div className="text-center lg:text-left">
            {/* 2026 Urgency Badge with Countdown */}
            <div className="inline-flex flex-col items-center bg-gradient-to-r from-red-500 to-orange-500 rounded-xl px-4 sm:px-6 py-3 sm:py-4 mb-4 sm:mb-6 shadow-2xl">
              <div className="flex items-center mb-1.5 sm:mb-2">
                <svg className="w-4 h-4 sm:w-5 sm:h-5 text-white mr-1.5 sm:mr-2 animate-pulse" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                </svg>
                <span className="text-xs sm:text-base font-bold text-white">Facturation électronique obligatoire</span>
              </div>
              <div className="flex gap-2 sm:gap-4 text-white">
                <div className="text-center">
                  <div className="text-xl sm:text-3xl font-bold">{countdown.days}</div>
                  <div className="text-[10px] sm:text-xs opacity-90">jours</div>
                </div>
                <div className="text-lg sm:text-2xl font-bold self-center">:</div>
                <div className="text-center">
                  <div className="text-xl sm:text-3xl font-bold">{countdown.hours}</div>
                  <div className="text-[10px] sm:text-xs opacity-90">heures</div>
                </div>
                <div className="text-lg sm:text-2xl font-bold self-center">:</div>
                <div className="text-center">
                  <div className="text-xl sm:text-3xl font-bold">{countdown.minutes}</div>
                  <div className="text-[10px] sm:text-xs opacity-90">min</div>
                </div>
              </div>
            </div>

            {/* Main Headline - Enhanced */}
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold leading-tight mb-4 sm:mb-6 animate-fade-in-up">
              La <span className="relative">
                <span className="relative z-10">SEULE</span>
                <span className="absolute bottom-2 left-0 right-0 h-4 bg-[#FF6F00] opacity-30 transform -rotate-1"></span>
              </span> application{" "}
              <span className="bg-gradient-to-r from-[#FF6F00] via-[#FFC107] to-[#FF6F00] bg-clip-text text-transparent animate-gradient-x">
                100% dédiée aux plombiers
              </span>
            </h1>

            <p className="text-base sm:text-lg text-blue-100 mb-5 sm:mb-6 leading-relaxed">
              Photographiez vos factures Point P ou Cedeo : les articles s'ajoutent automatiquement dans votre devis.
              <br className="hidden sm:block" />
              <strong className="text-white">Créez un devis complet en 2 minutes</strong> au lieu de 45.
              <br className="hidden sm:block" />
              <span className="text-[#4CAF50] font-bold">Prix ultra-compétitif.</span> Conforme facturation 2026.
            </p>

            {/* Key USPs - Animated */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 sm:gap-3 mb-6">
              {[
                { icon: "📸", text: "Photo → Devis automatique", badge: "EXCLUSIF" },
                { icon: "🔧", text: "100% spécial plombiers", badge: "UNIQUE" },
                { icon: "💶", text: "19,90€/mois tout compris", badge: "LE - CHER" },
                { icon: "✅", text: "Conforme 2026", badge: "GARANTI" },
              ].map((item, index) => (
                <div
                  key={index}
                  className="group flex flex-col items-center bg-white/10 backdrop-blur-md rounded-lg p-2 sm:p-3 hover:bg-white/20 transition-all border border-white/20"
                >
                  <div className="text-2xl sm:text-3xl mb-1">{item.icon}</div>
                  <span className="text-xs font-semibold text-center leading-tight">{item.text}</span>
                  <span className="text-[10px] sm:text-xs bg-[#FF6F00] px-1.5 py-0.5 rounded-full mt-1 font-bold whitespace-nowrap">{item.badge}</span>
                </div>
              ))}
            </div>

            {/* CTA Buttons - Enhanced */}
            <div className="flex flex-col sm:flex-row gap-3 justify-center lg:justify-start mb-6 sm:mb-8">
              <Link
                href="#pricing"
                className="group relative bg-gradient-to-r from-[#FF6F00] to-[#E65100] text-white px-6 sm:px-8 py-3.5 sm:py-4 rounded-xl font-bold text-base sm:text-lg hover:shadow-2xl transition-all overflow-hidden"
              >
                <span className="relative z-10 flex items-center justify-center">
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                  </svg>
                  Essayer gratuitement (sans CB)
                </span>
                <div className="absolute inset-0 bg-white opacity-0 group-hover:opacity-20 transition-opacity"></div>
              </Link>
              <Link
                href="#demo-video"
                className="group bg-white/10 backdrop-blur-sm text-white border-2 border-white/40 px-6 sm:px-8 py-3.5 sm:py-4 rounded-xl font-bold text-base sm:text-lg hover:bg-white/20 transition-all flex items-center justify-center gap-2"
              >
                <svg className="w-5 h-5 group-hover:scale-110 transition-transform" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" />
                </svg>
                Voir la démo (2 min)
              </Link>
            </div>

            {/* Trust Indicators - Enhanced */}
            <div className="space-y-6">
              {/* Stats Bar */}
              <div className="flex flex-wrap items-center justify-center lg:justify-start gap-6 lg:gap-8">
                <div className="flex items-center gap-3 bg-white/10 backdrop-blur-sm rounded-full px-5 py-3 border border-white/20">
                  <div className="flex">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <svg key={star} className="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                      </svg>
                    ))}
                  </div>
                  <div className="flex flex-col">
                    <span className="font-bold text-xl">4.8/5</span>
                    <span className="text-xs text-blue-200">247 avis</span>
                  </div>
                </div>

                <div className="flex flex-col bg-white/10 backdrop-blur-sm rounded-full px-5 py-3 border border-white/20">
                  <span className="font-bold text-3xl">500+</span>
                  <span className="text-sm text-blue-200">plombiers actifs</span>
                  <span className="text-xs text-green-300 flex items-center gap-1 mt-1">
                    <span className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></span>
                    Vérifié Nov 2025
                  </span>
                </div>

                <div className="flex flex-col bg-white/10 backdrop-blur-sm rounded-full px-5 py-3 border border-white/20">
                  <span className="font-bold text-3xl">15k+</span>
                  <span className="text-sm text-blue-200">devis créés</span>
                </div>
              </div>

              {/* Live Activity */}
              <div className="flex flex-col sm:flex-row gap-3 items-center justify-center lg:justify-start">
                <div className="inline-flex items-center bg-green-500/20 backdrop-blur-sm rounded-full px-5 py-3 border border-green-400/30 animate-pulse-soft">
                  <span className="inline-block w-3 h-3 bg-green-400 rounded-full mr-3 animate-ping"></span>
                  <span className="text-sm text-green-100 font-medium">
                    🟢 12 plombiers ont créé leur compte aujourd'hui
                  </span>
                </div>

                <div className="inline-flex items-center bg-orange-500/20 backdrop-blur-sm rounded-full px-5 py-3 border border-orange-400/30">
                  <svg className="w-5 h-5 text-orange-300 mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M12.395 2.553a1 1 0 00-1.45-.385c-.345.23-.614.558-.822.88-.214.33-.403.713-.57 1.116-.334.804-.614 1.768-.84 2.734a31.365 31.365 0 00-.613 3.58 2.64 2.64 0 01-.945-1.067c-.328-.68-.398-1.534-.398-2.654A1 1 0 005.05 6.05 6.981 6.981 0 003 11a7 7 0 1011.95-4.95c-.592-.591-.98-.985-1.348-1.467-.363-.476-.724-1.063-1.207-2.03zM12.12 15.12A3 3 0 017 13s.879.5 2.5.5c0-1 .5-4 1.25-4.5.5 1 .786 1.293 1.371 1.879A2.99 2.99 0 0113 13a2.99 2.99 0 01-.879 2.121z" clipRule="evenodd" />
                  </svg>
                  <span className="text-sm text-orange-100 font-bold">
                    {spotsRemaining}/1000 places "Prix Fondateur"
                  </span>
                </div>
              </div>

              {/* Guarantee Badge */}
              <div className="inline-flex items-center bg-white/10 backdrop-blur-sm rounded-2xl px-6 py-3 border border-white/20">
                <svg className="w-6 h-6 text-green-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
                <div className="flex flex-col">
                  <span className="text-sm font-semibold">Satisfait ou remboursé 30 jours</span>
                  <span className="text-xs text-blue-200">+ 14 jours d'essai gratuit sans CB</span>
                </div>
              </div>
            </div>
          </div>

          {/* Mobile Phone Background - Enhanced */}
          <div className="lg:hidden absolute inset-0 pointer-events-none overflow-hidden">
            {/* Phone Mockup with Content */}
            <div className="absolute right-[-80px] top-32 w-72 h-[580px] opacity-25">
              {/* Phone Frame */}
              <div className="relative w-full h-full bg-gradient-to-br from-gray-900 to-gray-800 rounded-[2.5rem] p-3 shadow-2xl transform rotate-12">
                <div className="bg-white rounded-[2rem] h-full overflow-hidden">
                  {/* Status Bar */}
                  <div className="bg-gradient-to-r from-[#1976D2] to-[#1565C0] px-4 py-3 flex items-center justify-between text-white text-xs">
                    <span className="font-semibold">9:41</span>
                    <div className="flex gap-1">
                      <div className="w-3 h-3 bg-white/30 rounded"></div>
                      <div className="w-3 h-3 bg-white/50 rounded"></div>
                      <div className="w-3 h-3 bg-white rounded"></div>
                    </div>
                  </div>

                  {/* App Content Preview */}
                  <div className="p-4 bg-gradient-to-br from-blue-50 to-white h-full">
                    <div className="text-center mb-4">
                      <h3 className="text-lg font-bold text-gray-900">Scan automatique</h3>
                      <p className="text-xs text-gray-600">Facture Point P</p>
                    </div>

                    {/* Camera View */}
                    <div className="relative bg-gray-100 rounded-xl p-4 mb-3 aspect-square flex items-center justify-center border-2 border-dashed border-blue-300">
                      <div className="absolute top-3 left-3 right-3 bottom-3 border-2 border-[#FF6F00] rounded-lg animate-pulse"></div>
                      <svg className="w-16 h-16 text-[#1976D2]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                      </svg>
                    </div>

                    {/* Extracted Items */}
                    <div className="bg-white rounded-lg p-3 shadow-md">
                      <div className="flex items-center gap-2 mb-2">
                        <div className="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center">
                          <span className="text-green-600 font-bold text-xs">✓</span>
                        </div>
                        <span className="text-xs font-semibold text-gray-900">8 articles détectés</span>
                      </div>
                      <div className="space-y-1.5">
                        <div className="flex justify-between text-[10px] text-gray-600">
                          <span>Radiateur 1500W</span>
                          <span className="font-semibold">189€</span>
                        </div>
                        <div className="flex justify-between text-[10px] text-gray-600">
                          <span>Tuyau PER Ø16</span>
                          <span className="font-semibold">38€</span>
                        </div>
                        <div className="flex justify-between text-[10px] text-gray-600">
                          <span>Raccords x10</span>
                          <span className="font-semibold">45€</span>
                        </div>
                      </div>
                    </div>

                    {/* Mini CTA */}
                    <button className="w-full mt-3 bg-gradient-to-r from-[#FF6F00] to-[#E65100] text-white py-2 rounded-lg font-bold text-xs shadow-md">
                      Créer le devis
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Text Content Backdrop for Readability on Mobile */}
          <div className="lg:hidden absolute inset-0 bg-gradient-to-r from-[#1976D2]/90 via-[#1565C0]/85 to-transparent pointer-events-none"></div>

          {/* Right Column - Interactive Demo Mockup */}
          <div className="hidden lg:block relative">
            <div className="relative">
              {/* Main Phone Mockup with Glow */}
              <div className="relative z-10 mx-auto w-80 h-[650px] bg-gradient-to-br from-gray-900 to-gray-800 rounded-[3.5rem] p-4 shadow-2xl transform hover:scale-105 transition-transform duration-500 ring-4 ring-white/20">
                <div className="bg-white rounded-[3rem] h-full overflow-hidden relative">
                  {/* Status Bar */}
                  <div className="bg-gradient-to-r from-[#1976D2] to-[#1565C0] px-6 py-4 flex items-center justify-between text-white text-sm">
                    <span className="font-semibold">9:41</span>
                    <div className="flex gap-1">
                      <div className="w-4 h-4 bg-white/30 rounded"></div>
                      <div className="w-4 h-4 bg-white/50 rounded"></div>
                      <div className="w-4 h-4 bg-white/70 rounded"></div>
                      <div className="w-4 h-4 bg-white rounded"></div>
                    </div>
                  </div>

                  {/* App Content - Scanner Demo */}
                  <div className="p-6 bg-gradient-to-br from-blue-50 to-white h-full">
                    <div className="text-center mb-6">
                      <h3 className="text-2xl font-bold text-gray-900 mb-1">Scan automatique</h3>
                      <p className="text-sm text-gray-600">Prenez en photo votre facture</p>
                    </div>

                    {/* Camera View Simulation */}
                    <div className="relative bg-gradient-to-br from-gray-100 to-gray-200 rounded-2xl p-6 mb-4 border-4 border-dashed border-blue-300 aspect-square flex items-center justify-center">
                      <div className="absolute top-4 left-4 right-4 bottom-4 border-2 border-[#FF6F00] rounded-lg animate-pulse-soft"></div>
                      <svg className="w-24 h-24 text-[#1976D2] animate-bounce-soft" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                      </svg>
                    </div>

                    {/* Extraction Progress */}
                    <div className="bg-white rounded-xl p-4 shadow-lg">
                      <div className="flex items-center gap-3 mb-3">
                        <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                          <svg className="w-6 h-6 text-green-600 animate-spin-slow" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                          </svg>
                        </div>
                        <div className="flex-1">
                          <p className="text-sm font-semibold text-gray-900">Extraction en cours...</p>
                          <p className="text-xs text-gray-500">12 articles détectés</p>
                        </div>
                        <span className="text-2xl font-bold text-[#4CAF50]">✓</span>
                      </div>
                      <div className="space-y-2">
                        <div className="flex justify-between text-xs text-gray-600">
                          <span>Radiateur 1500W</span>
                          <span className="font-semibold">189,90€</span>
                        </div>
                        <div className="flex justify-between text-xs text-gray-600">
                          <span>Tuyau PER Ø16 - 50m</span>
                          <span className="font-semibold">38,50€</span>
                        </div>
                        <div className="flex justify-between text-xs text-gray-600">
                          <span>Raccords laiton x10</span>
                          <span className="font-semibold">45,80€</span>
                        </div>
                      </div>
                    </div>

                    {/* CTA Button in Phone */}
                    <button className="w-full mt-4 bg-gradient-to-r from-[#FF6F00] to-[#E65100] text-white py-3 rounded-xl font-bold shadow-lg transform hover:scale-105 transition-transform">
                      Créer le devis (2 min)
                    </button>
                  </div>
                </div>

                {/* Glow Effect */}
                <div className="absolute inset-0 bg-gradient-to-r from-blue-400 to-purple-500 rounded-[3.5rem] blur-2xl opacity-20 -z-10 animate-pulse-soft"></div>
              </div>

              {/* Floating Success Card */}
              <div className="absolute -left-10 top-20 bg-white rounded-2xl shadow-2xl p-5 w-72 transform rotate-[-5deg] hover:rotate-0 transition-transform z-20 border-2 border-green-200">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-semibold text-gray-600">Devis #2847</span>
                  <span className="bg-green-500 text-white text-xs px-3 py-1 rounded-full font-bold">Accepté ✓</span>
                </div>
                <p className="text-4xl font-extrabold text-gray-900 mb-1">4 280 €</p>
                <p className="text-sm text-gray-600 mb-3">Rénovation salle de bain</p>
                <div className="flex items-center gap-2 text-xs text-green-700 bg-green-50 rounded-lg p-2">
                  <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clipRule="evenodd" />
                  </svg>
                  <span className="font-semibold">Créé en 2 min par photo</span>
                </div>
              </div>

              {/* Floating Time Saved Badge */}
              <div className="absolute -right-10 bottom-32 bg-gradient-to-br from-[#FF6F00] to-[#E65100] text-white rounded-2xl shadow-2xl p-6 w-64 transform rotate-[5deg] hover:rotate-0 transition-transform z-20">
                <div className="text-center">
                  <p className="text-sm font-semibold mb-2">Temps économisé ce mois</p>
                  <p className="text-5xl font-extrabold mb-1">12h</p>
                  <p className="text-sm opacity-90">= 600€ de temps facturable</p>
                  <div className="mt-3 pt-3 border-t border-white/30">
                    <p className="text-xs">sur 25 devis créés</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Wave Divider */}
      <div className="absolute bottom-0 left-0 right-0">
        <svg viewBox="0 0 1440 120" fill="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-auto">
          <path d="M0 120L60 110C120 100 240 80 360 70C480 60 600 60 720 65C840 70 960 80 1080 75C1200 70 1320 50 1380 40L1440 30V120H1380C1320 120 1200 120 1080 120C960 120 840 120 720 120C600 120 480 120 360 120C240 120 120 120 60 120H0Z" fill="white"/>
        </svg>
      </div>

      {/* Custom Animations */}
      <style jsx>{`
        @keyframes gradient-x {
          0%, 100% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
        }
        @keyframes blob {
          0%, 100% { transform: translate(0, 0) scale(1); }
          33% { transform: translate(30px, -50px) scale(1.1); }
          66% { transform: translate(-20px, 20px) scale(0.9); }
        }
        @keyframes bounce-soft {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-10px); }
        }
        @keyframes pulse-soft {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.8; }
        }
        @keyframes spin-slow {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
        .animate-gradient-x { animation: gradient-x 3s ease infinite; background-size: 200% 200%; }
        .animate-blob { animation: blob 7s infinite; }
        .animation-delay-2000 { animation-delay: 2s; }
        .animation-delay-4000 { animation-delay: 4s; }
        .animate-bounce-soft { animation: bounce-soft 2s ease-in-out infinite; }
        .animate-pulse-soft { animation: pulse-soft 2s ease-in-out infinite; }
        .animate-spin-slow { animation: spin-slow 3s linear infinite; }
        .animate-fade-in-up { animation: fadeInUp 0.6s ease-out; }
        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>
    </section>
  );
}
