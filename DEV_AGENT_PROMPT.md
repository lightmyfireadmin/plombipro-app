# DEV AGENT PROMPT - PlombiPro UI Enhancement Implementation

**PROJECT:** PlombiPro Mobile Application
**LANGUAGE:** Flutter/Dart
**OBJECTIVE:** Implement glassmorphic UI enhancements for 33 remaining pages to achieve 100% design consistency

---

## 📋 TABLE OF CONTENTS

1. [Project Context](#project-context)
2. [Current State Analysis](#current-state-analysis)
3. [Design System Specifications](#design-system-specifications)
4. [Implementation Priorities](#implementation-priorities)
5. [Technical Requirements](#technical-requirements)
6. [Code Examples & Patterns](#code-examples--patterns)
7. [Testing Requirements](#testing-requirements)
8. [Success Criteria](#success-criteria)

---

## 🎯 PROJECT CONTEXT

### Application Overview
**PlombiPro** is a Flutter mobile application for French plumbing professionals to manage their business operations including:
- Client management (CRUD)
- Quote generation and tracking
- Invoice creation and payment processing
- Product/service catalog
- Job site management
- Analytics and reporting

### Target Users
- French-speaking plumbers and plumbing companies
- Small to medium-sized businesses
- Users need quick access on job sites
- Must work offline-first (future requirement)

### Brand Identity
- **Primary Color:** Blue (`#0066CC`) - Represents water/plumbing
- **Secondary Color:** Orange (`#FF6B35`) - Energy, urgency, CTAs
- **Tertiary Color:** Teal (`#00BFA5`) - Supporting features/tools
- **Design Language:** Modern glassmorphism with animated gradients
- **Tone:** Professional, efficient, trustworthy

---

## 📊 CURRENT STATE ANALYSIS

### Enhanced Pages (7 - Already Implemented) ✅
These pages serve as reference implementations:

1. **`/home-enhanced`** → `lib/screens/home/home_screen_enhanced.dart`
   - Full glassmorphic dashboard
   - Animated gradient background
   - Floating bubble decorations
   - Glass containers for all cards
   - **USE AS PRIMARY REFERENCE**

2. **`/onboarding-enhanced`** → `lib/screens/onboarding/onboarding_screen_enhanced.dart`
   - Multi-step wizard with glass cards
   - Animated page transitions

3. **`/auth/register-step-by-step`** → `lib/screens/auth/register_step_by_step_screen.dart`
   - Glass form containers
   - Step progress indicator

4. **`/quotes`** → `lib/screens/quotes/quotes_list_page.dart`
   - Glass card list items

5. **`/invoices`** → `lib/screens/invoices/invoices_list_page.dart`
   - Glass card list items

6. **`/clients`** → `lib/screens/clients/clients_list_page.dart`
   - Glass card list items

7. **`/clients/new`** → `lib/screens/clients/add_client_wizard_page.dart`
   - Glass wizard steps

### Pages Needing Enhancement (33) ⚠️

**See detailed list in:** `ROUTING_UI_AUDIT.md`

**Priority Breakdown:**
- **P0 (Critical):** 5 pages - Auth flow (login, register, splash, forgot/reset password)
- **P1 (High):** 8 pages - Core business (quote/invoice forms, client details)
- **P2 (Medium):** 16 pages - Supporting features
- **P3 (Low):** 8 pages - Power user features

---

## 🎨 DESIGN SYSTEM SPECIFICATIONS

### File Locations
All design system components are already implemented:

1. **Colors:** `lib/config/plombipro_colors.dart`
2. **Typography:** `lib/config/plombipro_text_styles.dart`
3. **Spacing:** `lib/config/plombipro_spacing.dart`
4. **Glassmorphism Theme:** `lib/config/glassmorphism_theme.dart`
5. **Glass Components:** `lib/widgets/glassmorphic/`

### Core Glass Components

#### 1. GlassContainer
**Location:** `lib/widgets/glassmorphic/glass_card.dart`

**Usage:**
```dart
GlassContainer(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  borderRadius: BorderRadius.circular(20),
  opacity: 0.15, // 0.1-0.35 range
  child: Column(
    children: [
      // Your content here
    ],
  ),
)
```

**Properties:**
- `width`, `height`: Dimensions
- `padding`: Internal spacing
- `borderRadius`: Corner radius (typically 12-24)
- `opacity`: Glass transparency (0.1 = subtle, 0.35 = heavy)
- `gradient`: Optional gradient overlay
- `child`: Content widget

#### 2. AnimatedGlassContainer
**Location:** `lib/widgets/glassmorphic/glass_card.dart`

**Usage:**
```dart
AnimatedGlassContainer(
  width: 100,
  height: 100,
  padding: const EdgeInsets.all(16),
  borderRadius: BorderRadius.circular(20),
  opacity: 0.2,
  onTap: () {
    // Handle tap
  },
  child: Icon(Icons.add, color: Colors.white),
)
```

**Use For:**
- Buttons
- Interactive cards
- Tappable elements

**Provides:**
- Automatic scale animation on tap
- Ripple effect
- Hover feedback (web/desktop)

### Color Palette

```dart
// Primary Colors
PlombiProColors.primaryBlue        // #0066CC - Main brand
PlombiProColors.primaryBlueDark    // #004C99 - Darker shade
PlombiProColors.primaryBlueLight   // #3385D6 - Lighter shade

// Secondary Colors
PlombiProColors.secondaryOrange    // #FF6B35 - CTAs
PlombiProColors.secondaryOrangeLight

// Tertiary Colors
PlombiProColors.tertiaryTeal       // #00BFA5 - Features

// Semantic Colors
PlombiProColors.success            // #10B981 - Green
PlombiProColors.error              // #EF4444 - Red
PlombiProColors.warning            // #F59E0B - Amber
PlombiProColors.info               // #3B82F6 - Blue

// Neutral Colors
PlombiProColors.gray50 through gray900
PlombiProColors.white
PlombiProColors.black
```

### Typography

```dart
// Headlines
PlombiProTextStyles.headlineLarge   // 32px
PlombiProTextStyles.headlineMedium  // 28px
PlombiProTextStyles.headlineSmall   // 24px

// Titles
PlombiProTextStyles.titleLarge      // 22px
PlombiProTextStyles.titleMedium     // 16px
PlombiProTextStyles.titleSmall      // 14px

// Body
PlombiProTextStyles.bodyLarge       // 16px
PlombiProTextStyles.bodyMedium      // 14px
PlombiProTextStyles.bodySmall       // 12px

// Labels (buttons, chips)
PlombiProTextStyles.labelLarge      // 14px
PlombiProTextStyles.labelMedium     // 12px
PlombiProTextStyles.labelSmall      // 11px
```

### Spacing

```dart
PlombiProSpacing.xs    // 4px
PlombiProSpacing.sm    // 8px
PlombiProSpacing.md    // 16px
PlombiProSpacing.lg    // 24px
PlombiProSpacing.xl    // 32px
PlombiProSpacing.xxl   // 48px

// Padding
PlombiProSpacing.paddingXS through paddingXXL

// Border Radius
PlombiProSpacing.borderRadiusSM    // 8px
PlombiProSpacing.borderRadiusMD    // 12px
PlombiProSpacing.borderRadiusLG    // 16px
PlombiProSpacing.borderRadiusXL    // 24px
```

### Animation Standards

```dart
// Durations
GlassmorphismTheme.animationFast    // 200ms - Micro-interactions
GlassmorphismTheme.animationMedium  // 300ms - Standard
GlassmorphismTheme.animationSlow    // 500ms - Page transitions

// Curves
Curves.easeInOut      // Standard
Curves.easeOutCubic   // Smooth deceleration
Curves.elasticOut     // Playful bounce
```

---

## 🚀 IMPLEMENTATION PRIORITIES

### Phase 1: P0 - Authentication Flow (5 pages)
**Duration:** 2-3 days
**Impact:** Critical - First user impression

#### Page 1: SplashPage
**File:** `lib/screens/splash/splash_page.dart`
**Current:** Simple loading spinner
**Target:** Animated glassmorphic splash

**Requirements:**
- Animated gradient background (blue → teal)
- Floating PlombiPro logo in glass container
- Pulsing animation on logo
- Loading progress indicator in glass
- Smooth fade-in animations

**Code Pattern:**
```dart
Stack(
  children: [
    // Animated gradient background
    AnimatedGradientBackground(),

    // Floating bubbles
    ...FloatingBubbles(),

    // Center content
    Center(
      child: GlassContainer(
        padding: EdgeInsets.all(40),
        opacity: 0.2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated logo
            AnimatedLogo(),
            SizedBox(height: 24),
            // Loading indicator
            CircularProgressIndicator(),
          ],
        ),
      ),
    ),
  ],
)
```

#### Page 2: LoginPage
**File:** `lib/screens/auth/login_page.dart`
**Current:** Basic Material form
**Target:** Glass form with biometric button

**Requirements:**
- Gradient background matching brand
- Glass card for login form
- Glass input fields (white background, subtle border)
- Animated focus states on inputs
- Glass button for biometric login with fingerprint icon animation
- "Remember me" checkbox in glass container
- Smooth error message animations (use glassmorphic snackbar)

**Key Changes:**
```dart
// Replace Scaffold body
body: Stack(
  children: [
    // Background
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlombiProColors.primaryBlue.withOpacity(0.9),
            PlombiProColors.tertiaryTeal.withOpacity(0.7),
          ],
        ),
      ),
    ),

    // Form in glass container
    SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: GlassContainer(
            padding: EdgeInsets.all(32),
            opacity: 0.15,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo, inputs, buttons...
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ],
)
```

#### Page 3: RegisterPage
**File:** `lib/screens/auth/register_page.dart`
**Similar to LoginPage but with additional fields**

#### Page 4-5: ForgotPasswordPage & ResetPasswordPage
**Files:**
- `lib/screens/auth/forgot_password_page.dart`
- `lib/screens/auth/reset_password_page.dart`

**Similar glass treatment to LoginPage**

---

### Phase 2: P1 - Core Business Features (8 pages)
**Duration:** 5-7 days
**Impact:** High - Daily workflow

#### Quote Management

##### QuoteWizardPage
**File:** `lib/screens/quotes/quote_wizard_page.dart`
**Requirements:**
- Multi-step wizard with glass step indicators
- Glass containers for each step content
- Animated transitions between steps
- Progress bar in glass
- Summary panel in glass card

**Pattern:**
```dart
Column(
  children: [
    // Step indicator
    GlassContainer(
      child: Row(
        children: steps.map((step) =>
          AnimatedGlassContainer(
            opacity: currentStep >= step ? 0.25 : 0.1,
            child: StepIcon(),
          )
        ).toList(),
      ),
    ),

    // Step content
    Expanded(
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) => GlassContainer(
          child: StepContent(index),
        ),
      ),
    ),

    // Navigation buttons
    Row(
      children: [
        if (currentStep > 0) BackButton(),
        Spacer(),
        NextButton(),
      ],
    ),
  ],
)
```

##### QuoteFormPage
**File:** `lib/screens/quotes/quote_form_page.dart`
**Requirements:**
- Glass form sections
- Glass input fields
- Glass product picker
- Glass totals summary card
- Animated save confirmation

##### QuoteClientReviewPage
**File:** `lib/screens/quotes/quote_client_review_page.dart`
**Requirements:**
- Read-only glass card displaying quote
- Glass action buttons (Accept/Reject)
- Signature pad in glass container

#### Invoice Management

##### InvoiceWizardPage & InvoiceFormPage
**Files:**
- `lib/screens/invoices/invoice_wizard_page.dart`
- `lib/screens/invoices/invoice_form_page.dart`

**Similar patterns to Quote pages**

#### Client Management

##### ClientDetailPage
**File:** `lib/screens/clients/client_detail_page.dart`
**Current:** Basic Material cards
**Requirements:**
- Glass header with gradient and client avatar
- Glass stats cards (3 columns: revenue, unpaid, active quotes)
- Glass quick action buttons (Call, Email, New Quote)
- Glass tabs for history sections
- Glass list items in tabs

**Header Pattern:**
```dart
Stack(
  children: [
    // Gradient background
    Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, tertiaryTeal],
        ),
      ),
    ),

    // Content
    Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: GlassContainer(
        padding: EdgeInsets.all(20),
        opacity: 0.2,
        child: Row(
          children: [
            CircleAvatar(radius: 40),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clientName, style: headline),
                Text(companyName, style: body),
              ],
            ),
          ],
        ),
      ),
    ),
  ],
)
```

##### ClientFormPage
**File:** `lib/screens/clients/client_form_page.dart`
**Requirements:**
- Glass form sections (Contact Info, Address, Notes)
- Glass input fields with labels
- Glass dropdown for client type
- Glass save button with animation

---

### Phase 3: P2 - Supporting Features (16 pages)
**Duration:** 10-12 days

#### Profile & Settings (5 pages)

1. **EnhancedProfilePage** - Convert to glassmorphic
2. **CompanyProfilePage** - Glass form sections
3. **SettingsPage** - Glass setting groups
4. **InvoiceSettingsPage** - Glass configuration sections
5. **BackupExportPage** - Glass progress indicators

#### Payments (2 pages)

6. **PaymentsListPage** - Glass payment cards
7. **PaymentFormPage** - Glass form

#### Products (4 pages)

8. **ProductsListPage** - Glass product cards
9. **ProductFormPage** - Glass form with image preview
10. **CatalogsOverviewPage** - Glass catalog cards
11. **FavoriteProductsPage** - Glass favorites grid

#### Job Sites (2 pages)

12. **JobSitesListPage** - Glass job site cards with status
13. **JobSiteFormPage** - Glass form with map

#### Analytics (2 pages)

14. **AnalyticsDashboardPage** - Glass chart containers
15. **AdvancedReportsPage** - Glass report cards

#### Other (1 page)

16. **NotificationsPage** - Glass notification cards

---

### Phase 4: P3 - Power Features (8 pages)
**Duration:** 8-10 days

Low priority - Nice to have enhancements.

---

## 🔧 TECHNICAL REQUIREMENTS

### Prerequisites
- Flutter SDK: 3.19.0+
- Dart: 3.3.0+
- All dependencies already installed

### Required Imports
For each page you enhance, add:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/glassmorphism_theme.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_text_styles.dart';
import '../../config/plombipro_spacing.dart';
import '../../widgets/glassmorphic/glass_card.dart';
import '../../services/error_handler.dart'; // For error messages
```

### Background Patterns

#### Pattern 1: Animated Gradient (Main Pages)
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        PlombiProColors.primaryBlue.withOpacity(0.9),
        PlombiProColors.tertiaryTeal.withOpacity(0.7),
        PlombiProColors.backgroundDark,
      ],
    ),
  ),
)
```

#### Pattern 2: Solid Background (Secondary Pages)
```dart
Scaffold(
  backgroundColor: PlombiProColors.backgroundLight,
  // AppBar with glass effect
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: PlombiProColors.primaryBlue.withOpacity(0.8),
        ),
      ),
    ),
  ),
)
```

### Form Field Pattern
Replace standard TextFormField with glass version:

```dart
// OLD
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
  ),
)

// NEW
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: PlombiProColors.gray300,
      width: 1,
    ),
  ),
  child: TextFormField(
    style: PlombiProTextStyles.bodyLarge.copyWith(
      color: PlombiProColors.gray900,
    ),
    decoration: InputDecoration(
      labelText: 'Email',
      labelStyle: PlombiProTextStyles.bodyMedium.copyWith(
        color: PlombiProColors.gray600,
      ),
      border: InputBorder.none,
      contentPadding: EdgeInsets.all(16),
    ),
  ),
)
```

### Button Pattern

```dart
// Primary button
AnimatedGlassContainer(
  width: double.infinity,
  height: 56,
  borderRadius: BorderRadius.circular(12),
  opacity: 0.25,
  gradient: LinearGradient(
    colors: [
      PlombiProColors.primaryBlue,
      PlombiProColors.primaryBlueDark,
    ],
  ),
  onTap: _handleSubmit,
  child: Center(
    child: Text(
      'Enregistrer',
      style: PlombiProTextStyles.labelLarge.copyWith(
        color: Colors.white,
      ),
    ),
  ),
)

// Secondary button
OutlinedButton(
  onPressed: _handleCancel,
  style: OutlinedButton.styleFrom(
    side: BorderSide(
      color: PlombiProColors.gray300,
      width: 1,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
  ),
  child: Text('Annuler'),
)
```

### List Item Pattern

```dart
ListView.builder(
  padding: EdgeInsets.all(16),
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: AnimatedGlassContainer(
        padding: EdgeInsets.all(16),
        opacity: 0.15,
        onTap: () => _handleItemTap(item),
        child: Row(
          children: [
            // Icon or avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PlombiProColors.primaryBlueLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person),
            ),
            SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: PlombiProTextStyles.titleMedium,
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: PlombiProTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            // Trailing
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  },
)
```

### Stats Card Pattern

```dart
Row(
  children: [
    Expanded(
      child: GlassContainer(
        padding: EdgeInsets.all(20),
        opacity: 0.15,
        child: Column(
          children: [
            Icon(
              Icons.people,
              size: 32,
              color: PlombiProColors.primaryBlue,
            ),
            SizedBox(height: 8),
            Text(
              '11',
              style: PlombiProTextStyles.headlineMedium.copyWith(
                color: PlombiProColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Clients',
              style: PlombiProTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    ),
    SizedBox(width: 12),
    // Repeat for other stats...
  ],
)
```

---

## 📝 IMPLEMENTATION GUIDELINES

### Step-by-Step Process for Each Page

#### Step 1: Read Current Implementation
```dart
// Read the current file
// Understand: data flow, state management, user actions
```

#### Step 2: Create Glassmorphic Version
```dart
// Keep all logic unchanged
// Only modify UI layer:
//   - Replace Scaffold body with Stack + gradient background
//   - Wrap content sections in GlassContainer
//   - Replace Card widgets with GlassContainer
//   - Update form fields to glass style
//   - Replace buttons with AnimatedGlassContainer
//   - Add fade-in animations
```

#### Step 3: Test Functionality
```dart
// Verify all existing functionality still works:
//   - Data loads correctly
//   - Forms submit properly
//   - Navigation works
//   - State updates correctly
```

#### Step 4: Polish Animations
```dart
// Add entrance animations:
//   - FadeTransition for page content
//   - SlideTransition for lists
//   - ScaleTransition for dialogs
```

### Animation Controller Pattern

```dart
class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: GlassmorphismTheme.animationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: YourContent(),
    );
  }
}
```

### Error Handling
Use the already-implemented error handler:

```dart
// Success message
context.showSuccess('Client créé avec succès!');

// Error message
context.handleError(error, customMessage: 'Erreur lors de la sauvegarde');

// Warning
context.showWarning('Veuillez remplir tous les champs');

// Info
context.showInfo('Les modifications ont été enregistrées');
```

---

## ✅ TESTING REQUIREMENTS

### Visual Testing Checklist
For each page you enhance:

- [ ] Background gradient displays correctly
- [ ] Glass containers have proper blur and transparency
- [ ] Text is readable (sufficient contrast)
- [ ] Buttons respond to taps with scale animation
- [ ] Form fields accept input correctly
- [ ] Lists scroll smoothly
- [ ] Page transitions are smooth
- [ ] Loading states show properly
- [ ] Error messages display at top (not blocking content)
- [ ] Works on different screen sizes (phone, tablet)

### Functional Testing Checklist

- [ ] All data loads correctly
- [ ] Forms submit and validate properly
- [ ] Navigation works (back button, routing)
- [ ] State management works (Riverpod providers)
- [ ] No console errors
- [ ] No performance issues (60fps)
- [ ] Memory usage reasonable

### Device Testing

Test on:
- Android emulator (API 30+)
- iOS simulator (iOS 15+)
- Real device if available
- Different screen sizes

### Accessibility

- [ ] Text contrast ratio > 4.5:1
- [ ] Touch targets > 48x48dp
- [ ] Forms have proper labels
- [ ] Error messages are clear

---

## 🎯 SUCCESS CRITERIA

### Phase 1 Success (P0 - Auth Flow)
- [ ] All 5 auth pages use glassmorphic design
- [ ] Login→Onboarding→Home flow is visually consistent
- [ ] Animations smooth and professional
- [ ] No functional regressions
- [ ] User testing feedback positive

### Phase 2 Success (P1 - Core Business)
- [ ] All 8 core pages enhanced
- [ ] Daily workflows feel polished
- [ ] Users report improved satisfaction
- [ ] No performance degradation

### Phase 3 Success (P2 - Supporting Features)
- [ ] 16 supporting pages enhanced
- [ ] App feels cohesive throughout

### Phase 4 Success (P3 - Power Features)
- [ ] All 8 power features enhanced
- [ ] 100% UI consistency achieved

### Final Success Criteria
- [ ] All 40+ routes use glassmorphic design
- [ ] Zero UI inconsistencies
- [ ] Brand guidelines followed throughout
- [ ] Performance benchmarks met (60fps)
- [ ] User satisfaction metrics improved
- [ ] Ready for public release

---

## 📦 DELIVERABLES

For each phase, provide:

1. **Updated Files**
   - All modified Dart files
   - Preserved all existing functionality
   - Added glassmorphic UI enhancements

2. **Testing Report**
   - Visual testing checklist completed
   - Functional testing results
   - Screenshots of key pages

3. **Known Issues**
   - Any bugs discovered
   - Performance concerns
   - Recommendations

4. **Migration Notes**
   - Breaking changes (if any)
   - New dependencies (if any)
   - Configuration changes needed

---

## 🚨 IMPORTANT CONSTRAINTS

### DO NOT Change:
- ❌ Business logic or data flow
- ❌ State management patterns (Riverpod)
- ❌ Database queries or API calls
- ❌ Routing structure (GoRouter)
- ❌ Authentication flow
- ❌ Existing functionality

### DO Change:
- ✅ UI widgets (Card → GlassContainer)
- ✅ Layout structure (add Stack, gradients)
- ✅ Colors and typography
- ✅ Animations and transitions
- ✅ Visual feedback (buttons, loading states)

### Maintain:
- ✅ All existing features work
- ✅ No data loss
- ✅ No security issues
- ✅ Performance standards

---

## 💡 TIPS & BEST PRACTICES

### 1. Reference Implementation First
Always look at `home_screen_enhanced.dart` before starting a new page.

### 2. Gradual Enhancement
Don't rewrite entire pages. Enhance section by section:
1. Background
2. Main content container
3. Form fields
4. Buttons
5. Lists
6. Animations

### 3. Test Frequently
Test after each section enhancement, not after the entire page.

### 4. Maintain Readability
If glass effect makes text unreadable, adjust opacity or add solid backgrounds under text.

### 5. Performance First
If animations lag, reduce complexity or disable on lower-end devices.

### 6. Consistent Spacing
Use `PlombiProSpacing` constants, never hardcoded values.

### 7. Color Consistency
Always use `PlombiProColors`, never `Colors.blue` or hex values.

### 8. Typography Hierarchy
Use correct text styles for semantic meaning (headlineLarge for page titles, bodyMedium for content).

### 9. Animation Timing
Use `GlassmorphismTheme.animation*` constants for consistent timing.

### 10. Error Handling
Always use `context.handleError()` for consistent error messaging.

---

## 📞 SUPPORT & QUESTIONS

### Need Help?
- Review `home_screen_enhanced.dart` for reference
- Check `glassmorphism_theme.dart` for available configs
- Review `plombipro_colors.dart` for color palette
- Check existing enhanced pages for patterns

### Report Issues
If you encounter:
- Performance issues
- Design conflicts
- Technical blockers

Document in detail with:
- Page name
- Issue description
- Steps to reproduce
- Expected vs actual result
- Screenshots if applicable

---

## 🚀 READY TO START?

### Quick Start Checklist
- [ ] Read this entire prompt
- [ ] Review reference implementation (`home_screen_enhanced.dart`)
- [ ] Understand glassmorphism theme system
- [ ] Have development environment ready
- [ ] Have access to design system files

### Begin With:
**Phase 1, Page 1: SplashPage**
1. Read current implementation
2. Plan glassmorphic enhancements
3. Implement changes section by section
4. Test thoroughly
5. Move to next page

**Estimated Time:**
- Splash: 2-3 hours
- Login: 4-5 hours
- Register: 4-5 hours
- Forgot/Reset: 3-4 hours each

**Total Phase 1:** 20-24 hours

---

## ✅ IMPLEMENTATION COMMAND

**TO START IMPLEMENTATION:**

Begin with Phase 1 (P0 - Authentication Flow), starting with SplashPage. Follow the step-by-step process outlined above. Apply glassmorphic design patterns consistently using the provided code examples. Test each page thoroughly before moving to the next. Maintain all existing functionality while enhancing only the visual presentation layer.

**Report progress after each page completion.**

---

**END OF PROMPT**
