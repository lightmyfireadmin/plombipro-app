# PlombiPro Marketing Website

Le site web marketing de PlombiPro - Le logiciel de facturation pour plombiers.

## 🚀 Technologies

- **Next.js 14** - Framework React avec App Router
- **TypeScript** - Typage statique
- **Tailwind CSS** - Framework CSS utility-first
- **React** - Bibliothèque UI

## 📋 Prérequis

- Node.js 18+
- npm ou yarn

## 🛠️ Installation

```bash
# Installer les dépendances
npm install

# Lancer le serveur de développement
npm run dev

# Compiler pour la production
npm run build

# Lancer la version production
npm start
```

Le site sera accessible sur [http://localhost:3000](http://localhost:3000)

## 📁 Structure du Projet

```
website/
├── app/
│   ├── components/          # Composants React
│   │   ├── Navigation.tsx   # Barre de navigation avec menu mobile
│   │   ├── Hero.tsx         # Section hero avec CTA
│   │   ├── Features.tsx     # Fonctionnalités (OCR, catalogues)
│   │   ├── HowItWorks.tsx   # Process en 4 étapes
│   │   ├── Pricing.tsx      # Grilles de tarifs (Gratuit/Pro)
│   │   ├── Testimonials.tsx # Témoignages clients
│   │   └── Footer.tsx       # Footer avec liens
│   ├── globals.css          # Styles globaux + variables CSS
│   ├── layout.tsx           # Layout principal + SEO metadata
│   └── page.tsx             # Page d'accueil
├── public/                  # Assets statiques
└── package.json
```

## 🎨 Couleurs de Marque

```css
/* Définies dans globals.css */
--primary: #1976D2        /* Bleu principal */
--primary-dark: #1565C0   /* Bleu foncé */
--primary-light: #64B5F6  /* Bleu clair */
--secondary: #FF6F00      /* Orange */
--secondary-dark: #E65100 /* Orange foncé */
--accent: #4CAF50         /* Vert (success) */
```

## 📱 Sections du Site

### 1. **Navigation**
- Logo PlombiPro
- Liens vers sections (Fonctionnalités, Comment ça marche, Tarifs, Témoignages)
- CTA "Essai gratuit" et "Connexion"
- Menu mobile responsive

### 2. **Hero Section**
- Titre accrocheur avec le mot "scanne" en gradient orange
- Sous-titre mettant en avant Point P et Cedeo
- 3 badges (Scanner OCR, Conforme 2026, 5 devis gratuits)
- 2 CTA (Commencer gratuitement, Voir la démo)
- Trust indicators (4.8/5, 500+ plombiers)
- Mockup app avec cartes flottantes

### 3. **Features Section**
- 6 fonctionnalités clés
- 2 exclusives (Scanner OCR, Catalogues) avec badge orange
- Icons SVG personnalisés
- Cards avec hover effects

### 4. **How It Works**
- 4 étapes numérotées
- Process complet : Photo → Marge → Devis → Facture
- Banner "10 heures gagnées par semaine"
- Call-to-action

### 5. **Pricing**
- Plan Gratuit (0€) : 5 devis/mois
- Plan Pro (9,90€/mois) : Illimité avec badge "Offre de lancement -50%"
- Features détaillées
- FAQ avec 4 questions courantes
- Badge "Satisfait ou remboursé 30 jours"

### 6. **Testimonials**
- 3 témoignages avec avatars générés
- Statistiques (2h/jour économisées, +35% rentabilité, 8000€ récupérés)
- Stats globales (500+ plombiers, 15k+ devis, 4.8/5)
- Logos partenaires (Point P, Cedeo, Chorus Pro, Stripe)
- CTA final

### 7. **Footer**
- Logo et description
- 4 colonnes : Produit, Ressources, Légal, Contact
- Liens réseaux sociaux
- Badges conformité (RGPD, 2026, Hébergement France)
- Banner promo orange en bas

## 🔍 SEO

Le site est optimisé pour le référencement :

- **Meta title** : "PlombiPro - Logiciel de facturation pour plombiers | Devis & Factures"
- **Meta description** : Focus sur scanner OCR et catalogues Point P/Cedeo
- **Keywords** : logiciel facturation plombier, devis plomberie, Point P, Cedeo, OCR
- **Open Graph** : Configuré pour partages réseaux sociaux
- **Language** : fr (Français)
- **Structured data** : Prêt pour JSON-LD (à ajouter)

## 📦 Déploiement

### Vercel (Recommandé)

1. Push le code sur GitHub
2. Connecter le repo à Vercel
3. Déployer automatiquement

```bash
# Avec Vercel CLI
npm install -g vercel
vercel
```

### Autres Plateformes

- **Netlify** : Compatible
- **Cloudflare Pages** : Compatible
- **AWS Amplify** : Compatible
- **VPS/Serveur** : Nécessite Node.js

## 🚧 TODO / Améliorations Futures

- [ ] Ajouter vraies images mockup app
- [ ] Ajouter vidéo démo dans Hero
- [ ] Créer vraies photos de témoignages
- [ ] Ajouter images illustrations pour Features
- [ ] Créer page /legal/mentions-legales
- [ ] Créer page /legal/cgv
- [ ] Créer page /legal/confidentialite
- [ ] Ajouter tracking analytics (Google Analytics / Plausible)
- [ ] Ajouter formulaire contact
- [ ] Intégrer Stripe checkout pour essai Pro
- [ ] Ajouter JSON-LD structured data
- [ ] Créer page /blog
- [ ] Ajouter i18n si expansion internationale

## 📝 Assets à Produire

Voir le fichier `/VISUAL_ASSETS_CHECKLIST.md` à la racine du projet pour la liste complète des assets visuels nécessaires :

**Priorité 1 (Critical) :**
- Logo PlombiPro (SVG + PNG, 5 variations)
- Mockup app mobile (Hero section)
- 4-5 illustrations features
- Screenshot app pour stores

**Priorité 2 (Important) :**
- Photos témoignages
- Vidéo démo
- Icônes personnalisés

## 🤝 Contribution

Ce projet est développé pour PlombiPro. Pour toute question ou amélioration, contactez l'équipe de développement.

## 📄 License

Propriétaire - PlombiPro © 2025

---

**Site web développé avec ❤️ pour les plombiers français**
