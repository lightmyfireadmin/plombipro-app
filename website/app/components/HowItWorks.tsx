export default function HowItWorks() {
  const steps = [
    {
      number: "01",
      title: "Photographiez n'importe quel document",
      description: "Factures fournisseurs, devis, bons de livraison, récapitulatifs... Le scan universel extrait automatiquement tous les articles, quantités et prix. Compatible avec les 10 principaux fournisseurs.",
      icon: (
        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
      ),
    },
    {
      number: "02",
      title: "Ajoutez votre marge",
      description: "PlombiPro calcule automatiquement vos marges. Ajustez en un clic selon le type de chantier. Votre prix de vente est calculé instantanément.",
      icon: (
        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
        </svg>
      ),
    },
    {
      number: "03",
      title: "Générez le devis",
      description: "Un devis professionnel avec votre logo est créé en PDF. Envoyez-le par email ou SMS directement depuis l'app. Le client peut accepter en ligne.",
      icon: (
        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
      ),
    },
    {
      number: "04",
      title: "Transformez en facture",
      description: "Devis accepté ? Convertissez-le en facture conforme 2026 en 1 clic. Envoi automatique, relances si besoin. C'est fait.",
      icon: (
        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
    },
  ];

  return (
    <section id="how-it-works" className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            Comment ça marche ?
          </h2>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            De la facture fournisseur à la facture client en 4 étapes simples
          </p>
        </div>

        {/* Steps */}
        <div className="relative">
          {/* Connection Line - Desktop only */}
          <div className="hidden lg:block absolute top-1/2 left-0 right-0 h-0.5 bg-gradient-to-r from-[#1976D2] via-[#64B5F6] to-[#FF6F00] transform -translate-y-1/2"
               style={{ top: "120px" }}
          />

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-4 relative">
            {steps.map((step, index) => (
              <div key={index} className="relative">
                {/* Step Card */}
                <div className="bg-white rounded-2xl p-6 shadow-lg border border-gray-200 hover:shadow-xl transition-all hover:-translate-y-2 relative z-10">
                  {/* Step Number */}
                  <div className="flex items-center justify-between mb-4">
                    <span className="text-5xl font-bold text-[#1976D2] opacity-20">
                      {step.number}
                    </span>
                    <div className="bg-gradient-to-br from-[#1976D2] to-[#64B5F6] rounded-xl p-3 text-white">
                      {step.icon}
                    </div>
                  </div>

                  {/* Content */}
                  <h3 className="text-xl font-bold text-gray-900 mb-3">
                    {step.title}
                  </h3>
                  <p className="text-gray-600 leading-relaxed">
                    {step.description}
                  </p>
                </div>

                {/* Arrow - Mobile only */}
                {index < steps.length - 1 && (
                  <div className="lg:hidden flex justify-center my-4">
                    <svg className="w-6 h-6 text-[#1976D2]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                    </svg>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Time Saved Banner */}
        <div className="mt-16 bg-gradient-to-r from-[#1976D2] to-[#1565C0] rounded-2xl p-8 md:p-12 text-white text-center">
          <div className="max-w-3xl mx-auto">
            <div className="inline-flex items-center bg-white/10 backdrop-blur-sm rounded-full px-4 py-2 mb-4">
              <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clipRule="evenodd" />
              </svg>
              <span className="text-sm font-medium">Gain de temps</span>
            </div>
            <h3 className="text-3xl md:text-4xl font-bold mb-4">
              Économisez 10 heures par semaine
            </h3>
            <p className="text-xl text-blue-100 mb-8">
              Moins de paperasse, plus de temps pour vos chantiers. C'est ça la vraie rentabilité.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <a
                href="#"
                className="bg-[#FF6F00] text-white px-8 py-4 rounded-lg font-semibold hover:bg-[#E65100] transition-all shadow-xl"
              >
                Essayer gratuitement (sans CB)
              </a>
              <a
                href="#pricing"
                className="bg-white/10 backdrop-blur-sm text-white border-2 border-white/30 px-8 py-4 rounded-lg font-semibold hover:bg-white/20 transition-all"
              >
                Voir les tarifs
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
