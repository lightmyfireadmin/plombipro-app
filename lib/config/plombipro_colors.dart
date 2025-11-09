import 'package:flutter/material.dart';

/// PlombiPro Color System
/// Modern color palette based on website 2.0 design
/// Follows Material Design 3 principles with French plumbing industry aesthetics
class PlombiProColors {
  // ===== PRIMARY BRAND COLORS =====

  /// Primary Blue - Main brand color inspired by water/plumbing
  static const Color primaryBlue = Color(0xFF0066CC); // Vibrant blue
  static const Color primaryBlueDark = Color(0xFF004C99); // Darker shade
  static const Color primaryBlueLight = Color(0xFF3385D6); // Lighter shade
  static const Color primaryBlueExtraLight = Color(0xFFE6F2FF); // Very light tint

  /// Secondary Orange - Accent color for CTAs and highlights
  static const Color secondaryOrange = Color(0xFFFF6B35); // Warm orange
  static const Color secondaryOrangeDark = Color(0xFFE55A2B); // Darker orange
  static const Color secondaryOrangeLight = Color(0xFFFF8558); // Lighter orange
  static const Color secondaryOrangeExtraLight = Color(0xFFFFE8E0); // Very light tint

  /// Tertiary Teal - Supporting color for features/tools
  static const Color tertiaryTeal = Color(0xFF00BFA5); // Modern teal
  static const Color tertiaryTealDark = Color(0xFF008F7A); // Darker teal
  static const Color tertiaryTealLight = Color(0xFF33CCB8); // Lighter teal
  static const Color tertiaryTealExtraLight = Color(0xFFE0F7F4); // Very light tint

  // ===== SEMANTIC COLORS =====

  /// Success - For positive actions, completed states
  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color successLight = Color(0xFF34D399);
  static const Color successExtraLight = Color(0xFFD1FAE5);

  /// Error - For errors, warnings, destructive actions
  static const Color error = Color(0xFFEF4444); // Bright red
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorExtraLight = Color(0xFFFEE2E2);

  /// Warning - For caution states
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningExtraLight = Color(0xFFFEF3C7);

  /// Info - For informational messages
  static const Color info = Color(0xFF3B82F6); // Sky blue
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoExtraLight = Color(0xFFDBEAFE);

  // ===== NEUTRAL COLORS =====

  /// Grays - For text, backgrounds, borders
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  /// Pure colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ===== GRADIENT DEFINITIONS =====

  /// Primary gradient - Blue to teal (used in hero sections)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, tertiaryTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary gradient - Orange to red (used for CTAs)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryOrange, Color(0xFFE53E3E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient - Emerald shades
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass morphism overlay - Semi-transparent white
  static const Color glassMorphismOverlay = Color(0x1AFFFFFF);

  // ===== SURFACE COLORS =====

  /// Background colors for light theme
  static const Color backgroundLight = gray50;
  static const Color surfaceLight = white;
  static const Color surfaceElevatedLight = white;

  /// Background colors for dark theme
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceElevatedDark = Color(0xFF242424);

  // ===== TEXT COLORS =====

  /// Light theme text colors
  static const Color textPrimaryLight = gray900;
  static const Color textSecondaryLight = gray600;
  static const Color textTertiaryLight = gray500;
  static const Color textDisabledLight = gray400;

  /// Dark theme text colors
  static const Color textPrimaryDark = gray50;
  static const Color textSecondaryDark = gray400;
  static const Color textTertiaryDark = gray500;
  static const Color textDisabledDark = gray600;

  // ===== BORDER COLORS =====

  static const Color borderLight = gray300;
  static const Color borderDark = gray700;

  // ===== SHADOW COLORS =====

  /// Soft shadows for cards and elevated surfaces
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowStrong = Color(0x29000000);

  // ===== SPECIAL PURPOSE COLORS =====

  /// Premium/Pro features
  static const Color premium = Color(0xFFFFC107); // Gold
  static const Color premiumLight = Color(0xFFFFD54F);
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFB347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Overlay for modals/dialogs
  static const Color overlayLight = Color(0x80000000);
  static const Color overlayDark = Color(0xB3000000);

  /// Shimmer effect for loading states
  static const Color shimmerBase = gray200;
  static const Color shimmerHighlight = gray50;

  // ===== SUPPLIER-SPECIFIC COLORS =====

  /// Point P brand color
  static const Color supplierPointP = Color(0xFFE53935); // Red

  /// Cedeo brand color
  static const Color supplierCedeo = Color(0xFF1976D2); // Blue

  /// Leroy Merlin brand color
  static const Color supplierLeroyMerlin = Color(0xFF4CAF50); // Green

  /// Castorama brand color
  static const Color supplierCastorama = Color(0xFFFF9800); // Orange

  // ===== HELPER METHODS =====

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get lighter shade of a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  /// Get darker shade of a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return hslDark.toColor();
  }

  /// Get supplier color by name
  static Color getSupplierColor(String supplier) {
    switch (supplier.toLowerCase()) {
      case 'point_p':
        return supplierPointP;
      case 'cedeo':
        return supplierCedeo;
      case 'leroy_merlin':
        return supplierLeroyMerlin;
      case 'castorama':
        return supplierCastorama;
      default:
        return primaryBlue;
    }
  }
}
