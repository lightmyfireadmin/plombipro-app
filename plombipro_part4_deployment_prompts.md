# PLOMBIPRO - PART 4: iOS/ANDROID DEPLOYMENT & AI FLUTTERFLOW PROMPTS

---

## 📱 COMPLETE iOS DEPLOYMENT GUIDE

### Step 1: Prerequisites (15 minutes)

```bash
# Install/update Xcode command line tools
xcode-select --install

# Check Flutter doctor
flutter doctor -v

# Resolve any issues:
# ✓ Xcode version 14.3+
# ✓ iOS deployment target 11.0+
# ✓ CocoaPods installed
sudo gem install cocoapods
```

### Step 2: iOS Project Setup (30 minutes)

```bash
# Navigate to iOS folder
cd ios

# Update pods
pod repo update
pod update

# Install pods with platform spec
cd ..
flutter pub get
cd ios
pod install --repo-update

cd ..
```

### Step 3: Configure Info.plist

**File: `ios/Runner/Info.plist`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App name -->
    <key>CFBundleName</key>
    <string>PlombiPro</string>
    
    <!-- Localization -->
    <key>CFBundleDevelopmentRegion</key>
    <string>fr_FR</string>
    
    <!-- Camera permission (for OCR) -->
    <key>NSCameraUsageDescription</key>
    <string>PlombiPro a besoin d'accéder à votre caméra pour scanner les factures.</string>
    
    <!-- Photo library -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>PlombiPro a besoin d'accéder à votre photothèque pour importer des images.</string>
    
    <!-- File access -->
    <key>NSLocalNetworkUsageDescription</key>
    <string>PlombiPro accède à votre réseau local pour la synchronisation.</string>
    
    <!-- Required capabilities -->
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
        <string>arm64</string>
    </array>
    
    <!-- App delegates -->
    <key>UIApplicationDelegateClassName</key>
    <string>$(EXECUTABLE_NAME).GeneratedPluginRegistrant</string>
    
    <!-- Background modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>processing</string>
    </array>
</dict>
</plist>
```

### Step 4: Xcode Project Configuration

```bash
# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select "Runner" project
# 2. Select "Runner" target
# 3. Go to "Build Settings"
# 4. Search for "iOS Deployment Target"
# 5. Change to 11.0 (minimum for Supabase)
# 6. Search for "Valid Architectures"
# 7. Set to: arm64 armv7
```

### Step 5: Build & Sign for Release

```bash
# Create release build
flutter build ios --release

# Or using Xcode directly:
# 1. Select scheme: "Runner" | Product
# 2. Select destination: "iOS Device"
# 3. Product → Archive
# 4. In Archives window, select latest archive
# 5. Click "Distribute App"

# For TestFlight:
# 1. Choose "TestFlight and the App Store"
# 2. Select team
# 3. Check "Manage signing automatically"
# 4. Upload to App Store
```

### Step 6: App Store Connect Configuration

**Create App ID on App Store Connect:**
```
1. Log in to https://appstoreconnect.apple.com
2. Apps → + Create New App
3. Platform: iOS
4. Name: PlombiPro
5. Primary Language: French
6. Bundle ID: com.yourcompany.plombipro (must match Xcode)
7. SKU: PLOMBIPRO-2025
8. User Access: None (initially)
9. Save
```

**Set up TestFlight:**
```
1. TestFlight → Internal Testing
2. Add testers (Apple IDs)
3. Upload build from Xcode
4. Review build (usually 5-10 mins)
5. Send invitation to testers
```

**Prepare for App Store Review:**
```
1. App Information:
   - Category: Business
   - Age Rating: 4+
   - Copyright: 2025 Your Company

2. App Preview & Screenshots (5):
   - Dashboard (en français)
   - Devis
   - Facturation
   - Scan OCR
   - Paiements

3. Description (FR):
   "PlombiPro : Facturation et gestion d'affaires pour plombiers français.
   - Devis & Factures digitales
   - Scanner OCR pour factures fournisseurs
   - Paiements Stripe intégrés
   - Signatures électroniques
   - Conformité 2026 (Factur-X)"

4. Keywords: plomberie, facturation, devis, invoices

5. Support URL: https://support.plombipro.fr
   Privacy Policy: https://plombipro.fr/privacy
```

---

## 🤖 COMPLETE ANDROID DEPLOYMENT GUIDE

### Step 1: Prerequisites

```bash
# Ensure Android SDK 28+ installed
# Set ANDROID_HOME
export ANDROID_HOME=$HOME/Library/Android/sdk

# Check Flutter doctor
flutter doctor --android

# Verify:
# ✓ Android SDK version 28+
# ✓ Android buildTools 33.0.0+
# ✓ Gradle 8.0+
```

### Step 2: Configure build.gradle

**File: `android/build.gradle`**

```gradle
buildscript {
    ext.kotlin_version = '1.8.0'
    
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.1'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.3.15'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```

**File: `android/app/build.gradle`**

```gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    compileSdkVersion 33
    ndkVersion "25.2.9519653"

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.yourcompany.plombipro"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
        
        // Permissions
        manifestPlaceholders = [
            'appAuthRedirectScheme': 'com.yourcompany.plombipro'
        ]
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        
        debug {
            debuggable true
        }
    }
    
    signingConfigs {
        release {
            keyAlias System.getenv("KEY_ALIAS") ?: "release"
            keyPassword System.getenv("KEY_PASSWORD") ?: ""
            storeFile file(System.getenv("KEYSTORE_PATH") ?: "")
            storePassword System.getenv("KEYSTORE_PASSWORD") ?: ""
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation 'com.google.android.material:material:1.8.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
}
```

### Step 3: AndroidManifest.xml Configuration

**File: `android/app/src/main/AndroidManifest.xml`**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.yourcompany.plombipro">

    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Features -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />

    <application
        android:label="PlombiPro"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false"
        tools:targetApi="33">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- Required for background tasks -->
        <service android:name="io.flutter.embedding.engine.FlutterEngineGroup" />
    </application>
</manifest>
```

### Step 4: Generate Signing Key

```bash
# Generate keystore
keytool -genkey -v -keystore ~/plombipro-release-key.keystore \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias release -dname "CN=Your Name, O=Your Company, C=FR"

# Export public key (for backup)
keytool -export -rfc -alias release \
    -file ~/plombipro-public-key.pem \
    -keystore ~/plombipro-release-key.keystore
```

### Step 5: Build Release APK

```bash
# Set environment variables
export KEY_ALIAS=release
export KEY_PASSWORD=your_key_password
export KEYSTORE_PATH=$HOME/plombipro-release-key.keystore
export KEYSTORE_PASSWORD=your_keystore_password

# Build APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (for Google Play)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Step 6: Google Play Configuration

**Create Play Store Entry:**
```
1. Log in to https://play.google.com/console
2. All apps → Create app
3. Name: PlombiPro
4. Default language: French
5. App category: Business
6. Create
```

**Set up Store Listing:**
```
1. Store listing → All languages → French
2. Short description (80 chars):
   "Facturation & Gestion pour plombiers français"

3. Full description (4000 chars):
   "PlombiPro : Logiciel de facturation pour plombiers
   - Devis & Factures digitales
   - Scanner OCR pour factures fournisseurs
   - Paiements Stripe
   - Signatures électroniques
   - Conforme 2026 (Factur-X)
   - Support français 24/7"

4. Screenshots (5):
   - Dashboard
   - Devis
   - Factures
   - Scanner OCR
   - Paiements

5. Feature Graphic (1024x500):
   - Design professional showing app benefits

6. Video preview: YouTube URL (optional)
```

**Configure Pricing & Distribution:**
```
1. Pricing & Distribution → Free
2. Countries: Select France + EU
3. Content rating:
   - Government approvals: None
   - Medical: No
   - Violence: No
   - Adult content: No
   - Rating: 3+
```

**Upload Build:**
```
1. Release management → App releases → Production
2. Upload app-release.aab
3. Fill in release notes:
   "Version initiale PlombiPro
   - Facturation digitale
   - Scanner OCR
   - Paiements intégrés"
4. Review & Publish
```

---

## 🤖 EXACT FLUTTERFLOW AI PROMPTS

### Prompt 1: HomePage/Dashboard

```
Create a professional Flutter dashboard page with Material Design 3:

LAYOUT:
- SafeArea with Scaffold
- AppBar (title: "PlombiPro", color: #1976D2)
- Drawer: Sidebar navigation menu
- Body: CustomScrollView with SliverAppBar

CONTENT SECTIONS:

1. STICKY HEADER:
   - SliverAppBar with: "Bonjour [User Name]"
   - Subtitle: Company name
   - Centered date

2. STAT CARDS (2x2 Grid):
   Card 1: "CA du mois (HT): 12,450€" (blue card)
   Card 2: "Factures impayées: 3 (2,100€)" (orange card)
   Card 3: "Devis en attente: 2" (purple card)
   Card 4: "RDV aujourd'hui: 1" (green card)
   
   Each card shows:
   - Icon (top right)
   - Title (14px, bold)
   - Value (18px, bold, appropriate color)
   - Subtitle "que hier" or "change" in smaller text

3. RECENT ACTIVITY SECTION:
   - Title: "Activité récente"
   - Horizontal scrollable ListView with 5 cards
   - Each card shows: Quote/Invoice number, Client name, Amount (€), Date
   - Cards are 280px wide

4. QUICK ACTIONS (4 buttons in Wrap):
   - "+ Nouveau devis" (primary color)
   - "+ Nouvelle facture" (primary color)
   - "📸 Scanner facture" (secondary color)
   - "📞 Contacter client" (secondary color)

STYLING:
- Material Design 3 with blue primary (#1976D2)
- Border radius 12dp
- Shadows 1-2 elevation
- Responsive: Mobile 1 col, Tablet 2 col, Desktop full layout
- French language for all labels
- Bottom padding 32dp

INTERACTIVITY:
- Tap stat card: Navigate to relevant list page
- Tap activity card: Navigate to detail page
- Tap action button: Navigate to form page or start new workflow
- Pull to refresh: Reload dashboard data
```

### Prompt 2: QuotesListPage

```
Create a professional Quotes list page:

STRUCTURE:
- SafeArea with Scaffold
- AppBar: "Mes Devis" with search icon
- Body: Column with ListView

SEARCH & FILTER BAR:
- TextField: "Rechercher par client ou numéro"
- Below: Horizontal chip filters (clickable):
  Chip 1: "Tous" (selected = blue background)
  Chip 2: "Brouillon"
  Chip 3: "Envoyés"
  Chip 4: "Acceptés"
  Chip 5: "Rejetés"

QUOTE LIST (ListView.builder):
Each QuoteCard item:

LEFT SECTION (Expanded):
- Row 1: "DEV-2025-001" (bold, 14px) + StatusBadge aligned right
  StatusBadge colors:
  - Brouillon: Gray
  - Envoyé: Blue
  - Accepté: Green
  - Rejeté: Red
  - Facturé: Purple
- Row 2: Client name (12px gray)
- Row 3 (8px space)
- Row 4: Date "15 jan" + "1,250€" (bold, 14px) aligned right

DIVIDER between items

INTERACTIVE:
- Card tap: Navigate to QuoteDetailPage
- Long press / PopupMenuButton (3-dot menu):
  Options: "Voir", "Éditer", "Télécharger PDF", "Envoyer par email", "Supprimer"

EMPTY STATE:
- When no quotes: Show centered icon (document), text "Aucun devis"
- Button below: "Créer mon premier devis"

FAB: Bottom right "➕ Nouveau devis" → QuoteFormPage

FEATURES:
- Pull to refresh enabled
- Lazy loading if 100+ quotes
- Search filters in real-time
- Status badge color-coded
- French localization
```

### Prompt 3: QuoteFormPage (Complex Multi-Section Form)

```
Create advanced Quote form with Material Design 3:

STRUCTURE:
- Scaffold with AppBar: "Nouveau Devis" or "Éditer Devis"
- Body: Form with ListView (can scroll)
- FloatingActionButton: Save

SECTIONS (in order):

========== SECTION 1: CLIENT SELECTION ==========
- SectionHeader widget: "Client" with optional "Ajouter" button
- SearchableDropdown/Autocomplete:
  * TextField with icon (search)
  * As user types: show filtered list of existing clients
  * Each list item: ClientName | Email | Phone
  * Bottom item: "+ Créer nouveau client"
  * On select: populate client details

========== SECTION 2: DATES ==========
- SectionHeader: "Dates"
- Row with 2 DatePickers side by side:
  Picker 1: "Date du devis" (default: today)
  Picker 2: "Valide jusqu'au" (default: today + 30 days)
  On date change: update calculations

========== SECTION 3: LINE ITEMS ==========
- SectionHeader: "Lignes de devis"
- ListView of LineItemRow widgets (one per item)
  Each row is a Card with:
  
  Row 1 - Product autocomplete:
  * TextField with autocomplete from products table
  * As type: show product list (Name | SKU | Price)
  * On select: auto-fill Description, UnitPrice
  * Option to create custom item (no product)
  
  Row 2 - Three fields in a Row:
  * Qty field (decimal input, up to 3 decimals)
  * UnitPrice field (€ prefix, editable)
  * Discount % field (0-100)
  
  Row 3 - Auto-calculated totals:
  * "Total HT: 250€" (read-only, gray)
  
  Row 4 - Delete button:
  * Trash icon, red color, right-aligned

- "+ Ajouter ligne" button below last item
  On press: add new empty LineItemRow

========== SECTION 4: CALCULATIONS (Card) ==========
- Card with blue background (light):
  Row 1: "Total HT" | "1,000€" (right-aligned)
  Row 2: "TVA (20%)" | "200€" (right-aligned)
  Divider line
  Row 3: "Total TTC" | "1,200€" (bold, 16px, right-aligned)
  Divider line
  Row 4: "Acompte (30%)" | "360€" (small text)
  
  TVA % is a Dropdown selector: 5.5%, 10%, 20% (standard French rates)
  All calculations auto-update on line item change

========== SECTION 5: NOTES & OPTIONS ==========
- SectionHeader: "Informations supplémentaires"
- TextField (multiline): "Notes (description, conditions, etc.)"
- Checkbox: "Demander signature du client"
- Checkbox: "Envoyer par email après création"

========== SECTION 6: ACTION BUTTONS ==========
- Full-width Row with 2 buttons:
  Button 1: OutlinedButton "Annuler" (gray) → Pop navigation
  Button 2: ElevatedButton "Enregistrer" (blue) → Save & navigate

- Second row (8px below):
  Button 1: OutlinedButton "Télécharger PDF"
  Button 2: ElevatedButton "Envoyer par email"

VALIDATIONS:
- Quote number auto-generated (DEV-YYYY-NNN)
- At least 1 line item required
- Client required
- All prices must be positive
- Dates must be valid (valid_until > issue_date)

STYLING:
- Material Design 3 with blue theme
- Card elevation 1
- Border radius 12
- Spacing 16dp between sections
- Responsive (mobile optimized)
- French labels only
- Currency formatting with € symbol
- Loading state while saving

DATA FLOW:
- On load: if editing, populate form with existing quote data
- On save: POST to Supabase, generate auto-numbers, save line items
- On success: Show snackbar "Devis enregistré", navigate to detail page
- On error: Show error snackbar with retry button
```

### Prompt 4: ScanInvoicePage (OCR)

```
Create OCR Invoice scanning page:

STRUCTURE:
- SafeArea with Scaffold
- AppBar: "Scanner une facture"
- Body: SingleChildScrollView → Column

========== SECTION 1: IMAGE CAPTURE ==========
- SectionHeader: "Étape 1: Capturer l'image"
- Card:
  IF no image:
    * Icon (camera, large)
    * Text: "Prendre une photo ou importer une image"
    * Row with 2 buttons:
      - "📷 Caméra" → opens camera
      - "📁 Galerie" → opens file picker
  
  IF image selected:
    * Image preview (400x300)
    * Below: "Retirer image" button (trash icon)
    * "Modifier" button (edit icon)

========== SECTION 2: OCR PROCESSING ==========
- Center(
    ElevatedButton(
      label: "🔄 Analyser avec OCR",
      enabled: image != null,
      color: blue
    )
  )

- IF loading:
  * LinearProgressIndicator with % (0-100%)
  * Text: "Traitement en cours... 45%"
  * Text: "Extraction des données..." (smaller, gray)

========== SECTION 3: OCR RESULTS ==========
IF result != null:

- SectionHeader: "Étape 2: Résultats"
- Card with results:
  
  Row 1: "Fournisseur"
  * Editable TextField with current value
  
  Row 2: "Montant"
  * Editable CurrencyField with € prefix
  
  Row 3: "Confiance"
  * LinearProgressIndicator (color-coded):
    - Green: > 85% (excellent)
    - Amber: 65-85% (bon)
    - Red: < 65% (faible)
  * Text: "85% confiance" right-aligned
  
  Divider
  
  Row 4: "Lignes détectées:"
  * ListView of detected line items:
    - ListTile with:
      * Description (primary text, editable)
      * Qty × Price (secondary text)
    - Each item has delete button (red)
  * "+ Ajouter ligne" button

========== SECTION 4: VERIFICATION ==========
- SectionHeader: "Vérifier les données"
- Row:
  * Icon: Check (green circle)
  * Text: "Les données sont correctes?"
  * 2 buttons: "Non" (outline) | "Oui" (filled)

IF verified:
  ========== SECTION 5: CREATE INVOICE ==========
  - SectionHeader: "Étape 3: Créer facture"
  - Text: "Une facture fournisseur sera créée avec les données détectées"
  - Row with buttons:
    * "Annuler" (outline) → pop
    * "Créer facture" (filled, blue) → create invoice

ERROR STATES:
- If confidence < 40%: Show warning "Confiance très faible, vérifiez les données"
- If no items detected: "Aucune ligne détectée, ajoutez manuellement"
- If OCR fails: "Erreur OCR, réessayez avec meilleure qualité d'image"

STYLING:
- Material Design 3
- French labels only
- Currency formatting (€)
- Color-coded confidence indicators
- Smooth transitions between sections
- Loading animation (spinner)
```

### Prompt 5: Custom AppDrawer (Sidebar)

```
Create Material Design 3 sidebar menu/drawer:

HEADER (top):
- UserAccountsDrawerHeader with:
  * Blue background (#1976D2)
  * User initials avatar (large circle)
  * Current user email
  * Company name (if available)

MENU SECTIONS (Below header):

SECTION 1 (no title):
- ListTile: "🏠 ACCUEIL" → navigate /home

SECTION 2 "FACTURATION":
- ListTile: "📝 Mes Devis" → navigate /quotes
- ListTile: "🧾 Mes Factures" → navigate /invoices
- ListTile: "💳 Paiements & Relances" → navigate /payments

SECTION 3 "CATALOGUES & PRODUITS":
- ListTile: "🔍 Rechercher produit" → navigate /products
- ListTile: "⭐ Mes favoris" → navigate /favorites
- ListTile: "📥 Importer catalogue" → navigate /import-catalog
- ListTile: "📊 Stats usage" → navigate /product-stats

SECTION 4 "MES ACHATS":
- ListTile: "📋 Bons de commande" → navigate /orders
- ListTile: "🧾 Factures fournisseurs" → navigate /supplier-invoices
- ListTile: "🏪 Mes fournisseurs" → navigate /suppliers

SECTION 5 "MES CHANTIERS":
- ListTile: "📅 Calendrier" → navigate /calendar
- ListTile: "📊 Chantiers en cours" → navigate /worksites
- ListTile: "✍️ Signature client" → navigate /signatures
- ListTile: "📁 Historique" → navigate /worksite-history

SECTION 6 "MES CLIENTS":
- ListTile: "📇 Liste clients" → navigate /clients
- ListTile: "📞 Communication" → navigate /communication
- ListTile: "⚠️ Réclamations" → navigate /complaints

SECTION 7 "MON ENTREPRISE":
- ListTile: "⚙️ Paramètres" → navigate /settings
- ListTile: "📊 Comptabilité" → navigate /accounting
- ListTile: "🌐 Présence en ligne" → navigate /online-presence

SECTION 8 "MON PROFIL":
- ListTile: "📋 Mes infos" → navigate /profile
- ListTile: "💳 Abonnement" → navigate /subscription
- ListTile: "📈 Statistiques" → navigate /user-statistics
- ListTile: "🆘 Aide & Contact" → navigate /help

FOOTER (bottom):
- Divider
- ListTile: "🚪 Déconnexion" → signOut() → navigate /login

STYLING:
- Material Design 3
- Primary color: #1976D2 (blue)
- Selected item: light blue background + blue text
- Icons before text (all items)
- Section headers: small caps, gray text
- Leading icon color: dark gray
- Responsive width (280dp on mobile, up to 320 on tablet)
- French language only

FUNCTIONALITY:
- Close drawer on item select (Navigator.pop)
- Highlight currently selected section
- No nested items (flat structure)
```

---

## 📝 FINAL DEPLOYMENT CHECKLIST

### Pre-Release QA (1 week before)

- [ ] All 20 pages created and tested
- [ ] All CRUD operations working (Create, Read, Update, Delete)
- [ ] Authentication (login/logout) fully functional
- [ ] PDF generation tested with 10+ invoices
- [ ] OCR scanning tested with 20+ real invoices
- [ ] Stripe payment in sandbox mode successful
- [ ] Email notifications sending correctly
- [ ] Calculations (HT, TVA, TTC) verified
- [ ] French localization complete
- [ ] Responsive design tested: Mobile 360px, Tablet 768px, Desktop 1440px
- [ ] No console errors or warnings
- [ ] Performance: App launch < 2s, list load < 1s
- [ ] Offline mode tested (read cache works)
- [ ] Navigation stack proper (no lost states)
- [ ] Error handling for all network calls
- [ ] Timeout handling (30s default)
- [ ] Image compression for photos (max 2MB)
- [ ] Database indexes created for fast queries
- [ ] RLS policies tested (user isolation works)
- [ ] Security audit: No hardcoded secrets

### iOS Release Checklist

- [ ] Xcode build succeeds (no warnings)
- [ ] TestFlight upload successful
- [ ] 5 internal testers invited
- [ ] 3-day TestFlight review period
- [ ] Fix any crashes reported
- [ ] Icon 1024x1024 PNG created
- [ ] App Store preview images (5) ready
- [ ] App description in French complete
- [ ] Keywords optimized
- [ ] Privacy policy URL set
- [ ] Support URL set
- [ ] Pricing: Free
- [ ] Age rating: 4+
- [ ] App Store submit for review
- [ ] Wait 24-48hrs for review
- [ ] Monitor rejection reasons
- [ ] Fix and resubmit if needed

### Android Release Checklist

- [ ] Flutter build appbundle succeeds
- [ ] Signing configured & tested
- [ ] Play Store entry created
- [ ] Store listing complete (FR)
- [ ] Icon 512x512 PNG created
- [ ] Screenshots (5) uploaded
- [ ] Feature graphic 1024x500 PNG ready
- [ ] Pricing: Free
- [ ] Countries: France + EU selected
- [ ] Content rating: 3+
- [ ] Release notes in French
- [ ] First internal test build uploaded
- [ ] Internal testing 3 days minimum
- [ ] Move to beta when ready
- [ ] Beta testing 1 week
- [ ] Move to production when validated
- [ ] Monitor crash rates (target < 0.1%)

---

**DEPLOYMENT COMPLETE GUIDE READY! 🚀**

All platforms configured and ready for submission.