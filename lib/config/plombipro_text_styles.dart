import 'package:flutter/material.dart';
import 'plombipro_colors.dart';

/// PlombiPro Typography System
/// Consistent text styles following Material Design 3 type scale
/// Optimized for French language and plumbing industry content
class PlombiProTextStyles {
  // ===== FONT FAMILY =====

  /// Primary font family - Inter for clean, modern look
  static const String fontFamily = 'Inter';

  /// Fallback font family
  static const String fallbackFontFamily = 'Roboto';

  // ===== DISPLAY STYLES (For large hero text) =====

  /// Display Large - 57px, used for main hero headlines
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w700, // Bold
    height: 1.12, // Line height: 64px
    letterSpacing: -0.25,
    color: PlombiProColors.textPrimaryLight,
  );

  /// Display Medium - 45px, used for secondary hero headlines
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.15, // Line height: 52px
    letterSpacing: 0,
    color: PlombiProColors.textPrimaryLight,
  );

  /// Display Small - 36px, used for section headers
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w600, // Semi-bold
    height: 1.22, // Line height: 44px
    letterSpacing: 0,
    color: PlombiProColors.textPrimaryLight,
  );

  // ===== HEADLINE STYLES (For page titles and major sections) =====

  /// Headline Large - 32px
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25, // Line height: 40px
    letterSpacing: 0,
    color: PlombiProColors.textPrimaryLight,
  );

  /// Headline Medium - 28px
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.28, // Line height: 36px
    letterSpacing: 0,
    color: PlombiProColors.textPrimaryLight,
  );

  /// Headline Small - 24px
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33, // Line height: 32px
    letterSpacing: 0,
    color: PlombiProColors.textPrimaryLight,
  );

  // ===== TITLE STYLES (For card titles and list headers) =====

  /// Title Large - 22px
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27, // Line height: 28px
    letterSpacing: 0,
    color: PlombiProColors.textPrimaryLight,
  );

  /// Title Medium - 16px (most common title size)
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5, // Line height: 24px
    letterSpacing: 0.15,
    color: PlombiProColors.textPrimaryLight,
  );

  /// Title Small - 14px
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43, // Line height: 20px
    letterSpacing: 0.1,
    color: PlombiProColors.textPrimaryLight,
  );

  // ===== BODY STYLES (For main content text) =====

  /// Body Large - 16px (default body text)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5, // Line height: 24px
    letterSpacing: 0.5,
    color: PlombiProColors.textPrimaryLight,
  );

  /// Body Medium - 14px
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43, // Line height: 20px
    letterSpacing: 0.25,
    color: PlombiProColors.textPrimaryLight,
  );

  /// Body Small - 12px
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33, // Line height: 16px
    letterSpacing: 0.4,
    color: PlombiProColors.textSecondaryLight,
  );

  // ===== LABEL STYLES (For buttons, chips, form labels) =====

  /// Label Large - 14px (for prominent buttons)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43, // Line height: 20px
    letterSpacing: 0.1,
    color: PlombiProColors.textPrimaryLight,
  );

  /// Label Medium - 12px (for standard buttons)
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33, // Line height: 16px
    letterSpacing: 0.5,
    color: PlombiProColors.textPrimaryLight,
  );

  /// Label Small - 11px (for chips and small labels)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45, // Line height: 16px
    letterSpacing: 0.5,
    color: PlombiProColors.textSecondaryLight,
  );

  // ===== SPECIALIZED STYLES =====

  /// Button Text - 14px, uppercase, bold
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 1.25,
    color: PlombiProColors.white,
  );

  /// Caption - 12px, for image captions and small notes
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: PlombiProColors.textSecondaryLight,
  );

  /// Overline - 10px, uppercase, for labels
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 1.5,
    color: PlombiProColors.textSecondaryLight,
  );

  /// Code - Monospace font for technical content
  static const TextStyle code = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: PlombiProColors.textPrimaryLight,
    backgroundColor: PlombiProColors.gray100,
  );

  // ===== PRICE STYLES =====

  /// Large price display - for prominent pricing
  static const TextStyle priceLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: PlombiProColors.primaryBlue,
  );

  /// Medium price display - for cards
  static const TextStyle priceMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
    color: PlombiProColors.primaryBlue,
  );

  /// Small price display - for lists
  static const TextStyle priceSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0,
    color: PlombiProColors.primaryBlue,
  );

  // ===== HELPER METHODS =====

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to any text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply size to any text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Make text style bold
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }

  /// Make text style italic
  static TextStyle italic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// Make text style underlined
  static TextStyle underline(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.underline);
  }

  /// Apply opacity to text style
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(
      color: style.color?.withOpacity(opacity),
    );
  }

  // ===== DARK THEME VARIANTS =====

  /// Get dark theme variant of a text style
  static TextStyle darkVariant(TextStyle style) {
    Color? newColor;
    if (style.color == PlombiProColors.textPrimaryLight) {
      newColor = PlombiProColors.textPrimaryDark;
    } else if (style.color == PlombiProColors.textSecondaryLight) {
      newColor = PlombiProColors.textSecondaryDark;
    } else if (style.color == PlombiProColors.textTertiaryLight) {
      newColor = PlombiProColors.textTertiaryDark;
    } else {
      newColor = style.color;
    }
    return style.copyWith(color: newColor);
  }

  // ===== RESPONSIVE HELPERS =====

  /// Scale text style for small screens
  static TextStyle scaleForSmall(TextStyle style, [double scale = 0.875]) {
    return style.copyWith(fontSize: (style.fontSize ?? 14) * scale);
  }

  /// Scale text style for large screens
  static TextStyle scaleForLarge(TextStyle style, [double scale = 1.125]) {
    return style.copyWith(fontSize: (style.fontSize ?? 14) * scale);
  }
}
