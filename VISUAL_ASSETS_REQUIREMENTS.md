# PlombiPro - Visual Assets Requirements
**Complete Asset Specification for Production Deployment**
**Date:** November 5, 2025

---

## Table of Contents
1. [App Icons & Branding](#1-app-icons--branding)
2. [Navigation & UI Icons](#2-navigation--ui-icons)
3. [Onboarding & Tutorial Assets](#3-onboarding--tutorial-assets)
4. [Status Badges & Indicators](#4-status-badges--indicators)
5. [Empty State Illustrations](#5-empty-state-illustrations)
6. [Document Type Icons](#6-document-type-icons)
7. [Loading & Progress Animations](#7-loading--progress-animations)
8. [Marketing & Promotional Assets](#8-marketing--promotional-assets)
9. [Email Template Assets](#9-email-template-assets)
10. [Export Specifications](#10-export-specifications)

---

## 1. App Icons & Branding

### 1.1 Application Icon (Primary)

**Description:** Main PlombiPro app icon representing plumbing/professional service

**Sizes Required:**

#### iOS (PNG, transparent background)
- `icon_20@1x.png` - 20x20px
- `icon_20@2x.png` - 40x40px
- `icon_20@3x.png` - 60x60px
- `icon_29@1x.png` - 29x29px
- `icon_29@2x.png` - 58x58px
- `icon_29@3x.png` - 87x87px
- `icon_40@1x.png` - 40x40px
- `icon_40@2x.png` - 80x80px
- `icon_40@3x.png` - 120x120px
- `icon_60@2x.png` - 120x120px
- `icon_60@3x.png` - 180x180px
- `icon_76@1x.png` - 76x76px
- `icon_76@2x.png` - 152x152px
- `icon_83.5@2x.png` - 167x167px
- `icon_1024.png` - 1024x1024px (App Store)

#### Android (PNG, with adaptive icon support)
- `mipmap-mdpi/ic_launcher.png` - 48x48px
- `mipmap-hdpi/ic_launcher.png` - 72x72px
- `mipmap-xhdpi/ic_launcher.png` - 96x96px
- `mipmap-xxhdpi/ic_launcher.png` - 144x144px
- `mipmap-xxxhdpi/ic_launcher.png` - 192x192px
- `ic_launcher_foreground.xml` - Vector drawable
- `ic_launcher_background.xml` - Vector drawable
- `play_store_icon.png` - 512x512px (Google Play)

**Design Specifications:**
- Style: Modern, professional
- Colors: Primary blue (#1976D2), accent orange (#FF6F00)
- Imagery: Wrench/pipe symbol or stylized "PP" monogram
- Format: PNG with transparency, vector source (SVG/AI) required
- Safe zone: Keep important elements within 80% center area

---

### 1.2 Company Logo Placeholder

**Purpose:** Default logo shown when user hasn't uploaded their company logo

**Specifications:**
- File: `assets/images/default_company_logo.png`
- Size: 400x200px (2:1 ratio)
- Format: PNG with transparency
- Content: Generic "Your Logo Here" placeholder with subtle icon
- Background: Transparent or light gray

---

### 1.3 Splash Screen / Launch Screen

**Purpose:** Shown while app initializes

**Specifications:**

#### iOS Launch Screen
- `launch_image.png` - Multiple sizes for different devices
- Background: Solid color matching app theme (Primary Blue #1976D2)
- Center element: PlombiPro logo (white) at 120x120px
- Overall feel: Clean, professional

#### Android Splash Screen
- `drawable/splash_background.xml` - Vector drawable
- `drawable/splash_logo.png` - 192x192px centered logo
- Background color: `#1976D2`
- Duration: 1-2 seconds max

---

## 2. Navigation & UI Icons

### 2.1 Bottom Navigation Icons (if used)

**Purpose:** Primary navigation tabs

**Icons Needed:**
1. **Home/Dashboard**
   - File: `assets/icons/nav_home.svg`
   - Size: 24x24dp (vector preferred)
   - Style: Outlined when inactive, filled when active
   - States: 2 (active/inactive)

2. **Invoices/Billing**
   - File: `assets/icons/nav_invoices.svg`
   - Icon: Receipt or document icon
   - Size: 24x24dp
   - States: 2

3. **Clients**
   - File: `assets/icons/nav_clients.svg`
   - Icon: Person or contacts icon
   - Size: 24x24dp
   - States: 2

4. **Products**
   - File: `assets/icons/nav_products.svg`
   - Icon: Shopping bag or box icon
   - Size: 24x24dp
   - States: 2

5. **More/Settings**
   - File: `assets/icons/nav_more.svg`
   - Icon: Grid or three dots icon
   - Size: 24x24dp
   - States: 2

**Total Files:** 10 SVG files (5 icons × 2 states)

---

### 2.2 App Drawer Icon

**Purpose:** User avatar/profile picture placeholder

**Specifications:**
- File: `assets/images/default_avatar.png`
- Size: 200x200px
- Format: PNG
- Content: Generic user silhouette on circular background
- Colors: Light blue background, white silhouette

---

### 2.3 Feature Icons (Dashboard Quick Actions)

**Purpose:** Icons for quick action buttons on homepage

**Icons Required:**

1. **New Quote**
   - File: `assets/icons/action_quote.svg`
   - Icon: Document with plus sign
   - Size: 32x32dp
   - Color: Primary blue

2. **New Invoice**
   - File: `assets/icons/action_invoice.svg`
   - Icon: Receipt with plus sign
   - Size: 32x32dp
   - Color: Primary blue

3. **New Client**
   - File: `assets/icons/action_client.svg`
   - Icon: Person with plus sign
   - Size: 32x32dp
   - Color: Primary blue

4. **Scanner**
   - File: `assets/icons/action_scan.svg`
   - Icon: QR code or camera scanner
   - Size: 32x32dp
   - Color: Primary blue

5. **Contact**
   - File: `assets/icons/action_contact.svg`
   - Icon: Phone or message bubble
   - Size: 32x32dp
   - Color: Primary blue

**Total Files:** 5 SVG files

---

## 3. Onboarding & Tutorial Assets

### 3.1 Onboarding Wizard Illustrations

**Purpose:** Welcome screens for new users

**Illustrations Needed:**

#### Screen 1: Welcome
- File: `assets/onboarding/welcome.png`
- Size: 600x400px
- Content: Plumber with tools, professional appearance
- Style: Flat illustration, friendly
- Colors: Match app theme

#### Screen 2: Manage Invoices
- File: `assets/onboarding/invoices.png`
- Size: 600x400px
- Content: Invoice documents with checkmarks
- Style: Flat illustration
- Message: "Create and track invoices easily"

#### Screen 3: Track Job Sites
- File: `assets/onboarding/job_sites.png`
- Size: 600x400px
- Content: Map pin or construction site
- Style: Flat illustration
- Message: "Manage all your job sites"

#### Screen 4: Scan Receipts
- File: `assets/onboarding/ocr.png`
- Size: 600x400px
- Content: Phone scanning a receipt
- Style: Flat illustration
- Message: "Scan and digitize supplier invoices"

#### Screen 5: Get Paid
- File: `assets/onboarding/payments.png`
- Size: 600x400px
- Content: Euro symbol with upward arrow
- Style: Flat illustration
- Message: "Track payments and revenue"

**Total Files:** 5 PNG files

**Format:** PNG, 72 DPI, transparent or white background

---

## 4. Status Badges & Indicators

### 4.1 Quote Status Badges

**Purpose:** Visual indicators for quote status

**Badges Required:**

1. **Draft**
   - Color: Gray (#9E9E9E)
   - Icon: Pencil or edit icon
   - Text: "BROUILLON"

2. **Sent**
   - Color: Blue (#2196F3)
   - Icon: Send/arrow icon
   - Text: "ENVOYÉ"

3. **Accepted**
   - Color: Green (#4CAF50)
   - Icon: Checkmark
   - Text: "ACCEPTÉ"

4. **Rejected**
   - Color: Red (#F44336)
   - Icon: X or cancel icon
   - Text: "REFUSÉ"

5. **Expired**
   - Color: Orange (#FF9800)
   - Icon: Clock or warning
   - Text: "EXPIRÉ"

**Files:**
- `assets/badges/quote_draft.svg` - 80x24dp
- `assets/badges/quote_sent.svg` - 80x24dp
- `assets/badges/quote_accepted.svg` - 80x24dp
- `assets/badges/quote_rejected.svg` - 80x24dp
- `assets/badges/quote_expired.svg` - 80x24dp

**Total Files:** 5 SVG files

---

### 4.2 Invoice Payment Status Badges

**Purpose:** Visual indicators for payment status

**Badges Required:**

1. **Unpaid**
   - Color: Red (#F44336)
   - Icon: Warning or exclamation
   - Text: "IMPAYÉE"

2. **Partially Paid**
   - Color: Orange (#FF9800)
   - Icon: Half-filled circle
   - Text: "PARTIEL"

3. **Paid**
   - Color: Green (#4CAF50)
   - Icon: Checkmark
   - Text: "PAYÉE"

4. **Overdue**
   - Color: Dark Red (#C62828)
   - Icon: Alert
   - Text: "EN RETARD"

**Files:**
- `assets/badges/invoice_unpaid.svg` - 100x24dp
- `assets/badges/invoice_partial.svg` - 100x24dp
- `assets/badges/invoice_paid.svg` - 100x24dp
- `assets/badges/invoice_overdue.svg` - 100x24dp

**Total Files:** 4 SVG files

---

### 4.3 Job Site Status Badges

**Purpose:** Visual indicators for job site status

**Badges Required:**

1. **Planning**
   - Color: Purple (#9C27B0)
   - Icon: Calendar
   - Text: "PLANIFICATION"

2. **In Progress**
   - Color: Blue (#2196F3)
   - Icon: Construction/tools
   - Text: "EN COURS"

3. **On Hold**
   - Color: Orange (#FF9800)
   - Icon: Pause
   - Text: "EN PAUSE"

4. **Completed**
   - Color: Green (#4CAF50)
   - Icon: Checkmark
   - Text: "TERMINÉ"

**Files:**
- `assets/badges/jobsite_planning.svg` - 120x24dp
- `assets/badges/jobsite_active.svg` - 120x24dp
- `assets/badges/jobsite_hold.svg` - 120x24dp
- `assets/badges/jobsite_completed.svg` - 120x24dp

**Total Files:** 4 SVG files

---

## 5. Empty State Illustrations

### 5.1 Empty List Illustrations

**Purpose:** Friendly graphics when lists are empty

**Illustrations Needed:**

1. **No Clients Yet**
   - File: `assets/empty_states/no_clients.png`
   - Size: 300x200px
   - Content: Empty contact book or person icon
   - Message: "Aucun client pour le moment"
   - CTA: "Ajouter votre premier client"

2. **No Quotes Yet**
   - File: `assets/empty_states/no_quotes.png`
   - Size: 300x200px
   - Content: Empty document or notepad
   - Message: "Aucun devis créé"
   - CTA: "Créer votre premier devis"

3. **No Invoices Yet**
   - File: `assets/empty_states/no_invoices.png`
   - Size: 300x200px
   - Content: Empty receipt or invoice stack
   - Message: "Aucune facture"
   - CTA: "Créer votre première facture"

4. **No Products Yet**
   - File: `assets/empty_states/no_products.png`
   - Size: 300x200px
   - Content: Empty box or catalog
   - Message: "Aucun produit"
   - CTA: "Ajouter des produits"

5. **No Job Sites Yet**
   - File: `assets/empty_states/no_jobsites.png`
   - Size: 300x200px
   - Content: Empty map or construction site
   - Message: "Aucun chantier"
   - CTA: "Créer votre premier chantier"

6. **No Notifications**
   - File: `assets/empty_states/no_notifications.png`
   - Size: 300x200px
   - Content: Bell icon with checkmark
   - Message: "Aucune notification"

7. **No Search Results**
   - File: `assets/empty_states/no_results.png`
   - Size: 300x200px
   - Content: Magnifying glass with X
   - Message: "Aucun résultat trouvé"

**Total Files:** 7 PNG files

**Style:** Minimalist, friendly, monochromatic (blue/gray tones)

---

## 6. Document Type Icons

### 6.1 Job Site Document Type Icons

**Purpose:** Icons for different document types in job site documents tab

**Icons Required:**

1. **Invoice Document**
   - File: `assets/doc_types/doc_invoice.svg`
   - Size: 48x48dp
   - Icon: Receipt or invoice symbol
   - Color: Orange (#FF6F00)

2. **Quote Document**
   - File: `assets/doc_types/doc_quote.svg`
   - Size: 48x48dp
   - Icon: Document with pen
   - Color: Blue (#2196F3)

3. **Contract**
   - File: `assets/doc_types/doc_contract.svg`
   - Size: 48x48dp
   - Icon: Signed document
   - Color: Green (#4CAF50)

4. **Photo**
   - File: `assets/doc_types/doc_photo.svg`
   - Size: 48x48dp
   - Icon: Camera or image
   - Color: Purple (#9C27B0)

5. **PDF File**
   - File: `assets/doc_types/doc_pdf.svg`
   - Size: 48x48dp
   - Icon: PDF file icon
   - Color: Red (#F44336)

6. **Other/Generic**
   - File: `assets/doc_types/doc_other.svg`
   - Size: 48x48dp
   - Icon: Generic file
   - Color: Gray (#757575)

**Total Files:** 6 SVG files

---

## 7. Loading & Progress Animations

### 7.1 Loading Spinner

**Purpose:** Custom branded loading indicator

**Specifications:**
- File: `assets/animations/loading_spinner.json` (Lottie animation)
- Alternative: `assets/animations/loading_spinner.gif`
- Size: 100x100px
- Duration: 1.5 seconds loop
- Colors: Primary blue with accent highlights
- Style: Circular spinner or plumbing-themed animation (e.g., water droplets)

---

### 7.2 Progress Bar Asset

**Purpose:** Determinate progress indicator for uploads/downloads

**Specifications:**
- Programmatically generated (no asset needed)
- Colors: Primary blue fill, light gray background
- Height: 4dp
- Border radius: 2dp

---

### 7.3 Success Animation

**Purpose:** Shown after successful operations

**Specifications:**
- File: `assets/animations/success.json` (Lottie)
- Alternative: `assets/animations/success.gif`
- Size: 150x150px
- Duration: 1 second
- Animation: Green checkmark appearing
- Format: Lottie JSON (preferred) or GIF

---

### 7.4 Error Animation

**Purpose:** Shown when errors occur

**Specifications:**
- File: `assets/animations/error.json` (Lottie)
- Alternative: `assets/animations/error.gif`
- Size: 150x150px
- Duration: 1 second
- Animation: Red X or warning symbol
- Format: Lottie JSON (preferred) or GIF

---

## 8. Marketing & Promotional Assets

### 8.1 App Store Screenshots

**Purpose:** Marketing materials for iOS App Store

**Requirements:**

#### iPhone Screenshots (Required)
- **6.7" Display (iPhone 14 Pro Max)**
  - Size: 1290x2796px
  - Quantity: 5-10 screenshots
  - Format: PNG or JPG

- **6.5" Display (iPhone 11 Pro Max)**
  - Size: 1242x2688px
  - Quantity: 5-10 screenshots
  - Format: PNG or JPG

- **5.5" Display (iPhone 8 Plus)**
  - Size: 1242x2208px
  - Quantity: 5-10 screenshots
  - Format: PNG or JPG

#### iPad Screenshots (Optional)
- **12.9" Display (iPad Pro)**
  - Size: 2048x2732px
  - Quantity: 5-10 screenshots

**Content Suggestions:**
1. Dashboard with statistics
2. Invoice creation screen
3. Job site detail with photos
4. OCR scanning in action
5. Client management
6. Product catalog
7. Payment tracking
8. PDF invoice preview

**Style:** Add device frame, background, and feature callouts with text

---

### 8.2 Google Play Screenshots

**Purpose:** Marketing materials for Google Play Store

**Requirements:**

#### Phone Screenshots
- Size: 1080x1920px (minimum)
- Quantity: 2-8 screenshots
- Format: PNG or JPG (24-bit, no alpha)

#### 7" Tablet Screenshots (Optional)
- Size: 1024x1792px
- Quantity: Up to 8

#### 10" Tablet Screenshots (Optional)
- Size: 1536x2048px
- Quantity: Up to 8

**Content:** Same as iOS screenshots, adapted for Android UI

---

### 8.3 Feature Graphic (Google Play)

**Purpose:** Hero image for Google Play listing

**Specifications:**
- File: `marketing/google_play_feature_graphic.png`
- Size: 1024x500px (exact)
- Format: PNG or JPG (24-bit, no alpha)
- Content: PlombiPro branding, key features, tagline
- Text: Minimal, high contrast, large fonts
- Example text: "Gestion complète pour plombiers professionnels"

---

### 8.4 App Preview Video (Optional)

**Purpose:** Short video showcasing app features

**Specifications:**

#### iOS App Store
- Duration: 15-30 seconds
- Resolutions:
  - 1080x1920px (Portrait)
  - 1920x1080px (Landscape)
- Format: M4V, MP4, or MOV
- Codec: H.264
- File size: Max 500MB

#### Google Play
- Duration: 30 seconds to 2 minutes
- Resolution: 1920x1080px minimum
- Format: MPEG, AVI, WMV, MP4, MOV, or 3GPP
- File size: Max 100MB

**Content Outline:**
1. Opening: PlombiPro logo (2s)
2. Feature 1: Create invoices quickly (5s)
3. Feature 2: Scan receipts with OCR (5s)
4. Feature 3: Track job sites (5s)
5. Feature 4: Get paid faster (5s)
6. Closing: Download now + logo (3s)

---

## 9. Email Template Assets

### 9.1 Email Header Logo

**Purpose:** Logo for transactional emails

**Specifications:**
- File: `assets/email/header_logo.png`
- Size: 600x120px
- Format: PNG
- Content: PlombiPro logo (horizontal layout)
- Background: Transparent or solid color
- DPI: 144 (for retina displays)

---

### 9.2 Email Footer Graphics

**Purpose:** Footer icons for emails (social media, contact)

**Icons Needed:**
- Email icon: 32x32px
- Phone icon: 32x32px
- Website icon: 32x32px
- Facebook icon: 32x32px (if applicable)
- LinkedIn icon: 32x32px (if applicable)

**Format:** PNG, transparent background

---

### 9.3 Email Button Background

**Purpose:** CTA buttons in emails

**Specifications:**
- Programmatically generated (no asset)
- Background color: Primary blue (#1976D2)
- Text color: White
- Border radius: 4px
- Padding: 12px 24px
- Font: Bold, 16px

---

## 10. Export Specifications

### 10.1 PDF Report Graphics

**Purpose:** Headers/footers for generated PDF reports

**Files Needed:**

1. **Invoice Header**
   - Default professional header design
   - Size: Full width, 80pt height
   - Content: "FACTURE" text, decorative line
   - Colors: Match theme

2. **Quote Header**
   - Default professional header design
   - Size: Full width, 80pt height
   - Content: "DEVIS" text, decorative line
   - Colors: Match theme

**Note:** These are generated by ReportLab in the cloud function, but custom templates can be added as PNG overlays if needed.

---

### 10.2 Watermark (Optional)

**Purpose:** "PAID" or "DRAFT" watermark for PDFs

**Specifications:**
- Size: 400x100px
- Format: PNG with transparency
- Opacity: 20-30%
- Text: "PAYÉ" or "BROUILLON"
- Color: Gray
- Rotation: -45 degrees

---

## Summary of Assets Required

### Critical Assets (Highest Priority)
- ✅ App icons (iOS: 15 files, Android: 7 files)
- ✅ Splash screen graphics (2 files)
- ✅ Default company logo placeholder (1 file)
- ✅ Default user avatar (1 file)
- ⚠️ Status badges (13 SVG files)
- ⚠️ Empty state illustrations (7 files)

### High Priority Assets
- ⚠️ Navigation icons (10 files)
- ⚠️ Feature/action icons (5 files)
- ⚠️ Document type icons (6 files)
- ⚠️ Loading animations (3-4 files)

### Medium Priority Assets
- Onboarding illustrations (5 files)
- App Store screenshots (10+ files)
- Google Play assets (Feature graphic + screenshots)
- Email template graphics (6+ files)

### Low Priority Assets (Nice to Have)
- App preview video (1 file)
- PDF watermarks (2 files)
- Additional marketing materials

---

## Total Asset Count

| Category | Asset Count |
|----------|-------------|
| **App Icons** | 22 files |
| **UI Icons** | 21 files |
| **Badges & Status** | 13 files |
| **Empty States** | 7 files |
| **Onboarding** | 5 files |
| **Animations** | 4 files |
| **Document Icons** | 6 files |
| **Placeholders** | 2 files |
| **Marketing** | 20+ files |
| **Email Assets** | 6 files |
| **TOTAL** | **~106 files minimum** |

---

## Design System Guidelines

### Color Palette
```
Primary Blue: #1976D2
Primary Dark: #1565C0
Primary Light: #42A5F5
Accent Orange: #FF6F00
Accent Light: #FFA726
Success Green: #4CAF50
Error Red: #F44336
Warning Orange: #FF9800
Background: #FAFAFA
Surface: #FFFFFF
Text Primary: #212121
Text Secondary: #757575
```

### Typography
- Primary Font: Roboto (Material Design standard)
- Headings: Roboto Medium/Bold
- Body: Roboto Regular
- Sizes: Follow Material Design type scale

### Icon Style
- Style: Material Design Icons (outlined when inactive, filled when active)
- Weight: 400 (regular)
- Size: 24dp standard, 32dp for emphasis, 48dp for large
- Color: Follow color palette above

### Illustration Style
- Style: Flat, modern, friendly
- Colors: Use app color palette
- Complexity: Simple, clean, avoid excessive detail
- Background: Transparent or white

---

## Asset Delivery Format

### For Development
- **Icons:** SVG (vector) preferred, PNG @3x fallback
- **Images:** PNG with transparency
- **Illustrations:** PNG @2x (144 DPI)
- **Animations:** Lottie JSON preferred, GIF fallback

### Naming Convention
```
{category}_{name}_{variant}.{ext}

Examples:
- nav_home_active.svg
- badge_quote_accepted.svg
- empty_no_clients.png
- onboarding_welcome.png
```

### Folder Structure
```
assets/
├── icons/
│   ├── navigation/
│   ├── actions/
│   └── system/
├── images/
│   ├── placeholders/
│   ├── empty_states/
│   └── onboarding/
├── badges/
├── doc_types/
├── animations/
└── email/
```

---

## Tools & Resources

### Recommended Design Tools
- **Vector Graphics:** Figma, Adobe Illustrator, Sketch
- **Raster Graphics:** Photoshop, Affinity Photo
- **Animations:** Adobe After Effects + Lottie plugin
- **Icon Generation:** Android Asset Studio, App Icon Generator
- **Prototyping:** Figma, InVision

### Icon Resources
- Material Design Icons: https://fonts.google.com/icons
- Heroicons: https://heroicons.com/
- Feather Icons: https://feathericons.com/

### Illustration Resources
- unDraw: https://undraw.co/ (customizable)
- Storyset: https://storyset.com/ (animated)
- Illustrations.co: https://illlustrations.co/

### Animation Resources
- LottieFiles: https://lottiefiles.com/ (ready-made animations)
- After Effects + Lottie plugin for custom animations

---

## Next Steps

1. **Prioritize Critical Assets** - Start with app icons and splash screens
2. **Create Design System** - Establish color palette and typography
3. **Generate Core UI Assets** - Status badges, navigation icons
4. **Design Empty States** - User-friendly illustrations
5. **Create Marketing Materials** - App Store assets
6. **Test on Devices** - Verify all assets look correct on real devices
7. **Optimize File Sizes** - Compress PNGs, optimize SVGs
8. **Document Usage** - Create asset usage guide for developers

---

*Document Created: November 5, 2025*
*Total Assets Required: ~106 files minimum*
*Priority: Critical assets needed before production launch*
