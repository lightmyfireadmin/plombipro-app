export default function ProblemSolution() {
  const problems = [
    {
      badge: "Fini les erreurs",
      color: "from-[#4CAF50] to-[#45A049]",
      textColor: "text-[#4CAF50]",
      borderColor: "border-[#4CAF50]",
      icon: "✓",
      problem: "Vous en avez assez des erreurs de calcul dans vos devis ?",
      solution: "L'application calcule automatiquement les montants, TVA, marges et remises. Fini les erreurs et les pertes de temps.",
    },
    {
      badge: "Gagnez du temps",
      color: "from-[#FF6F00] to-[#E65100]",
      textColor: "text-[#FF6F00]",
      borderColor: "border-[#FF6F00]",
      icon: "⏰",
      problem: "Trop de temps perdu à ressaisir vos achats fournisseurs ?",
      solution: "Photographiez n'importe quelle facture ou devis : les articles s'ajoutent automatiquement. 10 principaux fournisseurs intégrés. 2 minutes au lieu de 20.",
    },
    {
      badge: "Récupérez vos impayés",
      color: "from-[#FFC107] to-[#FFB300]",
      textColor: "text-[#FFC107]",
      borderColor: "border-[#FFC107]",
      icon: "💰",
      problem: "Des factures impayées qui s'accumulent ?",
      solution: "Relances automatiques par email et SMS selon votre planning. Tableau de bord des paiements en attente. L'application vous alerte et relance pour vous.",
    },
    {
      badge: "Conforme 2026",
      color: "from-[#2196F3] to-[#1976D2]",
      textColor: "text-[#2196F3]",
      borderColor: "border-[#2196F3]",
      icon: "🛡️",
      problem: "Inquiet face à la facturation électronique obligatoire ?",
      solution: "Factur-X intégré, Chorus Pro compatible. Prêt dès maintenant pour septembre 2026. Mises à jour automatiques incluses.",
    },
  ];

  return (
    <section className="py-12 sm:py-16 bg-gradient-to-br from-gray-50 to-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center mb-8 sm:mb-10">
          <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-3">
            Vos défis quotidiens
          </h2>
          <p className="text-base sm:text-lg text-gray-600 max-w-3xl mx-auto">
            Une application pensée pour répondre aux vrais besoins des plombiers.
          </p>
        </div>

        {/* Problem-Solution Grid */}
        <div className="grid md:grid-cols-2 gap-6 sm:gap-8">
          {problems.map((item, index) => (
            <div
              key={index}
              className="relative group"
            >
              <div className="bg-white rounded-2xl p-5 sm:p-6 border-2 hover:shadow-xl transition-all duration-300">
                {/* Badge */}
                <div className="mb-4">
                  <div className={`inline-flex items-center bg-gradient-to-r ${item.color} text-white rounded-full px-4 py-2 font-bold text-sm shadow-lg`}>
                    <span className="mr-1.5 text-lg">{item.icon}</span>
                    {item.badge}
                  </div>
                </div>

                {/* Problem */}
                <div className="mb-4">
                  <div className="flex items-start mb-2">
                    <div className="w-6 h-6 rounded-full bg-red-100 flex items-center justify-center mr-2 flex-shrink-0 mt-0.5">
                      <span className="text-red-600 font-bold text-sm">✗</span>
                    </div>
                    <h3 className="text-base font-bold text-gray-900">
                      {item.problem}
                    </h3>
                  </div>
                </div>

                {/* Solution */}
                <div className={`border-l-4 ${item.borderColor} pl-4 py-1`}>
                  <div className="flex items-start">
                    <div className={`w-6 h-6 rounded-full bg-gradient-to-br ${item.color} flex items-center justify-center mr-2 flex-shrink-0 mt-0.5`}>
                      <span className="text-white font-bold text-sm">✓</span>
                    </div>
                    <p className="text-sm sm:text-base text-gray-700 leading-relaxed">
                      <strong className={item.textColor}>Solution :</strong> {item.solution}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="mt-8 sm:mt-10 text-center">
          <p className="text-gray-600 mb-4 text-base sm:text-lg">
            Simplifiez votre quotidien dès aujourd'hui
          </p>
          <a
            href="#pricing"
            className="inline-block bg-gradient-to-r from-[#FF6F00] to-[#E65100] text-white px-8 py-4 rounded-xl font-bold text-lg hover:shadow-2xl transition-all"
          >
            Essayer gratuitement (sans CB)
          </a>
          <p className="text-gray-500 mt-3 text-xs sm:text-sm">
            14 jours d'essai offerts • Résiliation en 2 clics • Aucune CB requise
          </p>
        </div>
      </div>
    </section>
  );
}
