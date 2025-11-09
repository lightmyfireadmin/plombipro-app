export default function Comparison() {
  const comparisons = [
    {
      category: "Les logiciels génériques",
      description: "Pour tous les secteurs d'activité",
      icon: "📄",
      limitations: [
        "Pas de scan automatique des factures et devis",
        "Pas de catalogues fournisseurs intégrés",
        "Devis générique pour tous les métiers",
        "Pas de calculateurs plomberie",
        "Aucune spécialisation pour votre métier",
      ],
      plombiProSolution: "PlombiPro est la SEULE application conçue à 100% pour les plombiers : scan automatique universel + catalogues des 10 principaux fournisseurs",
    },
    {
      category: "Les ERP BTP complets",
      description: "Solutions tout-en-un pour grandes entreprises",
      icon: "🏗️",
      limitations: [
        "Prix: 50-150€/mois (trop cher pour solo)",
        "Complexité: courbe d'apprentissage importante",
        "Fonctionnalités inutiles pour plombiers",
        "Cible: entreprises 10-100 personnes",
        "Pas de focus plomberie spécifique",
      ],
      plombiProSolution: "PlombiPro reste simple, abordable (19,90€) et 100% focus plomberie",
    },
    {
      category: "Les plateformes de formulaires",
      description: "Outils de gestion de chantier généralistes",
      icon: "📋",
      limitations: [
        "Focus: gestion de chantier et formulaires",
        "Pas conçu pour facturation",
        "Prix: 40-80€/mois + par utilisateur",
        "Il faut créer ses formulaires soi-même",
        "Pas de catalogues fournisseurs",
      ],
      plombiProSolution: "PlombiPro est une application de facturation prête à l'emploi avec 50 devis types plomberie pré-remplis",
    },
    {
      category: "Les outils BTP basiques",
      description: "Solutions construction non spécialisées",
      icon: "🔧",
      limitations: [
        "BTP générique (pas exclusif plombiers)",
        "Pas de scan automatique des factures et devis",
        "Pas de catalogues fournisseurs",
        "Prix cachés ou non affichés",
        "Pas d'innovation sur le gain de temps",
      ],
      plombiProSolution: "PlombiPro est exclusif plombiers, avec scan automatique universel + catalogues intégrés. Tarif transparent : 19,90€/mois tout compris",
    },
  ];

  const plombiProAdvantages = [
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
        </svg>
      ),
      title: "Scan automatique universel",
      description: "Scannez n'importe quelle facture ou devis : extraction automatique des articles, quantités et prix. Économisez 15 min par devis.",
      badge: "Exclusif",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
        </svg>
      ),
      title: "Catalogues 10 Fournisseurs",
      description: "50 000+ articles des 10 principaux fournisseurs (Point P, Cedeo, Leroy Merlin...) avec prix à jour. Personne d'autre ne l'a.",
      badge: "Exclusif",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
        </svg>
      ),
      title: "Calculateur Hydraulique",
      description: "Dimensionnement tuyaux, pression, débit. Outil technique que PERSONNE n'a.",
      badge: "Exclusif",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      title: "Mode Urgence Auto",
      description: "Coefficients nuit/weekend automatiques. Les autres: calcul manuel uniquement.",
      badge: "Unique",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      title: "Prix Transparent",
      description: "19,90€/mois affiché clairement. Les ERP: prix cachés derrière contact commercial.",
      badge: "Honnête",
    },
    {
      icon: (
        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
      ),
      title: "Simplicité Radicale",
      description: "Créez votre 1er devis en 15 min. Les ERP complexes: plusieurs jours de formation.",
      badge: "Simple",
    },
  ];

  return (
    <section className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center bg-orange-50 rounded-full px-4 py-2 mb-4">
            <svg
              className="w-5 h-5 text-[#FF6F00] mr-2"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fillRule="evenodd"
                d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clipRule="evenodd"
              />
            </svg>
            <span className="text-sm font-semibold text-gray-700">
              Comparaison Honnête
            </span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            Pourquoi PlombiPro vs. les autres ?
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            On ne critique personne. On explique juste pourquoi PlombiPro est{" "}
            <strong>fait UNIQUEMENT pour les plombiers</strong>.
          </p>
        </div>

        {/* Comparison Grid */}
        <div className="grid md:grid-cols-2 gap-8 mb-16">
          {comparisons.map((item, index) => (
            <div
              key={index}
              className="bg-gradient-to-br from-gray-50 to-white rounded-2xl p-8 border-2 border-gray-200 hover:border-[#1976D2] hover:shadow-xl transition-all"
            >
              {/* Category Header */}
              <div className="flex items-center mb-6">
                <div className="text-5xl mr-4">{item.icon}</div>
                <div>
                  <h3 className="text-xl font-bold text-gray-900">
                    {item.category}
                  </h3>
                  <p className="text-sm text-gray-500 italic">
                    {item.description}
                  </p>
                </div>
              </div>

              {/* Limitations */}
              <div className="mb-6">
                <p className="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-3">
                  Limites typiques :
                </p>
                <ul className="space-y-2">
                  {item.limitations.map((limitation, idx) => (
                    <li key={idx} className="flex items-start text-sm">
                      <svg
                        className="w-5 h-5 text-gray-400 mr-2 flex-shrink-0 mt-0.5"
                        fill="currentColor"
                        viewBox="0 0 20 20"
                      >
                        <path
                          fillRule="evenodd"
                          d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                          clipRule="evenodd"
                        />
                      </svg>
                      <span className="text-gray-600">{limitation}</span>
                    </li>
                  ))}
                </ul>
              </div>

              {/* PlombiPro Solution */}
              <div className="bg-blue-50 border-l-4 border-[#1976D2] rounded-lg p-4">
                <div className="flex items-start">
                  <svg
                    className="w-6 h-6 text-[#1976D2] mr-3 flex-shrink-0"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <div>
                    <p className="font-semibold text-[#1976D2] text-sm mb-1">
                      Différence PlombiPro :
                    </p>
                    <p className="text-gray-700 text-sm leading-relaxed">
                      {item.plombiProSolution}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* PlombiPro Unique Advantages */}
        <div className="bg-gradient-to-br from-blue-50 to-white rounded-3xl p-10 border-2 border-blue-200">
          <div className="text-center mb-10">
            <h3 className="text-3xl font-bold text-gray-900 mb-3">
              Les 6 avantages que SEUL PlombiPro offre
            </h3>
            <p className="text-gray-600">
              Fonctionnalités qu'aucun autre logiciel ne propose
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {plombiProAdvantages.map((advantage, index) => (
              <div
                key={index}
                className="bg-white rounded-xl p-6 border-2 border-gray-200 hover:border-[#FF6F00] hover:shadow-lg transition-all group"
              >
                {/* Badge */}
                <div className="flex items-center justify-between mb-4">
                  <div className="w-12 h-12 bg-gradient-to-br from-[#1976D2] to-[#1565C0] rounded-lg flex items-center justify-center text-white group-hover:from-[#FF6F00] group-hover:to-[#E65100] transition-all">
                    {advantage.icon}
                  </div>
                  <span className="bg-[#FF6F00] text-white text-xs font-bold px-3 py-1 rounded-full">
                    {advantage.badge}
                  </span>
                </div>

                {/* Content */}
                <h4 className="font-bold text-gray-900 mb-2">
                  {advantage.title}
                </h4>
                <p className="text-sm text-gray-600 leading-relaxed">
                  {advantage.description}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Bottom Summary */}
        <div className="mt-8 sm:mt-16 text-center">
          <div className="bg-gradient-to-r from-[#FF6F00] to-[#E65100] rounded-2xl p-10 text-white">
            <h3 className="text-3xl font-bold mb-4">
              Résumé : PlombiPro c'est quoi ?
            </h3>
            <p className="text-xl mb-6 leading-relaxed">
              La <strong>seule application conçue à 100% pour les plombiers</strong>
              ,<br />
              avec scan automatique universel et catalogues des 10 principaux fournisseurs,
              <br />
              au <strong>prix le plus juste</strong> (19,90€ au lieu de 50-150€),
              <br />
              conforme <strong>Factur-X 2026</strong> et <strong>sans superflu</strong>.
            </p>
            <a
              href="#pricing"
              className="inline-block bg-white text-[#FF6F00] px-10 py-4 rounded-xl font-bold text-lg hover:shadow-2xl transition-all transform hover:-translate-y-1"
            >
              Essayer gratuitement (sans CB)
            </a>
            <p className="mt-4 text-sm text-orange-100">
              14 jours gratuits • 5 devis offerts à vie • Résiliation en 2 clics
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
