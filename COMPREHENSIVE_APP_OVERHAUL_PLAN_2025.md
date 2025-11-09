# 🚀 PLOMBIPRO MOBILE APP - COMPREHENSIVE OVERHAUL PLAN 2025
## Complete Transformation Roadmap Based on Competitive Analysis & Codebase Audit

**Created:** November 9, 2025
**Status:** Master Implementation Plan
**Timeline:** 6 months for full transformation
**Priority Levels:** 🔴 CRITICAL | 🟡 HIGH | 🟢 MEDIUM | 🔵 LOW

---

## 📊 EXECUTIVE SUMMARY

### Current State Assessment
- **Code Quality:** B+ (Good foundation, incomplete features)
- **Feature Completeness:** 65% (MVP with significant gaps)
- **Competitive Readiness:** NOT READY (Missing 10+ critical features)
- **UI/UX Quality:** Decent but outdated compared to website 2.0
- **Performance:** Acceptable for MVP, needs optimization

### Target State Goals
- **Code Quality:** A (Production-ready, scalable architecture)
- **Feature Completeness:** 95% (Market-leading feature set)
- **Competitive Readiness:** FULLY READY (Feature parity + unique advantages)
- **UI/UX Quality:** Exceptional (Website 2.0 design language)
- **Performance:** Excellent (Optimized for scale)

### Key Objectives
1. ✅ Fix all placeholder/mock implementations
2. ✅ Implement 10 critical missing features from competitive analysis
3. ✅ Complete UI/UX transformation with website 2.0 design system
4. ✅ Establish scalable state management architecture
5. ✅ Optimize performance for 1,000+ users
6. ✅ Achieve feature parity with top competitors

---

## 📋 TABLE OF CONTENTS

### PHASE 1: IMMEDIATE FIXES & FOUNDATION (Weeks 1-2)
1. [Critical Bug Fixes](#phase-1-critical-bug-fixes)
2. [Design System Foundation](#phase-1-design-system)
3. [Core Component Library](#phase-1-components)

### PHASE 2: STATE MANAGEMENT & ARCHITECTURE (Weeks 3-4)
4. [Riverpod Implementation](#phase-2-state-management)
5. [Service Layer Refactor](#phase-2-services)
6. [Performance Optimization](#phase-2-performance)

### PHASE 3: CRITICAL FEATURE IMPLEMENTATION (Weeks 5-10)
7. [Electronic Signature](#phase-3-esignature)
8. [Recurring Invoices](#phase-3-recurring)
9. [Progress Invoices](#phase-3-progress)
10. [Client Portal](#phase-3-client-portal)
11. [Bank Reconciliation](#phase-3-bank-reconciliation)

### PHASE 4: OCR & CATALOG OPTIMIZATION (Weeks 11-13)
12. [OCR System Completion](#phase-4-ocr)
13. [Supplier Catalog Integration](#phase-4-catalogs)
14. [Hydraulic Calculator Real Implementation](#phase-4-calculator)

### PHASE 5: ADVANCED FEATURES (Weeks 14-18)
15. [Multi-User/Team Support](#phase-5-multiuser)
16. [Offline Mode](#phase-5-offline)
17. [Advanced Analytics](#phase-5-analytics)
18. [Template System](#phase-5-templates)

### PHASE 6: UI/UX TRANSFORMATION (Weeks 19-22)
19. [Screen Redesigns](#phase-6-redesigns)
20. [Animations & Micro-interactions](#phase-6-animations)
21. [Onboarding Overhaul](#phase-6-onboarding)

### PHASE 7: POLISH & LAUNCH PREP (Weeks 23-26)
22. [Testing Suite](#phase-7-testing)
23. [Performance Optimization](#phase-7-optimization)
24. [App Store Preparation](#phase-7-appstore)

---

# PHASE 1: IMMEDIATE FIXES & FOUNDATION
## 🔴 Weeks 1-2 | Critical Priority

<a name="phase-1-critical-bug-fixes"></a>
## 1.1 CRITICAL BUG FIXES (2 days) 🔴

### 1.1.1 Remove Mock Appointment Data
**File:** `/lib/services/supabase_service.dart` (lines 29-74)
**Issue:** Hardcoded fake appointment data in production code
**Impact:** Users see fake data, database not used properly

**Tasks:**
- [ ] Create `appointments` table in Supabase
  ```sql
  CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    client_id UUID REFERENCES clients(id),
    job_site_id UUID REFERENCES job_sites(id),
    title TEXT NOT NULL,
    description TEXT,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    location TEXT,
    status TEXT DEFAULT 'scheduled',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
  );

  CREATE INDEX idx_appointments_user_id ON appointments(user_id);
  CREATE INDEX idx_appointments_start_time ON appointments(start_time);

  ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

  CREATE POLICY "Users can view own appointments"
    ON appointments FOR SELECT
    USING (auth.uid() = user_id);

  CREATE POLICY "Users can manage own appointments"
    ON appointments FOR ALL
    USING (auth.uid() = user_id);
  ```

- [ ] Replace mock data fetching with real query
  ```dart
  // In supabase_service.dart
  static Future<List<Map<String, dynamic>>> fetchUpcomingAppointments({int limit = 5}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await Supabase.instance.client
        .from('appointments')
        .select('''
          *,
          clients (
            full_name,
            company_name
          ),
          job_sites (
            name,
            address
          )
        ''')
        .eq('user_id', userId)
        .gte('start_time', DateTime.now().toIso8601String())
        .order('start_time', ascending: true)
        .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      ErrorService.handleError('fetchUpcomingAppointments', e);
      return [];
    }
  }
  ```

- [ ] Add appointment CRUD methods to SupabaseService
  ```dart
  static Future<bool> createAppointment(Map<String, dynamic> appointmentData) async { ... }
  static Future<bool> updateAppointment(String id, Map<String, dynamic> updates) async { ... }
  static Future<bool> deleteAppointment(String id) async { ... }
  static Future<Map<String, dynamic>?> getAppointment(String id) async { ... }
  ```

- [ ] Update `home_page.dart` to use real appointments
- [ ] Create appointment management screen (`/lib/screens/appointments/`)

**Estimated Time:** 2 days
**Dependencies:** None
**Success Criteria:** Real appointments displayed on home screen

---

### 1.1.2 Fix Hydraulic Calculator Placeholder Logic
**File:** `/lib/screens/tools/hydraulic_calculator_page.dart` (lines 26-29)
**Issue:** Hardcoded results instead of real calculations
**Impact:** Tool is non-functional, damages credibility

**Tasks:**
- [ ] Implement real hydraulic formulas
  ```dart
  class HydraulicCalculations {
    // Hazen-Williams equation for pressure loss
    static double calculatePressureLoss({
      required double flowRate,        // L/min
      required double pipeLength,      // meters
      required double pipeDiameter,    // mm
      required double roughness,       // C coefficient (100-150)
    }) {
      // Convert units
      final Q = flowRate / 60000;  // Convert to m³/s
      final D = pipeDiameter / 1000;  // Convert to meters
      final C = roughness;

      // Hazen-Williams formula
      // hL = (10.67 * L * Q^1.852) / (C^1.852 * D^4.87)
      final hL = (10.67 * pipeLength * pow(Q, 1.852)) /
                 (pow(C, 1.852) * pow(D, 4.87));

      // Convert to bar (1 meter of head = 0.0980665 bar)
      return hL * 0.0980665;
    }

    // Recommend pipe diameter based on flow rate
    static double recommendPipeDiameter({
      required double flowRate,        // L/min
      required double maxVelocity,     // m/s (typically 1.5-2.5)
    }) {
      final Q = flowRate / 60000;  // Convert to m³/s

      // Area = Q / V
      final area = Q / maxVelocity;

      // Diameter = sqrt(4 * Area / pi)
      final diameter = sqrt((4 * area) / pi) * 1000;  // Convert to mm

      // Round to nearest standard pipe size
      return _roundToStandardPipeSize(diameter);
    }

    static double _roundToStandardPipeSize(double diameter) {
      const standardSizes = [12, 16, 20, 25, 32, 40, 50, 63, 75, 90, 110, 125, 160, 200, 250];

      for (int i = 0; i < standardSizes.length; i++) {
        if (diameter <= standardSizes[i]) {
          return standardSizes[i].toDouble();
        }
      }

      return standardSizes.last.toDouble();
    }

    // Calculate flow velocity
    static double calculateVelocity({
      required double flowRate,        // L/min
      required double pipeDiameter,    // mm
    }) {
      final Q = flowRate / 60000;  // Convert to m³/s
      final D = pipeDiameter / 1000;  // Convert to meters
      final area = pi * pow(D / 2, 2);

      return Q / area;  // m/s
    }
  }
  ```

- [ ] Update UI with real calculation results
  ```dart
  void _calculatePipeDiameter() {
    if (_flowRateController.text.isEmpty) return;

    final flowRate = double.tryParse(_flowRateController.text);
    if (flowRate == null) return;

    setState(() {
      _isCalculating = true;
    });

    // Simulate brief calculation delay for UX
    Future.delayed(Duration(milliseconds: 300), () {
      final recommended = HydraulicCalculations.recommendPipeDiameter(
        flowRate: flowRate,
        maxVelocity: 2.0,  // Standard for potable water
      );

      final pressureLoss = HydraulicCalculations.calculatePressureLoss(
        flowRate: flowRate,
        pipeLength: _pipeLengthController.text.isNotEmpty
          ? double.parse(_pipeLengthController.text)
          : 10.0,
        pipeDiameter: recommended,
        roughness: 130.0,  // PVC/Copper standard
      );

      final velocity = HydraulicCalculations.calculateVelocity(
        flowRate: flowRate,
        pipeDiameter: recommended,
      );

      setState(() {
        _recommendedPipeDiameter = recommended;
        _pressureLoss = pressureLoss;
        _velocity = velocity;
        _isCalculating = false;
      });
    });
  }
  ```

- [ ] Add input validation
- [ ] Add unit conversion options (L/min ↔ m³/h)
- [ ] Add material selection (PVC, Copper, PER, etc.)
- [ ] Add results explanation text
- [ ] Save calculation history

**Estimated Time:** 3 days
**Dependencies:** None
**Success Criteria:** Accurate hydraulic calculations with professional results

---

### 1.1.3 Fix Supplier Catalog Empty Pages
**File:** `/lib/screens/products/scraped_catalog_page.dart`
**Issue:** Point P and Cedeo catalog pages show empty lists
**Impact:** Unique selling point not delivering value

**Tasks:**
- [ ] Verify cloud function scrapers are deployed and running
  ```bash
  # Check cloud functions status
  gcloud functions list --filter="name:(scraper-point-p OR scraper-cedeo)"

  # Test scrapers manually
  gcloud functions call scraper-point-p --data '{}'
  gcloud functions call scraper-cedeo --data '{}'
  ```

- [ ] Create `supplier_products` table if missing
  ```sql
  CREATE TABLE supplier_products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier TEXT NOT NULL,  -- 'point_p' or 'cedeo'
    reference TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    subcategory TEXT,
    price NUMERIC(10, 2),
    unit TEXT,
    image_url TEXT,
    url TEXT,
    in_stock BOOLEAN DEFAULT true,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT now(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(supplier, reference)
  );

  CREATE INDEX idx_supplier_products_supplier ON supplier_products(supplier);
  CREATE INDEX idx_supplier_products_category ON supplier_products(category);
  CREATE INDEX idx_supplier_products_name ON supplier_products USING gin(to_tsvector('french', name));

  ALTER TABLE supplier_products ENABLE ROW LEVEL SECURITY;

  -- Allow public read for all users
  CREATE POLICY "Anyone can read supplier products"
    ON supplier_products FOR SELECT
    USING (true);
  ```

- [ ] Set up scheduled scraper runs
  ```yaml
  # In cloud_functions/scheduler.yaml
  - name: scrape-point-p-daily
    schedule: "0 2 * * *"  # 2 AM daily
    function: scraper-point-p

  - name: scrape-cedeo-daily
    schedule: "0 3 * * *"  # 3 AM daily
    function: scraper-cedeo
  ```

- [ ] Implement search and filter in catalog page
  ```dart
  Future<List<Map<String, dynamic>>> searchSupplierProducts({
    required String supplier,
    String? searchQuery,
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = Supabase.instance.client
      .from('supplier_products')
      .select()
      .eq('supplier', supplier)
      .order('name', ascending: true);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.textSearch('name', searchQuery, config: 'french');
    }

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    query = query.range(offset, offset + limit - 1);

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }
  ```

- [ ] Add pagination for large catalogs
- [ ] Implement product detail view
- [ ] Add "Add to Quote" quick action from catalog

**Estimated Time:** 2 days
**Dependencies:** Cloud functions verification
**Success Criteria:** Both catalogs display real product data with search/filter

---

### 1.1.4 Fix OCR Non-Functional Flow
**File:** `/lib/screens/ocr/scan_invoice_page.dart`
**Issue:** OCR extracts text but doesn't generate quote automatically
**Impact:** Key differentiator doesn't work end-to-end

**Tasks:**
- [ ] Update OCR cloud function to return structured data
  ```python
  # cloud_functions/ocr_processor/main.py
  from google.cloud import vision
  import re

  def process_invoice_ocr(request):
      # ... existing OCR extraction ...

      # Parse structured data
      invoice_data = {
          'supplier': detect_supplier(text),
          'invoice_number': extract_invoice_number(text),
          'date': extract_date(text),
          'total_amount': extract_total(text),
          'items': extract_line_items(text)
      }

      return {
          'success': True,
          'raw_text': text,
          'structured_data': invoice_data,
          'confidence': calculate_confidence(invoice_data)
      }

  def detect_supplier(text):
      suppliers = {
          'point_p': ['point p', 'pointp', 'point.p'],
          'cedeo': ['cedeo', 'cédéo'],
          'leroy_merlin': ['leroy merlin'],
          'castorama': ['castorama'],
      }

      text_lower = text.lower()
      for supplier, patterns in suppliers.items():
          for pattern in patterns:
              if pattern in text_lower:
                  return supplier

      return 'unknown'

  def extract_line_items(text):
      items = []
      # Parse line items with regex patterns
      # Pattern: [reference] [description] [quantity] [unit price] [total]
      pattern = r'(\w+)\s+([\w\s]+?)\s+(\d+)\s+([\d,\.]+)\s+€\s+([\d,\.]+)\s+€'

      matches = re.finditer(pattern, text)
      for match in matches:
          items.append({
              'reference': match.group(1),
              'description': match.group(2).strip(),
              'quantity': int(match.group(3)),
              'unit_price': float(match.group(4).replace(',', '.')),
              'total': float(match.group(5).replace(',', '.'))
          })

      return items
  ```

- [ ] Update app to handle structured OCR response
  ```dart
  Future<void> _processScan(File imageFile) async {
    setState(() => _isProcessing = true);

    try {
      // Upload image to storage
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = await SupabaseService.uploadScan(imageFile, fileName);

      // Call OCR cloud function
      final response = await SupabaseService.processOCR(path);

      if (response['success'] && response['structured_data'] != null) {
        final structuredData = response['structured_data'];

        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => OCRConfirmationDialog(
            supplierName: structuredData['supplier'],
            items: structuredData['items'],
            total: structuredData['total_amount'],
          ),
        );

        if (confirmed == true) {
          // Create quote from OCR data
          await _createQuoteFromOCR(structuredData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Devis créé à partir du scan!')),
          );

          // Navigate to quote
          context.go('/quotes');
        }
      } else {
        // Show manual entry option
        _showManualEntryDialog(response['raw_text']);
      }
    } catch (e) {
      ErrorService.handleError('OCR Processing', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du scan. Réessayez.')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _createQuoteFromOCR(Map<String, dynamic> ocrData) async {
    // Create quote with extracted data
    final quoteData = {
      'title': 'Devis - ${ocrData['supplier']} - ${DateTime.now().toString().substring(0, 10)}',
      'status': 'draft',
      'client_id': null,  // User will select later
      'items': ocrData['items'].map((item) => {
        'description': item['description'],
        'quantity': item['quantity'],
        'unit_price': item['unit_price'],
        'vat_rate': 20.0,  // Default, user can change
        'reference': item['reference'],
      }).toList(),
      'notes': 'Créé automatiquement depuis un scan OCR (${ocrData['supplier']})',
    };

    await SupabaseService.createQuote(quoteData);
  }
  ```

- [ ] Create OCR confirmation dialog widget
- [ ] Add manual correction UI for low-confidence items
- [ ] Implement supplier product matching (link scanned items to catalog)
- [ ] Add scan history view

**Estimated Time:** 5 days
**Dependencies:** Cloud function update
**Success Criteria:** Complete OCR → Quote flow with <2 minutes total time

---

<a name="phase-1-design-system"></a>
## 1.2 DESIGN SYSTEM FOUNDATION (3 days) 🔴

### 1.2.1 Create Comprehensive Color System
**New File:** `/lib/config/plombipro_colors.dart`

**Tasks:**
- [ ] Define all brand colors from website 2.0
  ```dart
  import 'package:flutter/material.dart';

  class PlombiProColors {
    // PRIMARY COLORS
    static const Color primary = Color(0xFF1976D2);        // Blue
    static const Color primaryDark = Color(0xFF1565C0);    // Blue Dark
    static const Color primaryLight = Color(0xFF64B5F6);   // Blue Light
    static const Color primaryLightest = Color(0xFFE3F2FD); // Blue Lightest

    // SECONDARY/ACCENT COLORS
    static const Color secondary = Color(0xFFFF6F00);      // Orange
    static const Color secondaryDark = Color(0xFFE65100);  // Orange Dark
    static const Color secondaryLight = Color(0xFFFFA726); // Orange Light

    // SUCCESS/ERROR/WARNING
    static const Color success = Color(0xFF4CAF50);
    static const Color error = Color(0xFFE53935);
    static const Color warning = Color(0xFFFFC107);
    static const Color info = Color(0xFF2196F3);

    // NEUTRAL GRAYS
    static const Color gray50 = Color(0xFFF9FAFB);
    static const Color gray100 = Color(0xFFF3F4F6);
    static const Color gray200 = Color(0xFFE5E7EB);
    static const Color gray300 = Color(0xFFD1D5DB);
    static const Color gray400 = Color(0xFF9CA3AF);
    static const Color gray500 = Color(0xFF6B7280);
    static const Color gray600 = Color(0xFF4B5563);
    static const Color gray700 = Color(0xFF374151);
    static const Color gray800 = Color(0xFF1F2937);
    static const Color gray900 = Color(0xFF111827);

    // BACKGROUND
    static const Color background = Colors.white;
    static const Color foreground = Color(0xFF1F2937);

    // GRADIENTS
    static const Gradient primaryGradient = LinearGradient(
      colors: [
        Color(0xFF1976D2),
        Color(0xFF1565C0),
        Color(0xFF0D47A1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    static const Gradient ctaGradient = LinearGradient(
      colors: [
        Color(0xFFFF6F00),
        Color(0xFFE65100),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    static const Gradient successGradient = LinearGradient(
      colors: [
        Color(0xFF4CAF50),
        Color(0xFF388E3C),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    static const Gradient heroGradient = LinearGradient(
      colors: [
        Color(0xFF1976D2),
        Color(0xFF1565C0),
        Color(0xFF0D47A1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.5, 1.0],
    );

    // OVERLAY COLORS
    static Color overlay(double opacity) => Colors.black.withOpacity(opacity);
    static Color primaryOverlay(double opacity) => primary.withOpacity(opacity);
    static Color secondaryOverlay(double opacity) => secondary.withOpacity(opacity);
  }
  ```

- [ ] Update app_theme.dart to use new color system
  ```dart
  import 'plombipro_colors.dart';

  class AppTheme {
    static ThemeData lightTheme() {
      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: PlombiProColors.primary,
          primaryContainer: PlombiProColors.primaryLight,
          secondary: PlombiProColors.secondary,
          secondaryContainer: PlombiProColors.secondaryLight,
          error: PlombiProColors.error,
          background: PlombiProColors.background,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onError: Colors.white,
          onBackground: PlombiProColors.foreground,
          onSurface: PlombiProColors.foreground,
        ),

        scaffoldBackgroundColor: PlombiProColors.gray50,

        // ... rest of theme config
      );
    }
  }
  ```

**Estimated Time:** 1 day
**Dependencies:** None
**Success Criteria:** Consistent colors throughout app

---

### 1.2.2 Typography System
**New File:** `/lib/config/plombipro_text_styles.dart`

**Tasks:**
- [ ] Define complete text style hierarchy
  ```dart
  import 'package:flutter/material.dart';
  import 'plombipro_colors.dart';

  class PlombiProTextStyles {
    // HERO TEXT (Largest, for hero sections)
    static const TextStyle hero = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 1.2,
      letterSpacing: -0.5,
      color: PlombiProColors.foreground,
    );

    // HEADINGS
    static const TextStyle heading1 = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: PlombiProColors.foreground,
    );

    static const TextStyle heading2 = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: PlombiProColors.foreground,
    );

    static const TextStyle heading3 = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: PlombiProColors.foreground,
    );

    // BODY TEXT
    static const TextStyle body = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: PlombiProColors.foreground,
    );

    static const TextStyle bodyBold = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: PlombiProColors.foreground,
    );

    // CAPTION/SMALL TEXT
    static const TextStyle caption = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: PlombiProColors.gray600,
    );

    static const TextStyle captionBold = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: PlombiProColors.gray700,
    );

    // LABELS
    static const TextStyle label = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: PlombiProColors.gray600,
    );

    static const TextStyle labelBold = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1.4,
      color: PlombiProColors.gray700,
    );

    // BUTTON TEXT
    static const TextStyle button = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: Colors.white,
    );

    static const TextStyle buttonSmall = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: Colors.white,
    );

    // NUMERIC (for prices, amounts)
    static const TextStyle numeric = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: PlombiProColors.foreground,
    );

    static const TextStyle numericLarge = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 1.1,
      color: PlombiProColors.foreground,
    );

    // GRADIENT TEXT (for special emphasis)
    static TextStyle gradientText({
      required Gradient gradient,
      double fontSize = 32,
      FontWeight fontWeight = FontWeight.w800,
    }) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        foreground: Paint()
          ..shader = gradient.createShader(
            Rect.fromLTWH(0, 0, 200, 70),
          ),
      );
    }
  }
  ```

**Estimated Time:** 0.5 days
**Dependencies:** PlombiProColors
**Success Criteria:** Consistent typography throughout app

---

### 1.2.3 Spacing & Layout Constants
**New File:** `/lib/config/plombipro_spacing.dart`

**Tasks:**
- [ ] Define spacing system (8px grid)
  ```dart
  class Spacing {
    static const double xs = 4.0;
    static const double sm = 8.0;
    static const double md = 16.0;
    static const double lg = 24.0;
    static const double xl = 32.0;
    static const double xxl = 48.0;
    static const double xxxl = 64.0;
  }

  class BorderRadii {
    static const double small = 8.0;
    static const double medium = 12.0;
    static const double large = 16.0;
    static const double xlarge = 24.0;
    static const double xxlarge = 32.0;

    static BorderRadius circular(double radius) => BorderRadius.circular(radius);

    static const BorderRadius circularSmall = BorderRadius.all(Radius.circular(small));
    static const BorderRadius circularMedium = BorderRadius.all(Radius.circular(medium));
    static const BorderRadius circularLarge = BorderRadius.all(Radius.circular(large));
    static const BorderRadius circularXLarge = BorderRadius.all(Radius.circular(xlarge));
  }

  class PlombiProShadows {
    static List<BoxShadow> card = [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 15,
        offset: Offset(0, 10),
      ),
    ];

    static List<BoxShadow> cardHover = [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 25,
        offset: Offset(0, 15),
      ),
    ];

    static List<BoxShadow> button = [
      BoxShadow(
        color: PlombiProColors.secondary.withOpacity(0.3),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ];

    static List<BoxShadow> buttonPrimary = [
      BoxShadow(
        color: PlombiProColors.primary.withOpacity(0.3),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ];

    static List<BoxShadow> elevation1 = [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 5,
        offset: Offset(0, 2),
      ),
    ];

    static List<BoxShadow> elevation2 = [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ];

    static List<BoxShadow> elevation3 = [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 15,
        offset: Offset(0, 6),
      ),
    ];
  }

  class IconSizes {
    static const double small = 16.0;
    static const double medium = 24.0;
    static const double large = 32.0;
    static const double xlarge = 48.0;
    static const double xxlarge = 64.0;
  }
  ```

**Estimated Time:** 0.5 days
**Dependencies:** PlombiProColors
**Success Criteria:** Consistent spacing and shadows

---

<a name="phase-1-components"></a>
## 1.3 CORE COMPONENT LIBRARY (4 days) 🟡

### 1.3.1 Gradient Button Component
**New File:** `/lib/widgets/gradient_button.dart`

**Tasks:**
- [ ] Create primary CTA button widget
  ```dart
  import 'package:flutter/material.dart';
  import '../config/plombipro_colors.dart';
  import '../config/plombipro_text_styles.dart';
  import '../config/plombipro_spacing.dart';

  class GradientButton extends StatefulWidget {
    final String text;
    final VoidCallback onPressed;
    final IconData? icon;
    final bool isSecondary;
    final bool isLoading;
    final double? width;

    const GradientButton({
      Key? key,
      required this.text,
      required this.onPressed,
      this.icon,
      this.isSecondary = false,
      this.isLoading = false,
      this.width,
    }) : super(key: key);

    @override
    _GradientButtonState createState() => _GradientButtonState();
  }

  class _GradientButtonState extends State<GradientButton>
      with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> _scaleAnimation;

    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        duration: Duration(milliseconds: 150),
        vsync: this,
      );

      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    }

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          if (!widget.isLoading) {
            widget.onPressed();
          }
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                decoration: BoxDecoration(
                  gradient: widget.isSecondary
                    ? PlombiProColors.primaryGradient
                    : PlombiProColors.ctaGradient,
                  borderRadius: BorderRadius.circular(BorderRadii.large),
                  boxShadow: widget.isSecondary
                    ? PlombiProShadows.buttonPrimary
                    : PlombiProShadows.button,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.xl,
                  vertical: Spacing.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: 20),
                      SizedBox(width: Spacing.sm),
                    ],
                    Text(
                      widget.text,
                      style: PlombiProTextStyles.button,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
  }
  ```

**Estimated Time:** 1 day
**Dependencies:** Design system
**Success Criteria:** Reusable button component used throughout app

---

### 1.3.2 Feature Card Component
**New File:** `/lib/widgets/feature_card.dart`

**Tasks:**
- [ ] Create feature card with badge support
  ```dart
  class FeatureCard extends StatelessWidget {
    final IconData icon;
    final String title;
    final String description;
    final String? badge;
    final String? timeSaved;
    final bool isHighlight;
    final VoidCallback? onTap;

    const FeatureCard({
      Key? key,
      required this.icon,
      required this.title,
      required this.description,
      this.badge,
      this.timeSaved,
      this.isHighlight = false,
      this.onTap,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadii.circularLarge,
            border: Border.all(
              color: isHighlight
                ? PlombiProColors.secondary
                : PlombiProColors.gray200,
              width: isHighlight ? 2 : 1,
            ),
            boxShadow: PlombiProShadows.card,
          ),
          padding: EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge at top right
              if (badge != null)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: isHighlight
                        ? PlombiProColors.ctaGradient
                        : PlombiProColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge!,
                      style: PlombiProTextStyles.labelBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: Spacing.sm),

              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: isHighlight
                    ? PlombiProColors.ctaGradient
                    : PlombiProColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),

              SizedBox(height: Spacing.md),

              // Title
              Text(title, style: PlombiProTextStyles.heading3),

              SizedBox(height: Spacing.sm),

              // Description
              Text(
                description,
                style: PlombiProTextStyles.body.copyWith(
                  color: PlombiProColors.gray700,
                ),
              ),

              // Time saved indicator
              if (timeSaved != null) ...[
                SizedBox(height: Spacing.md),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: PlombiProColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: PlombiProColors.primary,
                      ),
                      SizedBox(width: Spacing.xs),
                      Text(
                        timeSaved!,
                        style: PlombiProTextStyles.captionBold.copyWith(
                          color: PlombiProColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }
  ```

**Estimated Time:** 1 day
**Dependencies:** Design system
**Success Criteria:** Feature cards used in dashboard and feature screens

---

(Continued in next message due to length...)

---

## SUMMARY OF PHASE 1

**Total Duration:** 2 weeks
**Total Tasks:** 40+ individual tasks
**Key Deliverables:**
- ✅ All critical bugs fixed (mock data, fake calculator, empty catalogs, OCR)
- ✅ Complete design system (colors, typography, spacing, shadows)
- ✅ Core component library (buttons, cards, badges, icons)
- ✅ Foundation for all future development

**Estimated Lines of Code:** ~3,000 new lines
**Files Created/Modified:** 20+ files

**Success Metrics:**
- [ ] All placeholder/mock code removed
- [ ] Zero hardcoded fake data
- [ ] OCR → Quote flow works end-to-end in <2 minutes
- [ ] Catalogs display real products
- [ ] Hydraulic calculator produces accurate results
- [ ] Design system documented and used consistently
- [ ] 10+ reusable components created

---

*[Continue to PHASE 2: STATE MANAGEMENT & ARCHITECTURE in next section...]*

**Note:** This is Part 1 of 7. Would you like me to continue with the remaining phases?
