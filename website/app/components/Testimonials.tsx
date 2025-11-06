export default function Testimonials() {
  const testimonials = [
    {
      name: "Julien M.",
      role: "Plombier chauffagiste, Paris",
      company: "JM Plomberie",
      image: null, // Placeholder for actual image
      quote: "Le scanner OCR est une révolution. Je photographie mes factures Point P et hop, tout est dans le devis. J'ai gagné 2 heures par jour, c'est énorme.",
      rating: 5,
      stat: "2h/jour économisées",
    },
    {
      name: "Marc D.",
      role: "Plombier indépendant, Lyon",
      company: "MD Services",
      image: null,
      quote: "Avant je perdais du temps à ressaisir les prix du catalogue Cedeo. Maintenant c'est intégré. En plus je vois enfin quels chantiers sont vraiment rentables.",
      rating: 5,
      stat: "+35% de rentabilité",
    },
    {
      name: "Sophie L.",
      role: "Gérante, Bordeaux",
      company: "SL Plomberie & Chauffage",
      image: null,
      quote: "J'avais peur de la réforme 2026. Avec PlombiPro je suis tranquille, tout est conforme. Et les relances automatiques m'ont fait récupérer 8 000€ d'impayés !",
      rating: 5,
      stat: "8 000€ récupérés",
    },
  ];

  return (
    <section id="testimonials" className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center bg-blue-50 rounded-full px-4 py-2 mb-4">
            <svg className="w-5 h-5 text-[#FF6F00] mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
            <span className="text-sm font-semibold text-gray-700">
              Note moyenne : 4.8/5 sur les stores
            </span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            Ils ont adopté PlombiPro
          </h2>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Rejoignez les 500+ plombiers qui gagnent du temps chaque jour
          </p>
        </div>

        {/* Testimonials Grid */}
        <div className="grid md:grid-cols-3 gap-8 mb-16">
          {testimonials.map((testimonial, index) => (
            <div
              key={index}
              className="bg-gradient-to-br from-gray-50 to-white rounded-2xl p-8 border border-gray-200 hover:shadow-xl transition-all hover:-translate-y-2"
            >
              {/* Rating Stars */}
              <div className="flex mb-4">
                {[...Array(testimonial.rating)].map((_, i) => (
                  <svg
                    key={i}
                    className="w-5 h-5 text-[#FF6F00]"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                ))}
              </div>

              {/* Quote */}
              <blockquote className="text-gray-700 leading-relaxed mb-6 italic">
                &ldquo;{testimonial.quote}&rdquo;
              </blockquote>

              {/* Stat Highlight */}
              <div className="bg-gradient-to-r from-[#1976D2] to-[#64B5F6] text-white rounded-lg px-4 py-2 mb-6 inline-block">
                <span className="font-bold text-sm">{testimonial.stat}</span>
              </div>

              {/* Author */}
              <div className="flex items-center">
                <div className="w-12 h-12 bg-gradient-to-br from-[#1976D2] to-[#64B5F6] rounded-full flex items-center justify-center text-white font-bold text-lg mr-4">
                  {testimonial.name.charAt(0)}
                </div>
                <div>
                  <p className="font-semibold text-gray-900">
                    {testimonial.name}
                  </p>
                  <p className="text-sm text-gray-600">{testimonial.role}</p>
                  <p className="text-xs text-gray-500">{testimonial.company}</p>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Stats Section */}
        <div className="bg-gradient-to-br from-[#1976D2] to-[#1565C0] rounded-3xl p-12 text-white">
          <div className="grid md:grid-cols-4 gap-8 text-center">
            <div>
              <div className="text-5xl font-bold mb-2">500+</div>
              <div className="text-blue-100">Plombiers actifs</div>
            </div>
            <div>
              <div className="text-5xl font-bold mb-2">15k+</div>
              <div className="text-blue-100">Devis créés</div>
            </div>
            <div>
              <div className="text-5xl font-bold mb-2">10h</div>
              <div className="text-blue-100">Gagnées/semaine</div>
            </div>
            <div>
              <div className="text-5xl font-bold mb-2">4.8/5</div>
              <div className="text-blue-100">Satisfaction</div>
            </div>
          </div>
        </div>

        {/* Social Proof Logos */}
        <div className="mt-16 text-center">
          <p className="text-gray-600 mb-8">Compatible avec vos outils</p>
          <div className="flex flex-wrap justify-center items-center gap-8 md:gap-12 opacity-60">
            <div className="text-gray-400 font-bold text-xl">Point P</div>
            <div className="text-gray-400 font-bold text-xl">Cedeo</div>
            <div className="text-gray-400 font-bold text-xl">Chorus Pro</div>
            <div className="text-gray-400 font-bold text-xl">Stripe</div>
            <div className="text-gray-400 font-bold text-xl">iOS & Android</div>
          </div>
        </div>

        {/* Final CTA */}
        <div className="mt-16 text-center">
          <h3 className="text-3xl font-bold text-gray-900 mb-6">
            Prêt à gagner du temps ?
          </h3>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href="#"
              className="bg-[#FF6F00] text-white px-8 py-4 rounded-lg font-semibold text-lg hover:bg-[#E65100] transition-all shadow-xl hover:shadow-2xl transform hover:-translate-y-1"
            >
              Essayer gratuitement pendant 14 jours
            </a>
            <a
              href="#pricing"
              className="bg-gray-100 text-gray-900 px-8 py-4 rounded-lg font-semibold text-lg hover:bg-gray-200 transition-all"
            >
              Voir les tarifs
            </a>
          </div>
          <p className="text-gray-500 mt-4 text-sm">
            ✓ Aucune carte bancaire requise ✓ 5 devis offerts ✓ Résiliation en 2 clics ✓ Support français
          </p>
        </div>
      </div>
    </section>
  );
}
