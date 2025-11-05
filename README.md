# PlombiPro 🔧

**Le premier logiciel de devis et facturation fait PAR des plombiers, POUR des plombiers.**

PlombiPro est une application SaaS mobile-first conçue spécifiquement pour les artisans plombiers en France. Gérez vos devis, factures, et catalogue produits avec une solution moderne, conforme à la réglementation 2026 sur la facturation électronique.

---

## 🎯 Fonctionnalités Clés

### 🔍 Scanner OCR Magique
- Scannez n'importe quelle facture fournisseur avec votre smartphone
- Extraction automatique des produits, prix, et références
- Importation directe dans votre catalogue personnel
- Powered by OCR.space (gratuit jusqu'à 25,000 scans/mois)

### 📊 Gestion Devis & Factures
- Création de devis en 10 secondes via drag & drop
- Conversion devis → facture en 1 clic
- Templates pré-remplis pour interventions courantes (fuite, débouchage, installation chaudière)
- Envoi PDF par email automatique (via Resend)

### 🛠️ Catalogues Auto-Scrapés
- 50,000+ produits pré-indexés (Point.P, Cedeo, BigMat)
- Scraping automatique des prix via Edge Functions
- Mises à jour hebdomadaires des tarifs
- Recherche ultra-rapide par référence ou description

### ⚖️ Conforme 2026 Nativement
- Format Factur-X et CII (Cross Industry Invoice)
- Prêt pour le PPF (Plateforme de Facturation)
- Archivage légal 10 ans inclus (Supabase Storage)
- Numérotation séquentielle automatique

### 📱 Mobile-First Vrai
- Fonctionne offline (Supabase local cache)
- Mode urgence pour facturer sur chantier
- Synchronisation automatique multi-appareils
- Interface optimisée pour écran 5"

---

## 🏗️ Tech Stack

### Frontend
- **Flutter 3.x** (iOS, Android, Web)
- **Material Design 3** (Dynamic Color, Material You)
- **Supabase Client** (auth, database, realtime, storage)

### Backend
- **Supabase** (PostgreSQL + PostgREST + Realtime + Auth + Storage)
- **Edge Functions** (TypeScript/Deno)
  - OCR processing (`ocr-invoice`)
  - Email sending (`send-invoice-email`)
  - Catalog scraping (`scrape-catalog`)
  - Stripe webhooks (`stripe-webhook`)

### Intégrations
- **OCR.space API** (free tier: 25k requests/month)
- **Resend API** (free tier: 3k emails/month)
- **Stripe** (paiements en ligne, abonnements)
- **Supabase Storage** (PDFs, images)

---

## 📂 Structure du Projet

```
plombipro-app/
├── lib/
│   ├── main.dart                           # Entry point
│   ├── screens/
│   │   ├── auth/                           # Login, signup
│   │   ├── home/                           # Dashboard
│   │   ├── quotes/                         # Devis
│   │   ├── invoices/                       # Factures
│   │   ├── products/                       # Catalogue
│   │   ├── ocr/                            # Scanner OCR
│   │   └── settings/                       # Paramètres
│   ├── widgets/                            # Composants réutilisables
│   ├── models/                             # Data models
│   └── services/                           # API clients
├── assets/
│   ├── branding/                           # Logos, wordmarks
│   ├── marketing/                          # Screenshots, hero images
│   ├── icons/                              # App icons, feature icons
│   └── illustrations/                      # Empty states, onboarding
├── web/
│   ├── index.html                          # PWA shell
│   └── manifest.json                       # PWA manifest
├── supabase/
│   ├── functions/                          # Edge Functions
│   │   ├── ocr-invoice/
│   │   ├── send-invoice-email/
│   │   ├── scrape-catalog/
│   │   └── stripe-webhook/
│   └── migrations/                         # Database schemas
├── marketing-website.html                  # Landing page
└── PLOMBIPRO_MASTER_GUIDE.pdf             # Complete dev guide (39 pages)
```

---

## 🚀 Getting Started

### Prérequis
- Flutter SDK 3.x
- Dart 3.x
- Supabase CLI
- iOS Simulator / Android Emulator
- Xcode (pour iOS) ou Android Studio

### Installation

1. **Clone le repository**
```bash
git clone https://github.com/lightmyfireadmin/plombipro-app.git
cd plombipro-app
```

2. **Installer les dépendances Flutter**
```bash
flutter pub get
```

3. **Configuration Supabase**
- Créer un projet sur [supabase.com](https://supabase.com)
- Copier les clés API dans `lib/services/supabase_service.dart`
- Exécuter les migrations SQL (voir `supabase/migrations/`)

4. **Configuration des APIs tierces**
- OCR.space: [https://ocr.space/ocrapi](https://ocr.space/ocrapi)
- Resend: [https://resend.com](https://resend.com)
- Stripe: [https://stripe.com](https://stripe.com)

5. **Lancer l'app**
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome
```

---

## 🎨 Assets & Branding

Voir **[assets/ASSETS_GUIDE.md](assets/ASSETS_GUIDE.md)** pour:
- Palette de couleurs (Plumber Blue #1976D2, Tool Orange #FF6B35)
- Spécifications des logos
- Screenshots App Store / Play Store
- Guidelines de design

---

## 💰 Pricing Tiers

| Plan | Prix | Devis/mois | Factures/mois | Features |
|------|------|-----------|---------------|----------|
| **Gratuit** | 0€ | 5 | 10 | Catalogue de base |
| **Starter** | 15€ | ∞ | ∞ | OCR, templates, scraping |
| **Pro** | 29€ | ∞ | ∞ | Multi-users, API, analytics |

---

## 📋 Roadmap

### Phase 1: MVP (En cours)
- [x] Architecture Supabase + Flutter
- [x] Authentification (email/password)
- [x] CRUD Devis & Factures
- [x] Scanner OCR
- [x] Catalogue produits
- [ ] Déploiement App Store / Play Store

### Phase 2: Growth (Q1 2026)
- [ ] Intégration Stripe pour paiements clients
- [ ] Templates personnalisables
- [ ] Mode offline complet
- [ ] Statistiques dashboard

### Phase 3: Scale (Q2 2026)
- [ ] Multi-utilisateurs (Entreprises)
- [ ] API publique
- [ ] Connecteurs comptables (Pennylane, Indy)
- [ ] Facturation récurrente

---

## 📖 Documentation

- **[PLOMBIPRO_MASTER_GUIDE.pdf](PLOMBIPRO_MASTER_GUIDE.pdf)** - Guide complet (39 pages)
  - UI layouts complets
  - Backend architecture
  - Database schemas
  - Deployment guides
  - Competitive analysis

- **[assets/ASSETS_GUIDE.md](assets/ASSETS_GUIDE.md)** - Asset strategy & brand guidelines

- **[marketing-website.html](marketing-website.html)** - Landing page marketing

---

## 🛡️ Conformité & Sécurité

### Facturation Électronique 2026
- Format **Factur-X** (PDF + XML embarqué)
- Format **CII** (Cross Industry Invoice)
- Numérotation séquentielle sans trou
- Archivage 10 ans

### RGPD
- Données hébergées UE (Supabase Frankfurt)
- Politique de confidentialité
- Droit à l'oubli (suppression compte)

### Sécurité
- Row Level Security (RLS) activé sur toutes les tables
- Authentification JWT
- Hashage bcrypt pour mots de passe
- HTTPS obligatoire

---

## 🤝 Contributing

Ce projet est actuellement en développement privé. Pour toute suggestion ou bug report, contactez: **contact@plombipro.app**

---

## 📄 License

Proprietary - © 2025 PlombiPro. Tous droits réservés.

---

## 📞 Support

- **Email**: support@plombipro.app
- **Documentation**: [docs.plombipro.app](https://docs.plombipro.app)
- **Status**: [status.plombipro.app](https://status.plombipro.app)

---

**Made with ❤️ by plumbers, for plumbers. 🔧**
