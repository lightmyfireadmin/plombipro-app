"use client";

import { useState } from "react";

export default function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  const faqs = [
    {
      question: "Pourquoi c'est gratuit jusqu'à 5 devis ?",
      answer:
        "Parce qu'on veut que vous testiez le scan universel et les catalogues des 10 fournisseurs avant de sortir la carte bleue. Si ça ne vous plaît pas, vous gardez le gratuit à vie. Zéro risque.",
    },
    {
      question: "Mes données sont stockées où ?",
      answer:
        "En France et en Europe (serveurs Supabase EU en Irlande) avec sauvegardes quotidiennes automatiques. On ne revend JAMAIS vos données. Conformité RGPD totale.",
    },
    {
      question: "Les 10 fournisseurs sont vraiment intégrés ?",
      answer:
        "Oui. Plus de 50 000 articles (Point P, Cedeo, Leroy Merlin, Manomano, Castorama, Waterout, Distriartisan, SIDER, Legallais, Domomat) avec prix à jour. Catalogues actualisés automatiquement. Vous recherchez un produit, hop il est dans votre devis.",
    },
    {
      question: "Je serai vraiment conforme en 2026 ?",
      answer:
        "Oui, dès maintenant. PlombiPro génère déjà des factures au format Factur-X (obligatoire septembre 2026). Les mises à jour réglementaires sont automatiques et incluses. Vous êtes tranquille.",
    },
    {
      question: "Ça marche sur chantier sans WiFi ?",
      answer:
        "Oui ! L'application mobile fonctionne hors ligne. Vous scannez vos factures sur le chantier, créez vos devis, et tout se synchronise automatiquement quand vous retrouvez le réseau.",
    },
    {
      question: "Je peux importer mes anciens devis ?",
      answer:
        "Oui, import CSV ou Excel en quelques clics. Si vous avez beaucoup de données ou un format particulier, notre équipe peut le faire pour vous gratuitement.",
    },
    {
      question: "C'est facile à prendre en main ?",
      answer:
        "Très facile. Nos utilisateurs créent leur premier devis en moins de 15 minutes. On a des vidéos tutos pour chaque fonctionnalité, et le support français répond en moins de 2h.",
    },
    {
      question: "Puis-je personnaliser mes documents ?",
      answer:
        "Complètement. Votre logo, vos couleurs, vos conditions générales, vos mentions légales... tout est personnalisable. Vous pouvez même créer plusieurs templates différents.",
    },
  ];

  return (
    <section id="faq" className="py-20 bg-white">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center bg-blue-50 rounded-full px-4 py-2 mb-4">
            <svg
              className="w-5 h-5 text-[#1976D2] mr-2"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fillRule="evenodd"
                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z"
                clipRule="evenodd"
              />
            </svg>
            <span className="text-sm font-semibold text-gray-700">FAQ</span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            Les questions qu'on nous pose tout le temps
          </h2>
          <p className="text-xl text-gray-600">
            Tout ce que vous devez savoir avant de vous lancer
          </p>
        </div>

        {/* FAQ Accordion */}
        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <div
              key={index}
              className="bg-gradient-to-br from-gray-50 to-white rounded-2xl border-2 border-gray-200 overflow-hidden transition-all hover:border-[#1976D2] hover:shadow-lg"
            >
              <button
                className="w-full px-6 py-5 text-left flex items-center justify-between"
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
              >
                <span className="font-bold text-lg text-gray-900 pr-8">
                  {faq.question}
                </span>
                <svg
                  className={`w-6 h-6 text-[#1976D2] flex-shrink-0 transition-transform ${
                    openIndex === index ? "transform rotate-180" : ""
                  }`}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </button>
              {openIndex === index && (
                <div className="px-6 pb-5 text-gray-700 leading-relaxed">
                  {faq.answer}
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="mt-12 text-center bg-gradient-to-br from-blue-50 to-white rounded-2xl p-8 border-2 border-blue-200">
          <h3 className="text-2xl font-bold text-gray-900 mb-3">
            Une autre question ?
          </h3>
          <p className="text-gray-600 mb-6">
            Notre équipe répond en moins de 2h pendant les heures ouvrables
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href="mailto:contact@plombipro.fr"
              className="inline-flex items-center justify-center bg-[#1976D2] text-white px-6 py-3 rounded-lg font-semibold hover:bg-[#1565C0] transition-all"
            >
              <svg
                className="w-5 h-5 mr-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                />
              </svg>
              Envoyer un email
            </a>
            <a
              href="#pricing"
              className="inline-flex items-center justify-center bg-white text-[#1976D2] border-2 border-[#1976D2] px-6 py-3 rounded-lg font-semibold hover:bg-blue-50 transition-all"
            >
              Essayer gratuitement
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
