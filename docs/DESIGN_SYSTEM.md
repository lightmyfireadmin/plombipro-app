# PlombiPro Design System
## UX/UI Identity & Guidelines

**Version:** 1.0
**Last Updated:** November 2025
**Status:** Draft for Review

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Brand Identity & Design Philosophy](#brand-identity--design-philosophy)
3. [Color System](#color-system)
4. [Typography](#typography)
5. [Component Library](#component-library)
6. [Navigation & Information Architecture](#navigation--information-architecture)
7. [Animations & Micro-interactions](#animations--micro-interactions)
8. [User Flows & Experience Patterns](#user-flows--experience-patterns)
9. [State Management](#state-management)
10. [Accessibility](#accessibility)
11. [Competitive Analysis](#competitive-analysis)
12. [Implementation Roadmap](#implementation-roadmap)

---

## Executive Summary

### Current State Analysis

PlombiPro currently uses a basic Material Design 3 implementation with:
- **Primary Blue** (#1976D2) and **Accent Orange** (#FF6F00)
- Standard component theming
- Basic navigation structure

### Problems Identified

1. **Visual Identity**: Plain colors lack character and emotional connection
2. **User Experience**: No clear navigation hierarchy or mental model
3. **Workflow**: Missing contextual actions and natural task flow
4. **Engagement**: No micro-interactions or delightful moments
5. **Personality**: Generic appearance doesn't stand out from competition

### Vision

Transform PlombiPro into a **modern, character-rich professional tool** that combines:
- **Professionalism** with warmth and approachability
- **Efficiency** with delight and satisfaction
- **Power** with simplicity and natural flow

---

## Brand Identity & Design Philosophy

### Core Values

**🔧 Professional Excellence**
- Clean, precise, trustworthy
- Industry-standard colors that convey reliability
- Professional tools that inspire confidence

**💡 Smart Innovation**
- Modern, forward-thinking
- Intelligent automation and suggestions
- Smooth, delightful interactions

**🤝 Human-Centered**
- Warm, approachable, friendly
- Clear communication and guidance
- Celebrates user achievements

### Design Principles

#### 1. **Clarity Over Cleverness**
Every element should have a clear purpose. If users need to think, we've failed.

#### 2. **Progressive Disclosure**
Show essential information first, reveal complexity gradually as needed.

#### 3. **Immediate Feedback**
Every action should have an immediate, satisfying response.

#### 4. **Contextual Intelligence**
The app should anticipate needs and suggest next steps based on workflow context.

#### 5. **Celebratory Moments**
Acknowledge completions and milestones with satisfying animations.

---

## Color System

### Current vs. Proposed

#### Current Issues
- Flat, single-tone colors lack depth
- No semantic color system for different contexts
- Limited contrast variety
- No support for emotional states

#### New Color Architecture

### Primary Palette

```dart
// Professional Trust - Blue Family
static const Color primaryDeep = Color(0xFF0D47A1);      // Deep trust
static const Color primary = Color(0xFF1976D2);          // Main brand
static const Color primaryBright = Color(0xFF2196F3);    // Interactive
static const Color primaryLight = Color(0xFF64B5F6);     // Hover/Active
static const Color primaryMist = Color(0xFFE3F2FD);      // Backgrounds

// Energy & Action - Warm Accent
static const Color accentDeep = Color(0xFFE65100);       // Deep energy
static const Color accent = Color(0xFFFF6F00);           // Main accent
static const Color accentBright = Color(0xFFFF9800);     // Interactive
static const Color accentLight = Color(0xFFFFB74D);      // Hover/Active
static const Color accentMist = Color(0xFFFFF3E0);       // Backgrounds
```

### Semantic Colors

```dart
// Success - Nature & Growth
static const Color successDeep = Color(0xFF2E7D32);
static const Color success = Color(0xFF4CAF50);
static const Color successLight = Color(0xFF81C784);
static const Color successMist = Color(0xFFE8F5E9);

// Warning - Attention
static const Color warningDeep = Color(0xFFEF6C00);
static const Color warning = Color(0xFFFF9800);
static const Color warningLight = Color(0xFFFFB74D);
static const Color warningMist = Color(0xFFFFF3E0);

// Error - Alert
static const Color errorDeep = Color(0xFFC62828);
static const Color error = Color(0xFFF44336);
static const Color errorLight = Color(0xFFE57373);
static const Color errorMist = Color(0xFFFFEBEE);

// Info - Communication
static const Color infoDeep = Color(0xFF1565C0);
static const Color info = Color(0xFF2196F3);
static const Color infoLight = Color(0xFF64B5F6);
static const Color infoMist = Color(0xFFE3F2FD);
```

### Neutral Palette (2025 Trend: Warm Neutrals)

```dart
// Instead of pure grays, use warm neutrals for friendlier feel
static const Color neutralDark = Color(0xFF2C2C2E);      // Almost black
static const Color neutral800 = Color(0xFF3A3A3C);
static const Color neutral700 = Color(0xFF48484A);
static const Color neutral600 = Color(0xFF636366);       // Secondary text
static const Color neutral500 = Color(0xFF8E8E93);
static const Color neutral400 = Color(0xFFAEAEB2);
static const Color neutral300 = Color(0xFFC7C7CC);       // Borders
static const Color neutral200 = Color(0xFFD1D1D6);
static const Color neutral100 = Color(0xFFE5E5EA);       // Subtle backgrounds
static const Color neutral50 = Color(0xFFF2F2F7);        // Main background
static const Color neutralWhite = Color(0xFFFFFBFF);     // Warm white
```

### Gradient System

```dart
// Modern depth using subtle gradients (2025 trend)
static const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
);

static const LinearGradient accentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF6F00), Color(0xFFEF6C00)],
);

static const LinearGradient successGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
);
```

### Dark Mode Support

```dart
// Dark mode palette with proper contrast (WCAG AAA)
static const Color darkSurface = Color(0xFF121212);
static const Color darkSurfaceElevated1 = Color(0xFF1E1E1E);  // +1dp
static const Color darkSurfaceElevated2 = Color(0xFF232323);  // +2dp
static const Color darkSurfaceElevated3 = Color(0xFF252525);  // +3dp
static const Color darkSurfaceElevated4 = Color(0xFF272727);  // +4dp
```

### Accessibility Compliance

All color combinations meet **WCAG 2.1 Level AA** standards:
- Normal text: 4.5:1 contrast ratio minimum
- Large text: 3:1 contrast ratio minimum
- Interactive elements: 3:1 against adjacent colors

---

## Typography

### Type Scale (Material Design 3)

```dart
// Display - For hero moments
displayLarge: 57sp / Regular / -0.25px letter spacing
displayMedium: 45sp / Regular / 0px letter spacing
displaySmall: 36sp / Regular / 0px letter spacing

// Headline - For page titles and section headers
headlineLarge: 32sp / Regular / 0px letter spacing
headlineMedium: 28sp / Regular / 0px letter spacing
headlineSmall: 24sp / Regular / 0px letter spacing

// Title - For card titles and list headers
titleLarge: 22sp / Medium / 0px letter spacing
titleMedium: 16sp / Medium / 0.15px letter spacing
titleSmall: 14sp / Medium / 0.1px letter spacing

// Body - For content
bodyLarge: 16sp / Regular / 0.5px letter spacing
bodyMedium: 14sp / Regular / 0.25px letter spacing
bodySmall: 12sp / Regular / 0.4px letter spacing

// Label - For buttons and labels
labelLarge: 14sp / Medium / 0.1px letter spacing
labelMedium: 12sp / Medium / 0.5px letter spacing
labelSmall: 11sp / Medium / 0.5px letter spacing
```

### Font Family Recommendations

**Current:** Roboto (default Material)

**Recommended Upgrade Options:**

1. **Inter** - Modern, highly legible, great for professional apps
2. **SF Pro** (iOS-like feel) - Clean, professional, familiar
3. **Manrope** - Geometric, friendly, modern

**Decision:** Stick with **Roboto** for consistency with Material Design 3, but explore **Inter** for future versions.

### Typography Best Practices

1. **Line Height**: 1.5 for body text, 1.2 for headings
2. **Paragraph Spacing**: 16-24px between paragraphs
3. **Max Line Length**: 60-75 characters for optimal readability
4. **Hierarchy**: Use size, weight, and color to create clear hierarchy

---

## Component Library

### Elevation & Shadows

Material Design 3 uses **surface tints** instead of traditional shadows for elevated components.

```dart
// Elevation levels
Level 0: No elevation (flat on surface)
Level 1: 1dp - Cards at rest
Level 2: 3dp - Cards on hover
Level 3: 6dp - Dialogs, dropdown menus
Level 4: 8dp - Navigation drawer
Level 5: 12dp - Floating action button
```

### Card Variants

#### Standard Card
```dart
Card(
  elevation: 1,
  surfaceTintColor: Theme.of(context).colorScheme.primary,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16), // Increased from 12
  ),
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: content,
    ),
  ),
)
```

#### Featured Card (with gradient)
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [primaryDeep, primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  ),
)
```

#### Status Card
```dart
// Color-coded cards for different statuses
Container(
  decoration: BoxDecoration(
    color: statusColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: statusColor.withOpacity(0.3),
      width: 1.5,
    ),
  ),
)
```

### Button System

#### Primary Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // More rounded
    ),
    elevation: 2,
  ),
  onPressed: onPressed,
  child: Text('Primary Action'),
)
```

#### Secondary Button
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    side: BorderSide(
      color: Theme.of(context).colorScheme.primary,
      width: 2,
    ),
  ),
  onPressed: onPressed,
  child: Text('Secondary Action'),
)
```

#### Icon Button with Badge
```dart
Stack(
  children: [
    IconButton(
      icon: Icon(Icons.notifications_outlined),
      onPressed: onPressed,
    ),
    if (hasNotifications)
      Positioned(
        right: 8,
        top: 8,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: errorColor,
            shape: BoxShape.circle,
          ),
          constraints: BoxConstraints(
            minWidth: 16,
            minHeight: 16,
          ),
          child: Text(
            '$count',
            style: TextStyle(fontSize: 10, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
  ],
)
```

### Input Fields

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Placeholder text',
    prefixIcon: Icon(Icons.icon),
    suffixIcon: IconButton(
      icon: Icon(Icons.clear),
      onPressed: () => controller.clear(),
    ),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 2,
      ),
    ),
  ),
)
```

### Status Chips

```dart
Chip(
  avatar: Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: statusColor,
      shape: BoxShape.circle,
    ),
  ),
  label: Text(statusText),
  backgroundColor: statusColor.withOpacity(0.1),
  side: BorderSide(color: statusColor.withOpacity(0.3)),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
)
```

### Progress Indicators

```dart
// Linear progress with label
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Progress', style: Theme.of(context).textTheme.labelMedium),
        Text('${(progress * 100).toInt()}%',
             style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
    SizedBox(height: 8),
    ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        valueColor: AlwaysStoppedAnimation(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    ),
  ],
)
```

---

## Navigation & Information Architecture

### Current Problems

1. **Duplicate hamburger menus** (nav bar + top left)
2. **No back button** - users can get trapped
3. **Unclear hierarchy** - where to find specific functions

### Recommended IA Pattern: **Hub & Spoke with Bottom Navigation**

#### Primary Navigation (Bottom Nav - 5 items max)

```
┌─────────────────────────────────────┐
│                                     │
│         MAIN CONTENT                │
│                                     │
└─────────────────────────────────────┘
┌──────┬──────┬──────┬──────┬──────┐
│ Home │Sites │Clients│ $  │ More │
│  🏠  │ 📍  │  👥  │ 💰 │  ⋯  │
└──────┴──────┴──────┴──────┴──────┘
```

**Bottom Navigation Items:**
1. **Home** (🏠) - Dashboard, quick actions, recent activity
2. **Sites** (📍) - Job sites, tasks, time tracking
3. **Clients** (👥) - Client management, contacts
4. **Money** (💰) - Invoices, quotes, payments
5. **More** (⋯) - Settings, reports, tools

**Why Bottom Navigation?**
- ✅ Easy thumb access on mobile
- ✅ Always visible - no hidden menus
- ✅ Quick switching between sections
- ✅ Industry standard (ServiceTitan, Jobber)
- ✅ Matches iOS/Android conventions

#### Secondary Navigation (within each section)

**Option 1: Tab Bar** (for 2-4 sub-sections)
```dart
TabBar(
  tabs: [
    Tab(text: 'Active', icon: Icon(Icons.pending_actions)),
    Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
    Tab(text: 'Archived', icon: Icon(Icons.archive)),
  ],
)
```

**Option 2: Segmented Button** (for 2-3 options)
```dart
SegmentedButton<FilterType>(
  segments: [
    ButtonSegment(value: FilterType.all, label: Text('All')),
    ButtonSegment(value: FilterType.active, label: Text('Active')),
    ButtonSegment(value: FilterType.completed, label: Text('Done')),
  ],
  selected: {selectedFilter},
  onSelectionChanged: (Set<FilterType> newSelection) {
    setState(() => selectedFilter = newSelection.first);
  },
)
```

#### Tertiary Navigation (Settings, Tools, etc.)

Use the **"More"** tab with a **list-based menu**:

```dart
ListView(
  children: [
    // User profile header
    UserAccountsDrawerHeader(...),

    // Grouped menu items
    ListTile(
      leading: Icon(Icons.settings),
      title: Text('Settings'),
      trailing: Icon(Icons.chevron_right),
      onTap: () => context.go('/settings'),
    ),
    Divider(),
    ListTile(
      leading: Icon(Icons.analytics),
      title: Text('Reports'),
      trailing: Icon(Icons.chevron_right),
      onTap: () => context.go('/reports'),
    ),
    // ... more items
  ],
)
```

### Navigation Stack & Back Button

**Implementation:**
1. Use `GoRouter` (already in place) for navigation state
2. Add `AppBar` with automatic back button:

```dart
AppBar(
  leading: Navigator.canPop(context)
      ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
      : null,
  title: Text(pageTitle),
  actions: [/* contextual actions */],
)
```

3. Android back gesture support (default in Flutter)
4. iOS swipe-back gesture support:

```dart
MaterialApp.router(
  theme: ThemeData(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  ),
)
```

### Mental Model: Professional Workflow

```
┌─────────────────────────────────────────────────────┐
│                   USER'S DAY                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Morning:    Check dashboard → See today's sites   │
│              ↓                                      │
│  On Site:    Navigate to job → Add tasks/photos    │
│              ↓                                      │
│  Afternoon:  Track time → Complete tasks           │
│              ↓                                      │
│  Evening:    Generate invoice → Send to client     │
│              ↓                                      │
│  Follow-up:  Track payment → Close job             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**App should mirror this workflow** with:
- Contextual suggestions ("Ready to invoice this completed job?")
- Quick actions on cards ("Create invoice", "Add photo", etc.)
- Natural progression through states

---

## Animations & Micro-interactions

### Performance Targets

- **All animations: 60+ FPS**
- **Duration: 200-400ms** (300ms ideal)
- **Loading states: < 50ms** to show feedback

### Animation Curves

```dart
// Use these standard curves
Curves.easeInOut    // Default for most animations
Curves.easeOut      // Elements entering screen
Curves.easeIn       // Elements leaving screen
Curves.elasticOut   // Playful, celebratory moments
Curves.fastOutSlowIn // Material standard curve
```

### Micro-interaction Library

#### 1. Button Press Feedback

```dart
AnimatedScale(
  scale: _isPressed ? 0.95 : 1.0,
  duration: Duration(milliseconds: 100),
  curve: Curves.easeInOut,
  child: ElevatedButton(...),
)

// Or use InkWell ripple (built-in)
InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(12),
  splashColor: primaryColor.withOpacity(0.2),
  child: Container(...),
)
```

#### 2. Card Hover/Press Animation

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeInOut,
  transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(_isHovered ? 0.3 : 0.1),
        blurRadius: _isHovered ? 12 : 4,
        offset: Offset(0, _isHovered ? 8 : 2),
      ),
    ],
  ),
  child: Card(...),
)
```

#### 3. Success Checkmark Animation

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.elasticOut,
  transform: Matrix4.diagonal3Values(
    _showSuccess ? 1.0 : 0.0,
    _showSuccess ? 1.0 : 0.0,
    1.0,
  ),
  child: Icon(
    Icons.check_circle,
    color: successColor,
    size: 64,
  ),
)
```

#### 4. Page Transition

```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => nextPage,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.fastOutSlowIn;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  },
)
```

#### 5. Loading Shimmer Effect

```dart
Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Container(
    width: double.infinity,
    height: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)

// Package: shimmer: ^3.0.0
```

#### 6. Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: _handleRefresh,
  color: Theme.of(context).colorScheme.primary,
  child: ListView(...),
)
```

#### 7. Swipe-to-Delete

```dart
Dismissible(
  key: Key(item.id),
  direction: DismissDirection.endToStart,
  background: Container(
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    color: errorColor,
    child: Icon(Icons.delete, color: Colors.white),
  ),
  confirmDismiss: (direction) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  },
  onDismissed: (direction) {
    // Delete item
  },
  child: ListTile(...),
)
```

#### 8. Floating Action Button (FAB) Animation

```dart
AnimatedScale(
  scale: _showFAB ? 1.0 : 0.0,
  duration: Duration(milliseconds: 200),
  curve: Curves.easeInOut,
  child: FloatingActionButton.extended(
    onPressed: onPressed,
    icon: Icon(Icons.add),
    label: Text('New Job'),
  ),
)
```

#### 9. Status Badge Pulse

```dart
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.scale(
      scale: 1.0 + (_controller.value * 0.1),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: statusColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.5 * _controller.value),
              blurRadius: 8 * _controller.value,
              spreadRadius: 4 * _controller.value,
            ),
          ],
        ),
      ),
    );
  },
)

// _controller is AnimationController with repeat(reverse: true)
```

#### 10. Number Count-Up Animation

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: targetValue),
  duration: Duration(milliseconds: 800),
  curve: Curves.easeOut,
  builder: (context, value, child) {
    return Text(
      value.toStringAsFixed(2),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  },
)
```

### Celebratory Animations

#### Task Completion

```dart
ConfettiWidget(
  confettiController: _confettiController,
  blastDirectionality: BlastDirectionality.explosive,
  particleDrag: 0.05,
  emissionFrequency: 0.05,
  numberOfParticles: 20,
  gravity: 0.1,
  colors: [successColor, primaryColor, accentColor],
)

// Package: confetti: ^0.7.0
```

---

## User Flows & Experience Patterns

### Onboarding

#### First Launch: Value-Driven Onboarding

**Pattern: Benefit-Focused + Doing-Focused**

```
Screen 1: Welcome
- Logo + tagline
- "Get started" button
- "Skip" option (subtle)

Screen 2: Core Benefit #1
- Illustration: Job site management
- "Track all your jobs in one place"
- Swipe to continue

Screen 3: Core Benefit #2
- Illustration: Invoice generation
- "Create professional invoices instantly"
- Swipe to continue

Screen 4: Core Benefit #3
- Illustration: Client management
- "Keep all client info organized"
- "Let's get started!" button

Screen 5: Quick Setup
- "What's your company name?"
- "What's your email?"
- "Create password"
- "You're all set!" → Dashboard
```

#### Progressive Onboarding: In-Context Tips

Show tooltips/coachmarks on first use of features:

```dart
ShowCaseView(
  builder: Builder(
    builder: (context) {
      return FeatureDiscovery(
        child: IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _showFeature(context),
        ),
      );
    },
  ),
)

// Package: showcaseview: ^3.0.0
```

**When to show:**
- First time creating a job → Show photo/note features
- First completed job → Show "Create invoice" feature
- First invoice sent → Show payment tracking feature

### Task Completion Flow

**Example: Creating and Completing a Job**

```
1. Home Screen
   ↓ Tap "New Job" FAB

2. Job Form (Progressive)
   Step 1: Basic Info (Client, Site, Date)
   Step 2: Tasks (What needs to be done?)
   Step 3: Details (Photos, notes, budget)
   → "Create Job" button

3. Success Animation
   ✓ Checkmark animation
   "Job created!"
   → Auto-navigate to Job Detail

4. Job Detail Screen
   Contextual Actions:
   - "Start Timer" (if not started)
   - "Add Photo"
   - "Add Note"
   - "Complete Task" (for each task)

5. All Tasks Complete?
   → Show suggestion: "Ready to create invoice?"

6. Create Invoice
   → Pre-filled with job data
   → Review and send

7. Invoice Sent
   ✓ Success animation
   "Invoice sent to [client]!"
   → Return to dashboard with updated stats
```

### Contextual Actions

**Smart Suggestions Based on State:**

```dart
// Example: Job detail page
List<QuickAction> getContextualActions(Job job) {
  List<QuickAction> actions = [];

  if (!job.hasStarted) {
    actions.add(QuickAction(
      icon: Icons.play_arrow,
      label: 'Start Job',
      color: successColor,
      onTap: () => startJob(job),
    ));
  }

  if (job.isInProgress && !job.isTimerRunning) {
    actions.add(QuickAction(
      icon: Icons.timer,
      label: 'Start Timer',
      color: primaryColor,
      onTap: () => startTimer(job),
    ));
  }

  if (job.isCompleted && !job.hasInvoice) {
    actions.add(QuickAction(
      icon: Icons.receipt,
      label: 'Create Invoice',
      color: accentColor,
      onTap: () => createInvoice(job),
      featured: true, // Highlight this action
    ));
  }

  return actions;
}
```

### Search & Filtering

**Pattern: Progressive Filtering**

```dart
// Search bar always visible at top
SearchBar(
  hintText: 'Search jobs, clients...',
  leading: Icon(Icons.search),
  trailing: [
    IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () => showFilterSheet(),
    ),
  ],
)

// Filter bottom sheet
showModalBottomSheet(
  context: context,
  builder: (context) {
    return FilterSheet(
      filters: [
        FilterGroup(
          title: 'Status',
          options: ['Active', 'Completed', 'Archived'],
        ),
        FilterGroup(
          title: 'Date Range',
          options: ['Today', 'This Week', 'This Month', 'Custom'],
        ),
        FilterGroup(
          title: 'Client',
          options: clientsList,
          searchable: true,
        ),
      ],
    );
  },
);
```

---

## State Management

### Loading States

**Pattern: Skeleton Screens > Spinners**

```dart
// BAD: Generic spinner
if (isLoading) {
  return Center(child: CircularProgressIndicator());
}

// GOOD: Skeleton matching content layout
if (isLoading) {
  return ListView.builder(
    itemCount: 5,
    itemBuilder: (context, index) {
      return SkeletonCard(); // Shimmer effect
    },
  );
}
```

**Skeleton Card Implementation:**

```dart
class SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLine(width: 200, height: 20),
            SizedBox(height: 8),
            SkeletonLine(width: 150, height: 16),
            SizedBox(height: 8),
            SkeletonLine(width: 300, height: 14),
          ],
        ),
      ),
    );
  }
}
```

### Empty States

**Pattern: Informative + Actionable**

```dart
class EmptyJobsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            SvgPicture.asset(
              'assets/illustrations/empty_jobs.svg',
              height: 200,
            ),
            SizedBox(height: 24),

            // Heading
            Text(
              'No jobs yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),

            // Description
            Text(
              'Create your first job to get started tracking work and generating invoices.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24),

            // Call to action
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Create First Job'),
              onPressed: () => context.go('/jobs/new'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Different Empty States for Different Contexts:**

1. **First Time User**: "Get started by creating your first [item]"
2. **Filtered Results**: "No [items] match your filters. Try adjusting them."
3. **Search Results**: "No results for '[query]'. Try different keywords."
4. **Completed All**: "All done! 🎉 You've completed everything."

### Error States

**Pattern: Clear Message + Recovery Action**

```dart
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Error Types:**

1. **Network Error**: "Can't connect. Check your internet."
2. **Server Error**: "Our servers are having issues. We're working on it."
3. **Not Found**: "This [item] doesn't exist or has been deleted."
4. **Permission Error**: "You don't have permission to access this."
5. **Validation Error**: Clear, specific message about what's wrong

### Success Feedback

**Pattern: Inline Success Messages**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Text('Invoice sent to client!'),
        ),
      ],
    ),
    backgroundColor: successColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    action: SnackBarAction(
      label: 'View',
      textColor: Colors.white,
      onPressed: () => viewInvoice(),
    ),
  ),
);
```

---

## Accessibility

### Compliance Goals

- **WCAG 2.1 Level AA** minimum
- **Target: Level AAA** where possible

### Key Requirements

#### 1. Touch Targets

```dart
// Minimum: 48x48 dp
// Recommended: 56x56 dp for primary actions
Container(
  width: 56,
  height: 56,
  child: IconButton(
    icon: Icon(Icons.add),
    onPressed: onPressed,
  ),
)
```

#### 2. Text Scaling

```dart
// Always use Theme.of(context).textTheme
// NEVER use fixed font sizes for content
Text(
  'Content',
  style: Theme.of(context).textTheme.bodyMedium, // Respects user settings
)
```

#### 3. Semantic Labels

```dart
Semantics(
  label: 'Add new job site',
  hint: 'Opens job creation form',
  button: true,
  child: FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: onPressed,
  ),
)
```

#### 4. Screen Reader Support

```dart
// For decorative images
Semantics(
  excludeSemantics: true,
  child: Image.asset('assets/decorations/pattern.png'),
)

// For important images
Semantics(
  label: 'Job site photo showing completed plumbing work',
  image: true,
  child: Image.network(photoUrl),
)
```

#### 5. Focus Management

```dart
// Focus on error fields
if (emailError != null) {
  _emailFocusNode.requestFocus();
}

// Focus on newly added items
_scrollController.animateTo(
  _scrollController.position.maxScrollExtent,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOut,
);
```

#### 6. Color Independence

**DON'T rely on color alone:**

```dart
// BAD
Container(color: redColor); // Only color indicates error

// GOOD
Row(
  children: [
    Icon(Icons.error, color: errorColor),
    SizedBox(width: 8),
    Text('Error message', style: errorTextStyle),
  ],
)
```

---

## Competitive Analysis

### Industry Leaders

#### ServiceTitan
**Strengths:**
- Comprehensive feature set
- Clean, professional design
- Strong workflow automation

**Weaknesses:**
- Complex UI with steep learning curve
- Can feel overwhelming for small businesses
- Heavy, not always responsive

**Lessons:**
- ✅ Clear section separation
- ✅ Status-based color coding
- ❌ Avoid feature overload in primary nav

#### Jobber
**Strengths:**
- Extremely user-friendly
- Beautiful, modern design
- Great onboarding
- Quick actions everywhere

**Weaknesses:**
- Less feature-rich than competitors
- Limited customization

**Lessons:**
- ✅ Prioritize ease of use over features
- ✅ Excellent use of empty states
- ✅ Contextual quick actions

#### Fieldwire
**Strengths:**
- Real-time collaboration
- Excellent mobile experience
- Great document management

**Weaknesses:**
- Focused on construction, not service trades
- Complex project structures

**Lessons:**
- ✅ Mobile-first design
- ✅ Real-time updates and sync
- ✅ Document/photo management

### PlombiPro's Opportunity

**Differentiation Strategy:**

1. **Warmth + Professionalism**: Most competitors feel cold and corporate. PlombiPro should feel friendly and approachable while remaining professional.

2. **Intelligent Automation**: Suggest next steps, pre-fill data, reduce manual work.

3. **Beautiful & Delightful**: Most trade apps are utilitarian. We can stand out with thoughtful animations and polish.

4. **Focused Feature Set**: Better to do 20 things excellently than 100 things poorly.

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
**Goal: Fix critical UX issues and establish base design system**

#### Week 1: Navigation & Structure
- [ ] Implement bottom navigation bar (5 primary sections)
- [ ] Add proper back button support to all screens
- [ ] Remove duplicate hamburger menu icons
- [ ] Establish clear page hierarchy in router

#### Week 2: Core Components
- [ ] Update color system with new palette
- [ ] Refine typography scale
- [ ] Create reusable card components
- [ ] Implement consistent button styles
- [ ] Add proper loading states (shimmer skeletons)

**Deliverable:** App navigates smoothly, no trapped pages, consistent look & feel

---

### Phase 2: Visual Identity (Weeks 3-4)
**Goal: Transform from generic to distinctive**

#### Week 3: Color & Depth
- [ ] Implement gradient system for featured elements
- [ ] Add proper elevation/shadows to cards
- [ ] Update status chips with color system
- [ ] Refine input field styling
- [ ] Add surface tints (Material 3)

#### Week 4: Icons & Illustrations
- [ ] Audit all icons for consistency
- [ ] Add custom illustrations for empty states
- [ ] Create status icons and badges
- [ ] Design hero illustrations for onboarding

**Deliverable:** App looks modern, polished, and distinctive

---

### Phase 3: Micro-interactions (Weeks 5-6)
**Goal: Add delight and feedback**

#### Week 5: Basic Animations
- [ ] Button press feedback (scale/ripple)
- [ ] Card hover effects
- [ ] Page transitions
- [ ] Pull-to-refresh
- [ ] Loading indicators

#### Week 6: Advanced Interactions
- [ ] Success animations (checkmarks, confetti)
- [ ] Number count-ups for stats
- [ ] Status badge pulse animations
- [ ] Swipe-to-delete gestures
- [ ] FAB show/hide on scroll

**Deliverable:** App feels responsive and satisfying to use

---

### Phase 4: User Experience (Weeks 7-8)
**Goal: Streamline workflows and add intelligence**

#### Week 7: Contextual Actions
- [ ] Smart suggestions based on job state
- [ ] Quick actions on cards
- [ ] Contextual FAB actions
- [ ] Next-step recommendations

#### Week 8: Empty & Error States
- [ ] Design and implement all empty states
- [ ] Create friendly error messages
- [ ] Add recovery actions
- [ ] Implement search/filter UI

**Deliverable:** App guides users naturally through workflows

---

### Phase 5: Onboarding & Polish (Weeks 9-10)
**Goal: Great first impression and final touches**

#### Week 9: Onboarding
- [ ] Create onboarding flow (3-5 screens)
- [ ] Add progressive feature discovery
- [ ] Implement tooltips/coachmarks
- [ ] Create welcome checklist

#### Week 10: Final Polish
- [ ] Accessibility audit (touch targets, colors, labels)
- [ ] Performance optimization (60 FPS everywhere)
- [ ] Dark mode refinement
- [ ] Final bug fixes and edge cases

**Deliverable:** Production-ready, delightful app experience

---

### Phase 6: Continuous Improvement (Ongoing)
**Goal: Learn and iterate**

- [ ] User testing sessions (watch real users)
- [ ] Analytics implementation (track key flows)
- [ ] A/B testing for critical flows
- [ ] Gather feedback and prioritize improvements
- [ ] Quarterly design system updates

---

## Success Metrics

### User Experience
- **Task Completion Rate**: >90% for primary flows
- **Time to Complete Action**: 50% reduction from baseline
- **Error Rate**: <5% on critical paths
- **User Satisfaction**: 4.5+ stars in app stores

### Technical
- **Frame Rate**: 60+ FPS on animations
- **Load Time**: <2 seconds for primary screens
- **Accessibility**: WCAG 2.1 AA compliance

### Business
- **User Retention**: 70%+ after 30 days
- **Feature Adoption**: 80%+ use core features monthly
- **Support Tickets**: 40% reduction in UX-related issues

---

## Resources & References

### Design Inspiration
- [Mobbin](https://mobbin.com) - Mobile app design patterns
- [Dribbble](https://dribbble.com) - Design inspiration
- [Material Design 3](https://m3.material.io) - Official guidelines

### Color Tools
- [Coolors](https://coolors.co) - Color palette generator
- [Contrast Checker](https://webaim.org/resources/contrastchecker/) - WCAG compliance

### Animation Libraries
- [animations](https://pub.dev/packages/animations) - Material motion
- [shimmer](https://pub.dev/packages/shimmer) - Loading states
- [confetti](https://pub.dev/packages/confetti) - Celebrations
- [lottie](https://pub.dev/packages/lottie) - Complex animations

### Icons & Illustrations
- [Material Symbols](https://fonts.google.com/icons) - Google icons
- [unDraw](https://undraw.co) - Free illustrations
- [Storyset](https://storyset.com) - Animated illustrations

---

## Appendix: Code Templates

### A. Reusable Card Template

```dart
class PlombiCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool elevated;

  const PlombiCard({
    required this.child,
    this.onTap,
    this.accentColor,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevated ? 4 : 1,
      surfaceTintColor: accentColor ?? Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
```

### B. Status Chip Template

```dart
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
```

### C. Contextual Quick Action Button

```dart
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool featured;

  const QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    if (featured) {
      return ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
    }

    return OutlinedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveColor,
        side: BorderSide(color: effectiveColor),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
```

---

## Changelog

### Version 1.0 (November 2025)
- Initial design system documentation
- Comprehensive research on 2025 design trends
- Analysis of Apple Liquid Glass, Airbnb, Material Design 3
- Competitive analysis of service industry apps
- Complete component library
- Animation & micro-interaction guidelines
- Implementation roadmap

---

## Feedback & Iteration

This is a **living document**. As we implement and test these designs, we'll learn what works and what doesn't.

**Next Steps:**
1. Review this document with the team
2. Prioritize Phase 1 tasks
3. Create design mockups for key screens
4. Begin implementation
5. Test with real users
6. Iterate based on feedback

**Questions? Suggestions?**
Let's discuss and refine this together!

---

*Document prepared with extensive research on 2025 design trends, competitive analysis, and Flutter/Material Design 3 best practices.*
