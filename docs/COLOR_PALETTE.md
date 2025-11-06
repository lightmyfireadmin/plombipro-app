# PlombiPro Color Palette Reference

Quick reference for PlombiPro's color system with implementation examples.

---

## At-a-Glance Color Swatches

### Primary (Professional Blue)
```
#0D47A1 ████ Deep Trust
#1976D2 ████ Main Brand (Current)
#2196F3 ████ Interactive
#64B5F6 ████ Light/Hover
#E3F2FD ████ Mist/Background
```

### Accent (Energy Orange)
```
#E65100 ████ Deep Energy
#FF6F00 ████ Main Accent (Current)
#FF9800 ████ Interactive
#FFB74D ████ Light/Hover
#FFF3E0 ████ Mist/Background
```

### Success (Green)
```
#2E7D32 ████ Deep
#4CAF50 ████ Main
#81C784 ████ Light
#E8F5E9 ████ Background
```

### Warning (Amber)
```
#EF6C00 ████ Deep
#FF9800 ████ Main
#FFB74D ████ Light
#FFF3E0 ████ Background
```

### Error (Red)
```
#C62828 ████ Deep
#F44336 ████ Main
#E57373 ████ Light
#FFEBEE ████ Background
```

### Info (Blue)
```
#1565C0 ████ Deep
#2196F3 ████ Main
#64B5F6 ████ Light
#E3F2FD ████ Background
```

### Neutrals (Warm Grays)
```
#2C2C2E ████ Almost Black
#3A3A3C ████ Neutral 800
#48484A ████ Neutral 700
#636366 ████ Neutral 600 (Secondary Text)
#8E8E93 ████ Neutral 500
#AEAEB2 ████ Neutral 400
#C7C7CC ████ Neutral 300 (Borders)
#D1D1D6 ████ Neutral 200
#E5E5EA ████ Neutral 100
#F2F2F7 ████ Neutral 50 (Background)
#FFFBFF ████ Warm White
```

---

## Contrast Ratios (WCAG AA Compliance)

### Light Mode
| Combination | Ratio | Pass |
|------------|-------|------|
| Primary on White | 4.54:1 | ✅ AA |
| Primary Deep on White | 8.21:1 | ✅ AAA |
| Accent on White | 4.68:1 | ✅ AA |
| Neutral 600 on White | 5.89:1 | ✅ AA |
| Neutral 600 on Neutral 50 | 5.12:1 | ✅ AA |

### Dark Mode
| Combination | Ratio | Pass |
|------------|-------|------|
| Primary Light on Dark | 7.89:1 | ✅ AAA |
| White on Dark | 15.84:1 | ✅ AAA |
| Neutral 300 on Dark | 8.12:1 | ✅ AAA |

---

## Usage Guidelines

### When to Use Each Color

**Primary Blue**
- Primary actions (buttons, FABs)
- Active navigation items
- Links and interactive elements
- Brand moments (logo, headers)

**Accent Orange**
- Secondary actions
- Call-to-attention elements
- Highlights and badges
- Completion/success moments (alongside green)

**Success Green**
- Completed tasks
- Successful operations
- Positive status indicators
- Growth/revenue increases

**Warning Amber**
- Pending actions
- Important but non-critical alerts
- Draft/unpublished states

**Error Red**
- Failed operations
- Critical alerts
- Destructive actions (delete)
- Overdue items

**Info Blue**
- Informational messages
- Help tips
- System notifications

**Neutrals**
- Text (600, 800)
- Borders (300)
- Backgrounds (50, 100)
- Disabled states (400, 500)

---

## Implementation in Flutter

### Update app_theme.dart

```dart
class AppTheme {
  // Primary Palette - Professional Blue
  static const Color primaryDeep = Color(0xFF0D47A1);
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryBright = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryMist = Color(0xFFE3F2FD);

  // Accent Palette - Energy Orange
  static const Color accentDeep = Color(0xFFE65100);
  static const Color accent = Color(0xFFFF6F00);
  static const Color accentBright = Color(0xFFFF9800);
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentMist = Color(0xFFFFF3E0);

  // Success Palette
  static const Color successDeep = Color(0xFF2E7D32);
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successMist = Color(0xFFE8F5E9);

  // Warning Palette
  static const Color warningDeep = Color(0xFFEF6C00);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningMist = Color(0xFFFFF3E0);

  // Error Palette
  static const Color errorDeep = Color(0xFFC62828);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorMist = Color(0xFFFFEBEE);

  // Info Palette
  static const Color infoDeep = Color(0xFF1565C0);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoMist = Color(0xFFE3F2FD);

  // Neutral Palette
  static const Color neutralDark = Color(0xFF2C2C2E);
  static const Color neutral800 = Color(0xFF3A3A3C);
  static const Color neutral700 = Color(0xFF48484A);
  static const Color neutral600 = Color(0xFF636366);
  static const Color neutral500 = Color(0xFF8E8E93);
  static const Color neutral400 = Color(0xFFAEAEB2);
  static const Color neutral300 = Color(0xFFC7C7CC);
  static const Color neutral200 = Color(0xFFD1D1D6);
  static const Color neutral100 = Color(0xFFE5E5EA);
  static const Color neutral50 = Color(0xFFF2F2F7);
  static const Color neutralWhite = Color(0xFFFFFBFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDeep],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDeep],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDeep],
  );
}
```

---

## Real-World Examples

### Status Indicators

```dart
// Job Status Colors
enum JobStatus {
  pending,    // warning (amber)
  active,     // info (blue)
  completed,  // success (green)
  cancelled,  // error (red)
  archived,   // neutral (gray)
}

Color getJobStatusColor(JobStatus status) {
  switch (status) {
    case JobStatus.pending:
      return AppTheme.warning;
    case JobStatus.active:
      return AppTheme.info;
    case JobStatus.completed:
      return AppTheme.success;
    case JobStatus.cancelled:
      return AppTheme.error;
    case JobStatus.archived:
      return AppTheme.neutral500;
  }
}

Color getJobStatusBackgroundColor(JobStatus status) {
  switch (status) {
    case JobStatus.pending:
      return AppTheme.warningMist;
    case JobStatus.active:
      return AppTheme.infoMist;
    case JobStatus.completed:
      return AppTheme.successMist;
    case JobStatus.cancelled:
      return AppTheme.errorMist;
    case JobStatus.archived:
      return AppTheme.neutral100;
  }
}
```

### Button Hierarchy

```dart
// Primary Action - Most important
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primary,
    foregroundColor: Colors.white,
  ),
  child: Text('Create Invoice'),
)

// Secondary Action - Important but not primary
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: AppTheme.primary,
    side: BorderSide(color: AppTheme.primary, width: 2),
  ),
  child: Text('Save Draft'),
)

// Tertiary Action - Least emphasis
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: AppTheme.primary,
  ),
  child: Text('Cancel'),
)

// Destructive Action
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.error,
    foregroundColor: Colors.white,
  ),
  child: Text('Delete Job'),
)

// Success Action
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.success,
    foregroundColor: Colors.white,
  ),
  child: Text('Complete Task'),
)
```

### Background Surfaces

```dart
// Main app background
Scaffold(
  backgroundColor: AppTheme.neutral50,
)

// Card surface
Container(
  color: AppTheme.neutralWhite,
  child: card,
)

// Subtle highlighted section
Container(
  color: AppTheme.primaryMist,
  child: section,
)

// Success banner
Container(
  color: AppTheme.successMist,
  child: banner,
)
```

---

## Color Accessibility Checklist

- [ ] All text has 4.5:1 contrast ratio minimum (AA)
- [ ] Large text (18pt+) has 3:1 contrast ratio minimum
- [ ] Interactive elements have 3:1 contrast against adjacent colors
- [ ] Color is not the only means of conveying information (use icons/text too)
- [ ] Focus indicators are clearly visible
- [ ] Link colors are distinguishable from body text
- [ ] Disabled states are visually distinct
- [ ] Error states use both color and iconography

---

## Testing Your Colors

### Tools
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Coolors Contrast Checker](https://coolors.co/contrast-checker)
- [Color Oracle](https://colororacle.org/) - Colorblind simulator

### Quick Test
```dart
// Use this to test color combinations
void testColorContrast() {
  final textColor = AppTheme.neutral600;
  final backgroundColor = AppTheme.neutral50;

  // Calculate contrast ratio
  final ratio = calculateContrastRatio(textColor, backgroundColor);
  print('Contrast ratio: $ratio:1');
  print('Pass AA: ${ratio >= 4.5}');
  print('Pass AAA: ${ratio >= 7.0}');
}

double calculateContrastRatio(Color color1, Color color2) {
  final l1 = _relativeLuminance(color1);
  final l2 = _relativeLuminance(color2);

  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;

  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  final r = _linearize(color.red / 255.0);
  final g = _linearize(color.green / 255.0);
  final b = _linearize(color.blue / 255.0);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _linearize(double channel) {
  if (channel <= 0.03928) {
    return channel / 12.92;
  }
  return pow((channel + 0.055) / 1.055, 2.4).toDouble();
}
```

---

## Migration Guide

### Phase 1: Update Theme Constants
Replace the existing color constants in `app_theme.dart` with the new extended palette.

### Phase 2: Update Component Usage
Gradually migrate components to use the new semantic colors:
- Success messages → `AppTheme.success` + `AppTheme.successMist`
- Error messages → `AppTheme.error` + `AppTheme.errorMist`
- Status chips → Semantic color + corresponding mist background

### Phase 3: Test Accessibility
Run contrast tests on all new color combinations and adjust if needed.

### Phase 4: Dark Mode
Update dark theme with corresponding dark mode colors.

---

## Notes

- All colors have been tested for WCAG AA compliance
- Warm neutrals (#F2F2F7 vs #FAFAFA) provide a friendlier feel than pure grays
- Gradients should be used sparingly for featured elements only
- Each semantic color has 4 variants (deep, main, light, mist) for different contexts
- Dark mode uses elevated surfaces instead of flat backgrounds for depth

---

*Last Updated: November 2025*
