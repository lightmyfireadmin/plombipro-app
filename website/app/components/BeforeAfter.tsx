export default function BeforeAfter() {
  const comparisons = [
    {
      task: "Créer un devis",
      before: "45 min (Excel + calculette)",
      after: "2 min (photo + clic)",
      highlight: true,
    },
    {
      task: "Chercher prix fournisseurs",
      before: "15 min (catalogues papier)",
      after: "10 sec (10 catalogues intégrés)",
      highlight: false,
    },
    {
      task: "Ressaisir documents fournisseurs",
      before: "20 min de saisie manuelle",
      after: "30 sec (scan universel)",
      highlight: false,
    },
    {
      task: "Relancer impayés",
      before: "2h/semaine (manuel)",
      after: "0 min (automatique)",
      highlight: false,
    },
    {
      task: "Conformité 2026",
      before: "Stress + amendes ? 😰",
      after: "Factur-X inclus ✅",
      highlight: false,
    },
  ];

  return (
    <section className="py-20 bg-white">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            Sans PlombiPro vs Avec PlombiPro
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            La différence est énorme. Jugez par vous-même.
          </p>
        </div>

        {/* Comparison Table */}
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr className="bg-gradient-to-r from-gray-100 to-gray-50">
                <th className="p-4 md:p-6 text-left font-bold text-lg text-gray-900 border-b-2 border-gray-300">
                  Tâche quotidienne
                </th>
                <th className="p-4 md:p-6 text-center font-bold text-lg text-red-600 border-b-2 border-gray-300">
                  <div className="flex items-center justify-center space-x-2">
                    <span className="text-2xl">❌</span>
                    <span>Sans PlombiPro</span>
                  </div>
                </th>
                <th className="p-4 md:p-6 text-center font-bold text-lg text-green-600 border-b-2 border-gray-300">
                  <div className="flex items-center justify-center space-x-2">
                    <span className="text-2xl">✅</span>
                    <span>Avec PlombiPro</span>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              {comparisons.map((item, index) => (
                <tr
                  key={index}
                  className={`${
                    index % 2 === 0 ? "bg-white" : "bg-gray-50"
                  } ${
                    item.highlight ? "border-l-4 border-orange-500" : ""
                  } hover:bg-blue-50 transition-colors`}
                >
                  <td className="p-4 md:p-6 font-semibold text-gray-900 border-b border-gray-200">
                    {item.task}
                  </td>
                  <td className="p-4 md:p-6 text-center text-gray-700 border-b border-gray-200">
                    {item.before}
                  </td>
                  <td className="p-4 md:p-6 text-center font-bold text-green-700 border-b border-gray-200">
                    {item.after}
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr className="bg-gradient-to-r from-blue-50 to-blue-100 font-bold">
                <td className="p-6 text-lg text-gray-900 border-t-2 border-gray-300">
                  TOTAL TEMPS/SEMAINE
                </td>
                <td className="p-6 text-center text-lg text-red-600 border-t-2 border-gray-300">
                  ~20h gaspillées
                </td>
                <td className="p-6 text-center text-lg text-green-600 border-t-2 border-gray-300">
                  <div className="flex flex-col items-center">
                    <span className="text-2xl font-bold">10h gagnées</span>
                    <span className="text-sm text-gray-600 mt-1">
                      = 500€+ en plus par semaine
                    </span>
                  </div>
                </td>
              </tr>
            </tfoot>
          </table>
        </div>

        {/* Bottom explanation */}
        <div className="mt-12 bg-gradient-to-br from-orange-50 to-white rounded-2xl p-8 border-2 border-orange-200">
          <div className="flex items-start space-x-4">
            <div className="flex-shrink-0">
              <svg
                className="w-12 h-12 text-orange-500"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" />
              </svg>
            </div>
            <div>
              <h3 className="text-2xl font-bold text-gray-900 mb-3">
                10 heures par semaine, c'est quoi concrètement ?
              </h3>
              <ul className="space-y-2 text-gray-700">
                <li className="flex items-start">
                  <span className="text-orange-500 mr-2 font-bold">•</span>
                  <span>
                    <strong>2 chantiers en plus</strong> par semaine à 50€/h = +500€ de CA
                  </span>
                </li>
                <li className="flex items-start">
                  <span className="text-orange-500 mr-2 font-bold">•</span>
                  <span>
                    <strong>26 000€ par an</strong> de chiffre d'affaires supplémentaire
                  </span>
                </li>
                <li className="flex items-start">
                  <span className="text-orange-500 mr-2 font-bold">•</span>
                  <span>
                    Ou simplement <strong>rentrer chez vous plus tôt</strong> et profiter de votre famille
                  </span>
                </li>
              </ul>
            </div>
          </div>
        </div>

        {/* CTA */}
        <div className="mt-12 text-center">
          <a
            href="#pricing"
            className="inline-block bg-gradient-to-r from-[#FF6F00] to-[#E65100] text-white px-10 py-5 rounded-xl font-bold text-xl hover:shadow-2xl transition-all transform hover:-translate-y-1"
          >
            Je veux gagner 10h par semaine
          </a>
          <p className="text-gray-500 mt-4 text-sm">
            Sans carte bancaire • 5 devis offerts • Résiliation en 2 clics
          </p>
        </div>
      </div>
    </section>
  );
}
