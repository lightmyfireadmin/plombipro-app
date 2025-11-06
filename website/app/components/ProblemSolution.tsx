export default function ProblemSolution() {
  const problems = [
    {
      badge: "Adieu Excel",
      color: "from-[#4CAF50] to-[#45A049]",
      textColor: "text-[#4CAF50]",
      borderColor: "border-[#4CAF50]",
      icon: "✓",
      problem: "Vous perdez du temps avec Excel et les erreurs de calcul ?",
      solution: "PlombiPro calcule automatiquement vos devis avec les bons taux de TVA, marges et remises. Zéro erreur, gain de temps immédiat.",
    },
    {
      badge: "Ne passez plus vos soirées",
      color: "from-[#FF6F00] to-[#E65100]",
      textColor: "text-[#FF6F00]",
      borderColor: "border-[#FF6F00]",
      icon: "⏰",
      problem: "Vous passez vos soirées à faire de la paperasse ?",
      solution: "Scanner OCR intelligent : photographiez vos factures fournisseurs et vos articles sont automatiquement ajoutés à votre devis. 2 minutes au lieu de 20.",
    },
    {
      badge: "Ne perdez plus 1€",
      color: "from-[#FFC107] to-[#FFB300]",
      textColor: "text-[#FFC107]",
      borderColor: "border-[#FFC107]",
      icon: "💰",
      problem: "Vous avez des impayés qui traînent ?",
      solution: "Relances automatiques par email et SMS. Suivi des paiements en temps réel. PlombiPro vous alerte et relance vos clients pour vous.",
    },
    {
      badge: "Toujours conforme",
      color: "from-[#2196F3] to-[#1976D2]",
      textColor: "text-[#2196F3]",
      borderColor: "border-[#2196F3]",
      icon: "🛡️",
      problem: "Vous avez peur de ne pas être conforme en 2026 ?",
      solution: "Factur-X intégré, Chorus Pro compatible, prêt pour la facturation électronique obligatoire. Mises à jour automatiques selon les nouvelles réglementations.",
    },
  ];

  return (
    <section className="py-20 bg-gradient-to-br from-gray-50 to-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            Vous reconnaissez-vous ?
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            PlombiPro résout les problèmes quotidiens des plombiers. Voici comment.
          </p>
        </div>

        {/* Problem-Solution Grid */}
        <div className="grid md:grid-cols-2 gap-8 lg:gap-12">
          {problems.map((item, index) => (
            <div
              key={index}
              className="relative group"
            >
              <div className="bg-white rounded-3xl p-8 border-2 hover:shadow-2xl transition-all duration-300 hover:-translate-y-2">
                {/* Badge */}
                <div className="mb-6">
                  <div className={`inline-flex items-center bg-gradient-to-r ${item.color} text-white rounded-full px-6 py-3 font-bold text-lg shadow-lg`}>
                    <span className="mr-2 text-2xl">{item.icon}</span>
                    {item.badge}
                  </div>
                </div>

                {/* Problem */}
                <div className="mb-6">
                  <div className="flex items-start mb-3">
                    <div className="w-8 h-8 rounded-full bg-red-100 flex items-center justify-center mr-3 flex-shrink-0 mt-1">
                      <span className="text-red-600 font-bold text-lg">✗</span>
                    </div>
                    <h3 className="text-lg font-bold text-gray-900">
                      {item.problem}
                    </h3>
                  </div>
                </div>

                {/* Solution */}
                <div className={`border-l-4 ${item.borderColor} pl-6 py-2`}>
                  <div className="flex items-start">
                    <div className={`w-8 h-8 rounded-full bg-gradient-to-br ${item.color} flex items-center justify-center mr-3 flex-shrink-0 mt-1`}>
                      <span className="text-white font-bold text-lg">✓</span>
                    </div>
                    <p className="text-gray-700 leading-relaxed">
                      <strong className={item.textColor}>Solution :</strong> {item.solution}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="mt-16 text-center">
          <p className="text-gray-600 mb-6 text-lg">
            Prêt à dire adieu à ces problèmes ?
          </p>
          <a
            href="#pricing"
            className="inline-block bg-gradient-to-r from-[#FF6F00] to-[#E65100] text-white px-10 py-5 rounded-xl font-bold text-xl hover:shadow-2xl transition-all transform hover:-translate-y-1"
          >
            Essayer gratuitement pendant 14 jours
          </a>
          <p className="text-gray-500 mt-4 text-sm">
            Sans carte bancaire • 5 devis offerts • Résiliation en 2 clics
          </p>
        </div>
      </div>
    </section>
  );
}
