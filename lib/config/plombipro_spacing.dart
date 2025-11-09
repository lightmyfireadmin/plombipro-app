import 'package:flutter/material.dart';

/// PlombiPro Spacing System
/// Based on 8px grid system for consistent spacing throughout the app
/// All measurements are multiples of 8px for perfect alignment
class PlombiProSpacing {
  // ===== BASE UNIT =====

  /// Base spacing unit (8px)
  static const double base = 8.0;

  // ===== SPACING SCALE =====

  /// 0px - No spacing
  static const double none = 0.0;

  /// 4px - Minimal spacing (0.5 × base)
  static const double xxs = 4.0; // base * 0.5

  /// 8px - Extra small spacing (1 × base)
  static const double xs = 8.0; // base * 1

  /// 12px - Small spacing (1.5 × base)
  static const double sm = 12.0; // base * 1.5

  /// 16px - Medium spacing (2 × base) - Most commonly used
  static const double md = 16.0; // base * 2

  /// 24px - Large spacing (3 × base)
  static const double lg = 24.0; // base * 3

  /// 32px - Extra large spacing (4 × base)
  static const double xl = 32.0; // base * 4

  /// 40px - 2XL spacing (5 × base)
  static const double xxl = 40.0; // base * 5

  /// 48px - 3XL spacing (6 × base)
  static const double xxxl = 48.0; // base * 6

  /// 64px - 4XL spacing (8 × base)
  static const double xxxxl = 64.0; // base * 8

  /// 80px - 5XL spacing (10 × base)
  static const double xxxxxl = 80.0; // base * 10

  // ===== COMPONENT-SPECIFIC SPACING =====

  /// Padding inside buttons
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Padding inside large buttons
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );

  /// Padding inside small buttons
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xxs,
  );

  /// Padding inside cards
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Padding inside large cards
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(lg);

  /// Padding inside list tiles
  static const EdgeInsets listTilePadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Padding for page content
  static const EdgeInsets pagePadding = EdgeInsets.all(md);

  /// Padding for page content (large screens)
  static const EdgeInsets pagePaddingLarge = EdgeInsets.all(lg);

  /// Padding for form fields
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Padding for dialogs
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);

  /// Padding for modals
  static const EdgeInsets modalPadding = EdgeInsets.all(xl);

  /// Padding for app bar
  static const EdgeInsets appBarPadding = EdgeInsets.symmetric(
    horizontal: md,
  );

  /// Padding for bottom sheet
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(lg);

  /// Padding for chips
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xxs,
  );

  // ===== MARGIN/SPACING HELPERS =====

  /// Vertical spacing between sections
  static const double sectionSpacing = xl;

  /// Vertical spacing between cards in a list
  static const double cardSpacing = md;

  /// Horizontal spacing between elements in a row
  static const double rowSpacing = md;

  /// Spacing between form fields
  static const double formFieldSpacing = md;

  /// Spacing for grid items
  static const double gridSpacing = md;

  // ===== SIZED BOXES (Common vertical/horizontal spaces) =====

  /// 4px vertical space
  static const Widget verticalXXS = SizedBox(height: xxs);

  /// 8px vertical space
  static const Widget verticalXS = SizedBox(height: xs);

  /// 12px vertical space
  static const Widget verticalSM = SizedBox(height: sm);

  /// 16px vertical space
  static const Widget verticalMD = SizedBox(height: md);

  /// 24px vertical space
  static const Widget verticalLG = SizedBox(height: lg);

  /// 32px vertical space
  static const Widget verticalXL = SizedBox(height: xl);

  /// 40px vertical space
  static const Widget verticalXXL = SizedBox(height: xxl);

  /// 48px vertical space
  static const Widget verticalXXXL = SizedBox(height: xxxl);

  /// 4px horizontal space
  static const Widget horizontalXXS = SizedBox(width: xxs);

  /// 8px horizontal space
  static const Widget horizontalXS = SizedBox(width: xs);

  /// 12px horizontal space
  static const Widget horizontalSM = SizedBox(width: sm);

  /// 16px horizontal space
  static const Widget horizontalMD = SizedBox(width: md);

  /// 24px horizontal space
  static const Widget horizontalLG = SizedBox(width: lg);

  /// 32px horizontal space
  static const Widget horizontalXL = SizedBox(width: xl);

  // ===== BORDER RADIUS =====

  /// No radius - Sharp corners
  static const double radiusNone = 0.0;

  /// 4px radius - Subtle rounding
  static const double radiusXS = 4.0;

  /// 8px radius - Small rounding
  static const double radiusSM = 8.0;

  /// 12px radius - Medium rounding (most common)
  static const double radiusMD = 12.0;

  /// 16px radius - Large rounding
  static const double radiusLG = 16.0;

  /// 20px radius - Extra large rounding
  static const double radiusXL = 20.0;

  /// 24px radius - 2XL rounding
  static const double radiusXXL = 24.0;

  /// Full radius - Circular/pill shape
  static const double radiusFull = 9999.0;

  // ===== BORDER RADIUS HELPERS =====

  static BorderRadius get borderRadiusXS => BorderRadius.circular(radiusXS);
  static BorderRadius get borderRadiusSM => BorderRadius.circular(radiusSM);
  static BorderRadius get borderRadiusMD => BorderRadius.circular(radiusMD);
  static BorderRadius get borderRadiusLG => BorderRadius.circular(radiusLG);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  static BorderRadius get borderRadiusXXL => BorderRadius.circular(radiusXXL);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // ===== ICON SIZES =====

  /// Extra small icon - 16px
  static const double iconXS = 16.0;

  /// Small icon - 20px
  static const double iconSM = 20.0;

  /// Medium icon - 24px (default)
  static const double iconMD = 24.0;

  /// Large icon - 32px
  static const double iconLG = 32.0;

  /// Extra large icon - 40px
  static const double iconXL = 40.0;

  /// 2XL icon - 48px
  static const double iconXXL = 48.0;

  /// 3XL icon - 64px
  static const double iconXXXL = 64.0;

  // ===== ELEVATION =====

  /// No elevation
  static const double elevationNone = 0.0;

  /// Subtle elevation - 1dp
  static const double elevationXS = 1.0;

  /// Small elevation - 2dp
  static const double elevationSM = 2.0;

  /// Medium elevation - 4dp
  static const double elevationMD = 4.0;

  /// Large elevation - 8dp
  static const double elevationLG = 8.0;

  /// Extra large elevation - 16dp
  static const double elevationXL = 16.0;

  // ===== HELPER METHODS =====

  /// Get custom spacing (multiples of base unit)
  static double custom(double multiplier) {
    return base * multiplier;
  }

  /// Get EdgeInsets with all sides equal
  static EdgeInsets all(double spacing) {
    return EdgeInsets.all(spacing);
  }

  /// Get EdgeInsets with custom values
  static EdgeInsets only({
    double top = 0,
    double right = 0,
    double bottom = 0,
    double left = 0,
  }) {
    return EdgeInsets.only(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
    );
  }

  /// Get symmetric EdgeInsets
  static EdgeInsets symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  /// Get SizedBox with custom height
  static Widget height(double height) {
    return SizedBox(height: height);
  }

  /// Get SizedBox with custom width
  static Widget width(double width) {
    return SizedBox(width: width);
  }

  /// Get vertical divider
  static Widget get divider => const Divider(height: 1);

  /// Get vertical divider with spacing
  static Widget dividerWithSpacing([double spacing = md]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: const Divider(height: 1),
    );
  }

  // ===== RESPONSIVE BREAKPOINTS =====

  /// Mobile breakpoint (< 600px)
  static const double breakpointMobile = 600.0;

  /// Tablet breakpoint (600px - 900px)
  static const double breakpointTablet = 900.0;

  /// Desktop breakpoint (> 900px)
  static const double breakpointDesktop = 1200.0;

  /// Large desktop breakpoint (> 1200px)
  static const double breakpointLargeDesktop = 1536.0;

  /// Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointMobile;
  }

  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointMobile && width < breakpointTablet;
  }

  /// Check if screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }

  /// Get responsive spacing based on screen size
  static double responsive(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}
