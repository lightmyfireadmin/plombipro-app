export default function Pricing() {
  const plans = [
    {
      name: "Gratuit",
      price: "0",
      originalPrice: null,
      period: "pour toujours",
      description: "Pour tester sans carte bancaire",
      features: [
        "5 devis par mois",
        "5 factures par mois",
        "Scan automatique illimité",
        "Accès aux 50 000 articles",
        "Gestion des clients",
        "Application mobile",
        "Support par email",
      ],
      cta: "Essayer gratuitement (sans CB)",
      popular: false,
      gradient: "from-gray-700 to-gray-900",
      badge: null,
    },
    {
      name: "Pro",
      price: "19,90",
      originalPrice: null,
      period: "par mois",
      description: "Tout illimité, le prix le plus bas du marché",
      features: [
        "Devis & factures illimités",
        "Scan automatique illimité",
        "50 000 articles Point P & Cedeo",
        "50 devis types plomberie",
        "Gestion des chantiers",
        "Suivi de rentabilité",
        "Relances automatiques SMS/Email",
        "Export comptable",
        "Conforme facturation 2026",
        "Support prioritaire",
      ],
      cta: "Essai gratuit 14 jours (sans CB)",
      popular: true,
      gradient: "from-[#1976D2] to-[#1565C0]",
      badge: "LE - CHER",
    },
  ];

  return (
    <section id="pricing" className="py-20 bg-gradient-to-br from-gray-50 to-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center mb-12">
          <div className="inline-flex items-center bg-gradient-to-r from-[#FF6F00] to-[#E65100] text-white rounded-full px-6 py-2 font-bold text-sm mb-4">
            💰 LE PRIX LE PLUS BAS DU MARCHÉ
          </div>
          <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-3">
            19,90€/mois tout compris
          </h2>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto mb-4">
            Les autres logiciels : 40€ à 150€/mois. <strong>PlombiPro : moins cher, plus puissant.</strong>
          </p>
          <div className="inline-flex items-center bg-blue-50 rounded-full px-5 py-2 text-sm">
            <svg className="w-4 h-4 text-[#4CAF50] mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
            </svg>
            <span className="text-gray-700 font-medium">Annulez quand vous voulez • Résiliez en 2 clics</span>
          </div>
        </div>

        {/* Pricing Cards */}
        <div className="grid md:grid-cols-2 gap-8 max-w-5xl mx-auto">
          {plans.map((plan, index) => (
            <div
              key={index}
              className={`relative rounded-3xl bg-white overflow-hidden transition-all hover:shadow-2xl ${
                plan.popular
                  ? "border-4 border-[#FF6F00] shadow-xl transform md:scale-105"
                  : "border-2 border-gray-200 shadow-lg"
              }`}
            >
              {/* Popular Badge */}
              {plan.badge && (
                <div className="absolute top-0 right-0">
                  <div className="bg-gradient-to-r from-[#FF6F00] to-[#E65100] text-white px-6 py-2 rounded-bl-2xl font-semibold text-sm">
                    {plan.badge}
                  </div>
                </div>
              )}

              <div className="p-8">
                {/* Plan Header */}
                <div className="mb-8">
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">
                    {plan.name}
                  </h3>
                  <p className="text-gray-600 mb-6">{plan.description}</p>

                  {/* Price */}
                  <div className="flex items-baseline mb-2">
                    <span className="text-5xl font-bold text-gray-900">
                      {plan.price}€
                    </span>
                    <span className="text-gray-600 ml-2">/ {plan.period}</span>
                  </div>
                  {plan.originalPrice && (
                    <div className="flex items-center">
                      <span className="text-lg text-gray-400 line-through">
                        {plan.originalPrice}€/mois
                      </span>
                      <span className="ml-2 bg-[#4CAF50] text-white text-xs font-semibold px-2 py-1 rounded">
                        -50% pendant 6 mois
                      </span>
                    </div>
                  )}
                </div>

                {/* CTA Button */}
                <a
                  href="#"
                  className={`block w-full text-center px-8 py-4 rounded-xl font-semibold text-lg transition-all mb-8 ${
                    plan.popular
                      ? "bg-gradient-to-r from-[#FF6F00] to-[#E65100] text-white hover:shadow-xl transform hover:-translate-y-1"
                      : "bg-gray-900 text-white hover:bg-gray-800"
                  }`}
                >
                  {plan.cta}
                </a>

                {/* Features List */}
                <div className="space-y-4">
                  <p className="text-sm font-semibold text-gray-900 uppercase tracking-wide">
                    Inclus :
                  </p>
                  <ul className="space-y-3">
                    {plan.features.map((feature, featureIndex) => (
                      <li key={featureIndex} className="flex items-start">
                        <svg
                          className={`w-6 h-6 flex-shrink-0 mr-3 ${
                            plan.popular ? "text-[#FF6F00]" : "text-[#1976D2]"
                          }`}
                          fill="currentColor"
                          viewBox="0 0 20 20"
                        >
                          <path
                            fillRule="evenodd"
                            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                            clipRule="evenodd"
                          />
                        </svg>
                        <span className="text-gray-700">{feature}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Why So Cheap Section */}
        <div className="mt-16 max-w-3xl mx-auto">
          <div className="bg-gradient-to-br from-blue-50 to-white rounded-2xl p-8 md:p-10 border-2 border-blue-200">
            <h3 className="text-2xl md:text-3xl font-bold text-gray-900 mb-4 flex items-center">
              <span className="text-3xl mr-3">💡</span>
              Pourquoi seulement 9,90€ ?
            </h3>
            <p className="text-gray-700 leading-relaxed mb-4 text-lg">
              <strong>Pendant le lancement, on veut 1000 plombiers heureux, pas la rentabilité.</strong>
            </p>
            <p className="text-gray-700 leading-relaxed mb-4">
              Une fois qu'on aura prouvé que PlombiPro vous fait gagner 10h/semaine,
              le tarif normal sera 19,90€. Mais ceux qui s'inscrivent maintenant
              <strong className="text-orange-600"> gardent 9,90€ À VIE.</strong>
            </p>
            <div className="inline-flex items-center bg-orange-100 rounded-full px-6 py-3 border-2 border-orange-300 mb-4">
              <svg className="w-5 h-5 text-orange-600 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clipRule="evenodd" />
              </svg>
              <span className="text-orange-800 font-bold">
                Prix bloqué à vie pour les 1000 premiers
              </span>
            </div>
            <p className="text-sm text-gray-500">
              ⚡ 327 / 1000 places "Prix Fondateur" déjà prises
            </p>
          </div>
        </div>

        {/* FAQ/Guarantees Section */}
        <div className="mt-12 max-w-4xl mx-auto">
          <div className="bg-blue-50 rounded-2xl p-8 md:p-10">
            <h3 className="text-2xl font-bold text-gray-900 mb-6 text-center">
              Questions fréquentes
            </h3>
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <h4 className="font-semibold text-gray-900 mb-2 flex items-center">
                  <svg className="w-5 h-5 text-[#1976D2] mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z" clipRule="evenodd" />
                  </svg>
                  Puis-je changer de plan ?
                </h4>
                <p className="text-gray-600">
                  Oui, à tout moment. Passez de Gratuit à Pro en un clic. Résiliez quand vous voulez.
                </p>
              </div>
              <div>
                <h4 className="font-semibold text-gray-900 mb-2 flex items-center">
                  <svg className="w-5 h-5 text-[#1976D2] mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z" clipRule="evenodd" />
                  </svg>
                  Comment payer ?
                </h4>
                <p className="text-gray-600">
                  Carte bancaire sécurisée via Stripe (leader mondial des paiements). Pas de frais cachés, pas d'engagement. Résiliation en 2 clics.
                </p>
              </div>
              <div>
                <h4 className="font-semibold text-gray-900 mb-2 flex items-center">
                  <svg className="w-5 h-5 text-[#1976D2] mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z" clipRule="evenodd" />
                  </svg>
                  L'essai est-il vraiment gratuit ?
                </h4>
                <p className="text-gray-600">
                  Oui, 14 jours gratuits sans carte bancaire. Puis 9,90€/mois ou retour automatique au plan gratuit. Aucune CB requise pour tester.
                </p>
              </div>
              <div>
                <h4 className="font-semibold text-gray-900 mb-2 flex items-center">
                  <svg className="w-5 h-5 text-[#1976D2] mr-2" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z" clipRule="evenodd" />
                  </svg>
                  Mes données sont-elles sécurisées ?
                </h4>
                <p className="text-gray-600">
                  Hébergement en France, RGPD compliant, sauvegardes quotidiennes. Vos données vous appartiennent.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Money Back Guarantee */}
        <div className="mt-12 text-center">
          <div className="inline-flex items-center bg-[#4CAF50] text-white rounded-full px-6 py-3">
            <svg className="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
            <span className="font-semibold">
              Satisfait ou remboursé pendant 30 jours
            </span>
          </div>
        </div>
      </div>
    </section>
  );
}
