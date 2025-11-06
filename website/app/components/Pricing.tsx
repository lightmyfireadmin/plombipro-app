export default function Pricing() {
  const plans = [
    {
      name: "Gratuit",
      price: "0",
      period: "pour toujours",
      description: "Pour tester PlombiPro sans engagement",
      features: [
        "5 devis par mois",
        "5 factures par mois",
        "Scanner OCR illimité",
        "Catalogues Point P & Cedeo",
        "Gestion des clients",
        "Application mobile iOS/Android",
        "Support par email",
      ],
      cta: "Commencer gratuitement",
      popular: false,
      gradient: "from-gray-700 to-gray-900",
    },
    {
      name: "Pro",
      price: "9,90",
      originalPrice: "19,90",
      period: "par mois",
      description: "L'offre complète pour les pros (offre de lancement)",
      features: [
        "Devis & factures illimités",
        "Scanner OCR illimité",
        "Catalogues Point P & Cedeo",
        "Gestion des chantiers",
        "Suivi de rentabilité",
        "Relances automatiques",
        "Export comptable",
        "Factur-X & Chorus Pro",
        "Support prioritaire",
        "Personnalisation avancée",
      ],
      cta: "Essai gratuit 14 jours",
      popular: true,
      gradient: "from-[#1976D2] to-[#1565C0]",
      badge: "Offre de lancement",
    },
  ];

  return (
    <section id="pricing" className="py-20 bg-gradient-to-br from-gray-50 to-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            Tarifs simples et transparents
          </h2>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Commencez gratuitement. Passez en Pro quand vous êtes prêt.
          </p>
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

        {/* FAQ/Guarantees Section */}
        <div className="mt-16 max-w-4xl mx-auto">
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
                  Carte bancaire sécurisée via Stripe. Pas de frais cachés. Résiliation en 2 clics.
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
                  Oui, 14 jours gratuits sans CB. Puis 9,90€/mois ou retour au plan gratuit.
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
