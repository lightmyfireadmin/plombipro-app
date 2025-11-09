export default function Features() {
  const features = [
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
      ),
      title: "Scan Universel → Devis en 2 min",
      description: "Photographiez n'importe quel document (factures fournisseurs, devis, bons de livraison, récapitulatifs...). Extraction automatique complète des articles, quantités et prix. Gérez votre comptabilité, suivez vos marges, CA et taxes en temps réel. ⏱️ Gain : 15 min par devis = 25h/mois.",
      badge: "Exclusif",
      badgeColor: "bg-[#FF6F00]",
      highlight: true,
      timeSaved: "15 min/devis",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
        </svg>
      ),
      title: "Catalogues 10 Fournisseurs",
      description: "50 000+ articles des principaux fournisseurs (Point P, Cedeo, Leroy Merlin, Manomano, Castorama, Waterout, Distriartisan, SIDER, Legallais, Domomat). Prix à jour automatiquement : radiateurs, PER, raccords, robinetterie... ⏱️ Gain : 10 min par recherche.",
      badge: "Exclusif",
      badgeColor: "bg-[#FF6F00]",
      highlight: true,
      timeSaved: "10 min/recherche",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 10h10M7 14h10" />
        </svg>
      ),
      title: "50 devis types plomberie",
      description: "Chauffe-eau, fuite, rénovation salle de bain, installation chaudière... tous les chantiers courants sont pré-remplis avec les prix 2025. Personnalisez en 2 clics et c'est prêt.",
      badge: "Exclusif",
      badgeColor: "bg-[#FF6F00]",
      highlight: true,
      timeSaved: "20 min/devis",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
      ),
      title: "GPS Automatique + Planning Intelligent",
      description: "Vos RDV du jour s'organisent automatiquement par GPS. Itinéraire optimisé, navigation directe, messages clients automatiques (\"J'arrive dans 15 min\"). Gérez vos employés, évitez les retards, planifiez les dépenses. ⏱️ Gain : 1h/jour de trajets.",
      badge: "Nouveau",
      badgeColor: "bg-[#4CAF50]",
      highlight: true,
      timeSaved: "1h/jour trajets",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      title: "Mode Urgence",
      description: "Dépannage en pleine nuit ou week-end ? Le coefficient d'urgence (×1.5 à ×2.5) s'applique automatiquement selon l'heure et le jour. Ne perdez plus d'argent sur les dépannages.",
      badge: "Nouveau",
      badgeColor: "bg-[#FFC107]",
      highlight: false,
      timeSaved: "+18% CA urgences",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
        </svg>
      ),
      title: "Gestion de Chantiers",
      description: "Suivez tous vos chantiers en un coup d'œil. Achats, main d'œuvre, rentabilité réelle. Identifiez les chantiers qui perdent de l'argent avant qu'il soit trop tard.",
      badge: null,
      badgeColor: "",
      highlight: false,
      timeSaved: "2h/semaine",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      title: "Suivi Impayés",
      description: "Relances automatiques par email et SMS selon un planning personnalisable. Tableau de bord des paiements en attente. Nos clients récupèrent en moyenne 8 000€/an d'impayés.",
      badge: null,
      badgeColor: "",
      highlight: false,
      timeSaved: "1h/semaine",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
        </svg>
      ),
      title: "Conforme 2026 DÈS MAINTENANT",
      description: "Format Factur-X natif, export Chorus Pro pour les chantiers publics. Évitez les amendes de 15€ par facture non conforme. Mises à jour réglementaires automatiques incluses.",
      badge: "Obligatoire",
      badgeColor: "bg-[#4CAF50]",
      highlight: false,
      timeSaved: "Évite amendes",
    },
  ];

  return (
    <section id="features" className="py-20 bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            Tout ce qui vous fait VRAIMENT gagner du temps
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto mb-4">
            Des fonctionnalités pensées <strong>spécialement pour les plombiers</strong>.
            Pas de superflu, que de l'essentiel pour gagner du temps et de l'argent.
          </p>
          <p className="text-sm text-gray-500">
            Les fonctionnalités que les autres logiciels n'ont pas.
          </p>
        </div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <div
              key={index}
              className={`relative bg-white rounded-2xl p-8 transition-all hover:shadow-xl ${
                feature.highlight
                  ? "border-2 border-[#FF6F00] shadow-lg"
                  : "border border-gray-200"
              }`}
            >
              {/* Badge */}
              {feature.badge && (
                <div className="absolute top-4 right-4">
                  <span
                    className={`${feature.badgeColor} text-white text-xs font-semibold px-3 py-1 rounded-full`}
                  >
                    {feature.badge}
                  </span>
                </div>
              )}

              {/* Icon */}
              <div
                className={`inline-flex items-center justify-center w-16 h-16 rounded-xl mb-6 ${
                  feature.highlight
                    ? "bg-gradient-to-br from-[#FF6F00] to-[#E65100] text-white"
                    : "bg-[#1976D2] text-white"
                }`}
              >
                {feature.icon}
              </div>

              {/* Content */}
              <h3 className="text-xl font-bold text-gray-900 mb-3">
                {feature.title}
              </h3>
              <p className="text-gray-600 leading-relaxed">
                {feature.description}
              </p>

              {/* GPS Animation - Only for GPS feature */}
              {feature.title === "GPS Automatique + Planning Intelligent" && (
                <div className="mt-6 bg-gradient-to-br from-blue-50 to-green-50 rounded-xl p-4 border-2 border-green-200">
                  <div className="relative h-40">
                    {/* Map Background */}
                    <div className="absolute inset-0 bg-gradient-to-br from-gray-100 to-gray-200 rounded-lg opacity-50">
                      <div className="grid grid-cols-4 grid-rows-4 h-full">
                        {[...Array(16)].map((_, i) => (
                          <div key={i} className="border border-gray-300/30"></div>
                        ))}
                      </div>
                    </div>

                    {/* Route Line */}
                    <svg className="absolute inset-0 w-full h-full" viewBox="0 0 200 160">
                      <path
                        d="M 30,80 Q 60,30 100,60 T 170,80"
                        stroke="#4CAF50"
                        strokeWidth="3"
                        fill="none"
                        strokeDasharray="5,5"
                        className="animate-pulse"
                      />
                    </svg>

                    {/* Location Pins */}
                    <div className="absolute top-16 left-6 animate-bounce">
                      <div className="relative">
                        <svg className="w-8 h-8 text-[#FF6F00]" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                        </svg>
                        <div className="absolute -bottom-6 left-1/2 transform -translate-x-1/2 bg-white px-2 py-1 rounded shadow-md whitespace-nowrap text-xs font-bold">
                          RDV 1
                        </div>
                      </div>
                    </div>

                    <div className="absolute top-8 right-6 animate-bounce animation-delay-200">
                      <div className="relative">
                        <svg className="w-8 h-8 text-[#4CAF50]" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                        </svg>
                        <div className="absolute -bottom-6 left-1/2 transform -translate-x-1/2 bg-white px-2 py-1 rounded shadow-md whitespace-nowrap text-xs font-bold">
                          RDV 2
                        </div>
                      </div>
                    </div>

                    {/* Moving Van */}
                    <div className="absolute top-20 left-20 animate-pulse-slow">
                      <svg className="w-10 h-10 text-[#1976D2]" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M18 18.5a1.5 1.5 0 01-1.5-1.5 1.5 1.5 0 011.5-1.5 1.5 1.5 0 011.5 1.5 1.5 1.5 0 01-1.5 1.5m1.5-9l1.96 2.5H17V9.5M6 18.5A1.5 1.5 0 014.5 17 1.5 1.5 0 016 15.5 1.5 1.5 0 017.5 17 1.5 1.5 0 016 18.5M20 8h-3V4H3c-1.11 0-2 .89-2 2v11h2a3 3 0 003 3 3 3 0 003-3h6a3 3 0 003 3 3 3 0 003-3h2v-5l-3-4z"/>
                      </svg>
                    </div>
                  </div>

                  <div className="mt-3 flex items-center justify-center gap-2 text-xs text-green-700">
                    <svg className="w-4 h-4 animate-spin-slow" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span className="font-semibold">Itinéraire optimisé automatiquement</span>
                  </div>
                </div>
              )}

              {/* Time saved indicator */}
              {feature.timeSaved && (
                <div className="mt-6 inline-flex items-center bg-blue-50 rounded-full px-4 py-2">
                  <svg className="w-4 h-4 mr-2 text-[#1976D2]" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clipRule="evenodd" />
                  </svg>
                  <span className="text-[#1976D2] font-semibold text-sm">
                    {feature.timeSaved}
                  </span>
                </div>
              )}

              {/* Highlight indicator */}
              {feature.highlight && (
                <div className="mt-4 flex items-center text-[#FF6F00] font-medium text-sm">
                  <svg
                    className="w-5 h-5 mr-2"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                  Fonctionnalité unique
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="mt-16 text-center">
          <div className="inline-flex items-center bg-blue-50 rounded-full px-6 py-3 mb-6">
            <svg
              className="w-5 h-5 text-[#1976D2] mr-2"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fillRule="evenodd"
                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
                clipRule="evenodd"
              />
            </svg>
            <span className="text-sm font-medium text-gray-700">
              Toutes les fonctionnalités disponibles dès l'offre gratuite
            </span>
          </div>
        </div>
      </div>
    </section>
  );
}
