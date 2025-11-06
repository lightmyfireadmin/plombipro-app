# PlombiPro - Assets Guide

## 🎨 Brand Identity System

### Color Palette

**Primary Colors:**
- **Plumber Blue**: `#1976D2` (Trust, professionalism)
- **Tool Orange**: `#FF6B35` (Energy, action, urgency mode)
- **Success Green**: `#4CAF50` (Paid invoices, completed jobs)
- **Warning Amber**: `#FFC107` (Pending payments, reminders)
- **Error Red**: `#F44336` (Overdue, urgent)

**Neutral Colors:**
- **Dark Gray**: `#212121` (Text, headers)
- **Medium Gray**: `#757575` (Secondary text)
- **Light Gray**: `#F5F5F5` (Backgrounds)
- **White**: `#FFFFFF` (Cards, surfaces)

### Typography

**Primary Font**: **Roboto** (Material Design 3)
- **Headings**: Roboto Bold (500-700)
- **Body**: Roboto Regular (400)
- **Buttons**: Roboto Medium (500)

**Fallback**: System fonts (San Francisco on iOS, Roboto on Android)

---

## 📁 Assets Directory Structure

```
assets/
├── branding/
│   ├── logo/
│   │   ├── plombipro-logo-full.svg          # Full logo with text
│   │   ├── plombipro-logo-icon.svg          # Icon only (for app)
│   │   ├── plombipro-logo-horizontal.svg    # Horizontal lockup
│   │   ├── plombipro-logo-light.svg         # For dark backgrounds
│   │   └── plombipro-logo-dark.svg          # For light backgrounds
│   ├── wordmark/
│   │   └── plombipro-wordmark.svg           # Text only, no icon
│   └── guidelines/
│       └── brand-guidelines.pdf             # Usage rules
│
├── marketing/
│   ├── hero/
│   │   ├── hero-dashboard.png               # Main dashboard screenshot
│   │   ├── hero-ocr-scanner.png             # OCR feature highlight
│   │   └── hero-mobile-mockup.png           # Phone mockup with app
│   ├── features/
│   │   ├── feature-quotes.png               # Quote generation visual
│   │   ├── feature-invoices.png             # Invoice management
│   │   ├── feature-ocr.png                  # OCR scanning
│   │   ├── feature-2026-compliance.png      # Electronic invoicing badge
│   │   ├── feature-payments.png             # Stripe integration
│   │   └── feature-catalog.png              # Product catalog
│   ├── testimonials/
│   │   ├── testimonial-plumber-1.jpg        # Stock photo or real user
│   │   ├── testimonial-plumber-2.jpg
│   │   └── testimonial-plumber-3.jpg
│   └── comparison/
│       └── plombipro-vs-obat.svg            # Comparison table graphic
│
├── screenshots/
│   ├── app-store/
│   │   ├── iphone-6.7/                      # iPhone Pro Max screenshots
│   │   │   ├── 01-home-dashboard.png
│   │   │   ├── 02-quotes-list.png
│   │   │   ├── 03-ocr-scanner.png
│   │   │   ├── 04-invoice-form.png
│   │   │   └── 05-settings.png
│   │   └── ipad-12.9/                       # iPad Pro screenshots
│   │       ├── 01-dashboard-tablet.png
│   │       └── 02-quote-form-tablet.png
│   └── play-store/
│       ├── 01-home-fr.png                   # French language
│       ├── 02-quotes-fr.png
│       ├── 03-ocr-fr.png
│       └── 04-invoice-fr.png
│
├── icons/
│   ├── app-icons/
│   │   ├── android/
│   │   │   ├── ic_launcher-512.png          # Adaptive icon base
│   │   │   ├── ic_launcher-192.png
│   │   │   └── ic_launcher-48.png
│   │   └── ios/
│   │       ├── AppIcon-1024.png             # App Store icon
│   │       ├── AppIcon-180.png              # iPhone icon
│   │       └── AppIcon-167.png              # iPad icon
│   ├── feature-icons/
│   │   ├── icon-ocr.svg                     # Camera/scan icon
│   │   ├── icon-quote.svg                   # Document icon
│   │   ├── icon-invoice.svg                 # Receipt icon
│   │   ├── icon-payment.svg                 # Credit card icon
│   │   ├── icon-catalog.svg                 # Grid/products icon
│   │   └── icon-2026-badge.svg              # Compliance badge
│   └── social/
│       ├── social-facebook.png              # 1200x630px
│       ├── social-twitter.png               # 1200x675px
│       └── social-linkedin.png              # 1200x627px
│
└── illustrations/
    ├── empty-states/
    │   ├── empty-quotes.svg                 # No quotes yet
    │   ├── empty-invoices.svg               # No invoices yet
    │   ├── empty-products.svg               # No products yet
    │   └── empty-search.svg                 # No search results
    ├── onboarding/
    │   ├── onboarding-1-welcome.svg         # Welcome screen
    │   ├── onboarding-2-ocr.svg             # OCR feature intro
    │   └── onboarding-3-ready.svg           # Ready to start
    └── errors/
        ├── error-network.svg                # Connection error
        ├── error-404.svg                    # Page not found
        └── error-500.svg                    # Server error
```

---

## 🖼️ Asset Specifications

### Logo Requirements

**PlombiPro Logo Concept:**
- **Icon**: Stylized wrench + invoice/document combination
- **Colors**: Primary blue (#1976D2) + Tool orange (#FF6B35)
- **Style**: Modern, clean, professional
- **Formats**: SVG (vector), PNG (raster at 512px, 1024px, 2048px)

**Logo Variations Needed:**
1. **Full Logo**: Icon + "PlombiPro" wordmark
2. **Icon Only**: For app icon, favicon
3. **Horizontal**: Icon left, text right (for headers)
4. **Vertical**: Icon top, text below (for app splash)
5. **Light/Dark**: Versions for different backgrounds

### App Icon Guidelines

**Design Principles:**
- Simple, recognizable at small sizes (48px)
- No text (icon only)
- High contrast
- Unique silhouette
- Follows Material Design 3 / iOS HIG

**iOS Icon:**
- No transparency
- No rounded corners (iOS adds automatically)
- Sizes: 1024x1024px (App Store), 180x180px, 167x167px

**Android Icon:**
- Adaptive icon (foreground + background layers)
- Safe zone for different masks
- Sizes: 512x512px, 192x192px, 48x48px

### Screenshot Requirements

**App Store (iOS):**
- **iPhone 6.7"**: 1290 x 2796 pixels (5 images required)
- **iPad 12.9"**: 2048 x 2732 pixels (optional but recommended)
- Format: PNG or JPEG
- Color space: RGB
- Language: French (primary market)

**Play Store (Android):**
- **Minimum**: 320px
- **Maximum**: 3840px
- Aspect ratio: 16:9 or 9:16
- Format: PNG or JPEG (no alpha)
- Quantity: 2-8 screenshots

### Marketing Image Specs

**Hero Image (Landing Page):**
- Size: 1920 x 1080px
- Format: WebP (optimized), PNG (fallback)
- Content: Dashboard screenshot or phone mockup
- Optimization: < 200KB

**Feature Graphics:**
- Size: 800 x 600px
- Format: SVG (preferred), PNG
- Style: Flat design, icons + short labels
- Colors: Brand palette

**Social Media:**
- **Open Graph** (Facebook, LinkedIn): 1200 x 630px
- **Twitter Card**: 1200 x 675px
- **Instagram**: 1080 x 1080px (square)
- Format: PNG or JPEG
- Text: Overlays should be readable at thumbnail size

---

## 🎯 Priority Asset Creation Order

### Phase 1: MVP Launch Essentials (Week 1)
1. ✅ **Logo - Icon Only** (for app)
2. ✅ **Logo - Full** (for marketing)
3. ✅ **App Icon** (iOS + Android adaptive)
4. ✅ **Favicon** (for web app)
5. ✅ **5 App Store Screenshots** (iPhone)

### Phase 2: Marketing Website (Week 2)
6. ✅ **Hero Image** (landing page)
7. ✅ **6 Feature Icons** (quotes, invoices, OCR, etc.)
8. ✅ **Social Media Images** (OG, Twitter)
9. ✅ **Comparison Graphic** (vs Obat)
10. ✅ **3 Testimonial Photos** (stock or real)

### Phase 3: Polish & Growth (Week 3-4)
11. ✅ **Empty State Illustrations** (4 SVGs)
12. ✅ **Onboarding Illustrations** (3 SVGs)
13. ✅ **Error State Illustrations** (3 SVGs)
14. ✅ **8 Play Store Screenshots** (Android)
15. ✅ **Brand Guidelines PDF**

---

## 🛠️ Recommended Tools

### Free/Open Source:
- **Figma** (free tier): UI design, prototyping
- **Inkscape**: Vector graphics (SVG)
- **GIMP**: Raster graphics
- **Unsplash/Pexels**: Stock photos (testimonials)
- **unDraw**: Customizable illustrations
- **Heroicons**: Icon set (MIT license)

### Paid (Optional):
- **Adobe Illustrator**: Professional vector work
- **Sketch**: macOS UI design
- **IconJar**: Icon management
- **Smartmockups**: Device mockups

### Screenshot Tools:
- **Xcode Simulator**: iOS screenshots
- **Android Studio Emulator**: Android screenshots
- **Shotbot**: Automated app store screenshots
- **AppLaunchpad**: Screenshot framing

---

## 📐 Design Principles for PlombiPro

### 1. **Professional Yet Approachable**
- Clean, modern interfaces
- Not overly "corporate" - friendly for solo plumbers
- Blue conveys trust, orange adds energy

### 2. **Mobile-First**
- Icons must work at 24x24px
- Touch targets minimum 48x48px
- Readable on 5" screens

### 3. **French Market**
- All text in French
- Cultural relevance (French plumbing trade)
- No American-centric imagery

### 4. **Accessibility**
- WCAG 2.1 AA contrast ratios (4.5:1 for text)
- Color not the only indicator
- Alt text for all images

### 5. **Differentiation**
- **vs Obat**: More modern, mobile-centric
- **vs Generic Tools**: Plumbing-specific imagery (wrenches, pipes)
- **Unique Angle**: OCR scanner, 2026 compliance badge

---

## 🖌️ Asset Creation Workflow

### Logo Design Process:
1. **Sketch** 10-15 concepts (paper/digital)
2. **Refine** top 3 concepts in vector
3. **Test** at multiple sizes (512px, 128px, 48px, 24px)
4. **Validate** with target users (5 plumbers)
5. **Finalize** in all required formats

### Screenshot Workflow:
1. **Populate** app with realistic demo data (French names, real prices)
2. **Capture** at required resolutions (Simulator/Emulator)
3. **Frame** in device mockups (optional but recommended)
4. **Annotate** with feature callouts (for App Store)
5. **Localize** for French market

### Illustration Style Guide:
- **Style**: Flat 2.5D (subtle shadows, no gradients)
- **Colors**: Max 3 colors per illustration (from brand palette)
- **Line Weight**: Consistent 2-3px strokes
- **Metaphors**: Trade-specific (tools, invoices, smartphones)
- **Size**: Scalable vectors (SVG), export to PNG for web

---

## ✅ Quality Checklist

Before finalizing any asset:

- [ ] **Naming Convention**: Lowercase, hyphens, descriptive (`plombipro-logo-horizontal.svg`)
- [ ] **Format**: Correct file type (SVG for vectors, PNG for rasters, WebP for web)
- [ ] **Optimization**: Compressed for web (TinyPNG, SVGO)
- [ ] **Consistency**: Matches brand colors exactly
- [ ] **Accessibility**: Sufficient contrast, readable at small sizes
- [ ] **Legal**: Licensed for commercial use (or original work)
- [ ] **Versioning**: Keep PSD/AI source files separately
- [ ] **Documentation**: Add to this guide with usage notes

---

## 📞 Next Steps

**Immediate Action Items:**
1. **Hire/Commission Logo Designer** (Fiverr, 99designs, local designer)
   - Budget: €50-200 for professional logo
   - Deliverables: Logo package (all variations, SVG + PNG)

2. **Create App Screenshots** (DIY with Simulator)
   - Time: 2-3 hours
   - Cost: Free

3. **Source Stock Photos** (Unsplash, Pexels)
   - Search: "plumber", "tradesman", "construction worker"
   - Filter: Free for commercial use

4. **Commission Illustrations** (Fiverr, unDraw customization)
   - Budget: €30-100 for 10 custom SVGs
   - Style: Flat, minimal, brand colors

**Resources:**
- [Material Design Icons](https://fonts.google.com/icons)
- [Heroicons](https://heroicons.com/)
- [unDraw Illustrations](https://undraw.co/)
- [Unsplash](https://unsplash.com/)
- [App Store Screenshot Sizes](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications)

---

**Last Updated**: November 5, 2025
**Version**: 1.0
**Maintainer**: PlombiPro Team
