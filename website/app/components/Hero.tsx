import Link from "next/link";

export default function Hero() {
  return (
    <section className="relative bg-gradient-to-br from-[#1976D2] to-[#1565C0] text-white pt-32 pb-20 overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute inset-0" style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
        }} />
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left Column - Text Content */}
          <div className="text-center lg:text-left">
            <div className="inline-flex items-center bg-white/10 backdrop-blur-sm rounded-full px-4 py-2 mb-6">
              <span className="inline-block w-2 h-2 bg-[#4CAF50] rounded-full mr-2 animate-pulse"></span>
              <span className="text-sm font-medium">Offre de lancement : -50% pendant 6 mois</span>
            </div>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold leading-tight mb-6">
              Créez vos devis plomberie{" "}
              <span className="bg-gradient-to-r from-[#FF6F00] to-[#FFC107] bg-clip-text text-transparent">
                en 2 minutes
              </span>
              , pas de calculs, 100% conforme
            </h1>

            <p className="text-xl text-blue-100 mb-8 leading-relaxed">
              <strong>Le seul logiciel pensé 100% pour les plombiers.</strong> Scanner OCR, catalogues Point P & Cedeo intégrés.
              Rejoignez les 500+ plombiers qui gagnent 10h par semaine.
            </p>

            {/* Key Benefits */}
            <div className="flex flex-col sm:flex-row gap-4 mb-8 text-left">
              <div className="flex items-start space-x-2">
                <svg className="w-6 h-6 text-[#4CAF50] flex-shrink-0 mt-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                </svg>
                <span>Scanner OCR inclus</span>
              </div>
              <div className="flex items-start space-x-2">
                <svg className="w-6 h-6 text-[#4CAF50] flex-shrink-0 mt-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                </svg>
                <span>Conforme 2026</span>
              </div>
              <div className="flex items-start space-x-2">
                <svg className="w-6 h-6 text-[#4CAF50] flex-shrink-0 mt-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                </svg>
                <span>5 devis gratuits</span>
              </div>
            </div>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
              <Link
                href="#"
                className="bg-[#FF6F00] text-white px-8 py-4 rounded-lg font-semibold text-lg hover:bg-[#E65100] transition-all shadow-xl hover:shadow-2xl transform hover:-translate-y-0.5"
              >
                Essayer gratuitement
              </Link>
              <Link
                href="#how-it-works"
                className="bg-white/10 backdrop-blur-sm text-white border-2 border-white/30 px-8 py-4 rounded-lg font-semibold text-lg hover:bg-white/20 transition-all"
              >
                Voir la démo
              </Link>
            </div>

            {/* Trust Indicators */}
            <div className="mt-8 pt-8 border-t border-white/20">
              <p className="text-sm text-blue-100 mb-3">Ils nous font confiance</p>
              <div className="flex flex-wrap items-center justify-center lg:justify-start gap-4 lg:gap-6 text-blue-100">
                <div className="flex items-center space-x-2">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                  <span className="font-medium">4.8/5 (247 avis)</span>
                </div>
                <div className="hidden sm:block text-2xl text-white/30">•</div>
                <div>
                  <span className="font-medium">500+ plombiers actifs</span>
                </div>
                <div className="hidden sm:block text-2xl text-white/30">•</div>
                <div>
                  <span className="font-medium">15 000+ devis créés</span>
                </div>
              </div>
            </div>
          </div>

          {/* Right Column - App Mockup Placeholder */}
          <div className="hidden lg:block relative">
            <div className="relative">
              {/* Floating Card 1 */}
              <div className="absolute top-0 right-0 bg-white rounded-lg shadow-2xl p-4 w-64 transform rotate-3 hover:rotate-0 transition-transform">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium text-gray-600">Devis #2847</span>
                  <span className="bg-[#4CAF50] text-white text-xs px-2 py-1 rounded">Accepté</span>
                </div>
                <p className="text-2xl font-bold text-gray-900">4 280 €</p>
                <p className="text-sm text-gray-500">Rénovation salle de bain</p>
              </div>

              {/* Floating Card 2 */}
              <div className="absolute bottom-0 left-0 bg-white rounded-lg shadow-2xl p-4 w-64 transform -rotate-3 hover:rotate-0 transition-transform">
                <div className="flex items-center mb-3">
                  <div className="w-10 h-10 bg-[#FF6F00] rounded-full flex items-center justify-center mr-3">
                    <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Scanner OCR</p>
                    <p className="font-medium text-gray-900">Facture scannée</p>
                  </div>
                </div>
                <div className="bg-gray-100 rounded p-2 text-xs text-gray-600">
                  12 articles extraits automatiquement
                </div>
              </div>

              {/* Central Phone Mockup Placeholder */}
              <div className="mx-auto w-64 h-[500px] bg-gradient-to-br from-gray-800 to-gray-900 rounded-[3rem] p-3 shadow-2xl">
                <div className="bg-white rounded-[2.5rem] h-full overflow-hidden">
                  <div className="bg-[#1976D2] p-6 text-white">
                    <div className="flex items-center justify-between mb-4">
                      <h3 className="font-bold text-lg">Dashboard</h3>
                      <div className="w-8 h-8 bg-white/20 rounded-full"></div>
                    </div>
                    <div className="bg-white/10 rounded-lg p-3">
                      <p className="text-xs text-blue-100">Chiffre d'affaires</p>
                      <p className="text-2xl font-bold">45 680 €</p>
                    </div>
                  </div>
                  <div className="p-4 space-y-3">
                    <div className="bg-gray-100 rounded-lg h-16"></div>
                    <div className="bg-gray-100 rounded-lg h-16"></div>
                    <div className="bg-gray-100 rounded-lg h-16"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
