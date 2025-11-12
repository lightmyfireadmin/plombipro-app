import 'package:flutter/material.dart';
import 'plombipro_colors.dart';
import 'plombipro_text_styles.dart';
import 'plombipro_spacing.dart';

/// PlombiPro App Theme
/// Material Design 3 theme using PlombiPro design system
/// Provides consistent theming across the entire application
class AppTheme {
  // Legacy color constants for backward compatibility
  static const Color primaryBlue = PlombiProColors.primaryBlue;
  static const Color primaryDark = PlombiProColors.primaryBlueDark;
  static const Color primaryLight = PlombiProColors.primaryBlueLight;
  static const Color accentOrange = PlombiProColors.secondaryOrange;
  static const Color accentLight = PlombiProColors.secondaryOrangeLight;
  static const Color successGreen = PlombiProColors.success;
  static const Color errorRed = PlombiProColors.error;
  static const Color warningOrange = PlombiProColors.warning;
  static const Color infoBlue = PlombiProColors.info;
  static const Color backgroundLight = PlombiProColors.backgroundLight;
  static const Color surfaceLight = PlombiProColors.surfaceLight;
  static const Color surfaceDark = PlombiProColors.surfaceDark;
  static const Color textPrimary = PlombiProColors.textPrimaryLight;
  static const Color textSecondary = PlombiProColors.textSecondaryLight;
  static const Color textDisabled = PlombiProColors.textDisabledLight;

  /// Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme using PlombiProColors
    colorScheme: ColorScheme.light(
      primary: PlombiProColors.primaryBlue,
      primaryContainer: PlombiProColors.primaryBlueLight,
      secondary: PlombiProColors.secondaryOrange,
      secondaryContainer: PlombiProColors.secondaryOrangeLight,
      tertiary: PlombiProColors.tertiaryTeal,
      tertiaryContainer: PlombiProColors.tertiaryTealLight,
      surface: PlombiProColors.surfaceLight,
      error: PlombiProColors.error,
      onPrimary: PlombiProColors.white,
      onSecondary: PlombiProColors.white,
      onSurface: PlombiProColors.textPrimaryLight,
      onError: PlombiProColors.white,
    ),

    // Scaffold
    scaffoldBackgroundColor: PlombiProColors.backgroundLight,

    // App Bar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Card using PlombiProSpacing
    cardTheme: CardThemeData(
      elevation: PlombiProSpacing.elevationSM,
      shape: RoundedRectangleBorder(
        borderRadius: PlombiProSpacing.borderRadiusMD,
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Elevated Button using PlombiProColors and PlombiProSpacing
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PlombiProColors.primaryBlue,
        foregroundColor: PlombiProColors.white,
        elevation: PlombiProSpacing.elevationSM,
        padding: PlombiProSpacing.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: PlombiProSpacing.borderRadiusSM,
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: const BorderSide(color: primaryBlue),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Icon Button
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: primaryBlue,
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentOrange,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white, // Changed from grey[50] to pure white for better visibility
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      // CRITICAL: Force black text in input fields to prevent white-on-white
      // This style applies to the text the user types, not labels/hints
      floatingLabelStyle: const TextStyle(color: primaryBlue),
      // Ensure input text is always black, regardless of device theme
      hoverColor: Colors.transparent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: Colors.grey[400]),
      // Force black text color in all text fields to prevent white-on-white
      prefixStyle: const TextStyle(color: Colors.black87, fontSize: 16),
      suffixStyle: const TextStyle(color: Colors.black87, fontSize: 16),
      counterStyle: const TextStyle(color: textSecondary, fontSize: 12),
      errorStyle: const TextStyle(color: errorRed, fontSize: 12),
      helperStyle: const TextStyle(color: textSecondary, fontSize: 12),
    ),

    // Text Selection Theme - Force visible selection colors
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: primaryBlue,
      selectionColor: Color(0xFFB3D4FF), // Light blue selection
      selectionHandleColor: primaryBlue,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[200],
      selectedColor: primaryLight,
      secondarySelectedColor: accentLight,
      labelStyle: const TextStyle(color: textPrimary),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
      space: 1,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryBlue;
        }
        return Colors.grey[400];
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.grey[300];
      }),
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryBlue;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Radio
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryBlue;
        }
        return Colors.grey;
      }),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryBlue,
      linearTrackColor: Color(0xFFE3F2FD),
      circularTrackColor: Color(0xFFE3F2FD),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),

    // Navigation Rail
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Colors.white,
      selectedIconTheme: IconThemeData(color: primaryBlue),
      unselectedIconTheme: IconThemeData(color: textSecondary),
      selectedLabelTextStyle: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: textSecondary),
      elevation: 2,
    ),

    // Drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
    ),

    // List Tile
    listTileTheme: const ListTileThemeData(
      iconColor: primaryBlue,
      textColor: textPrimary,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Badge
    badgeTheme: const BadgeThemeData(
      backgroundColor: errorRed,
      textColor: Colors.white,
      smallSize: 12,
      largeSize: 20,
    ),

    // Tab Bar
    tabBarTheme: TabBarThemeData(
      labelColor: primaryBlue,
      unselectedLabelColor: textSecondary,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryBlue, width: 3),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
    ),

    // Text Theme using PlombiProTextStyles
    textTheme: const TextTheme(
      displayLarge: PlombiProTextStyles.displayLarge,
      displayMedium: PlombiProTextStyles.displayMedium,
      displaySmall: PlombiProTextStyles.displaySmall,
      headlineLarge: PlombiProTextStyles.headlineLarge,
      headlineMedium: PlombiProTextStyles.headlineMedium,
      headlineSmall: PlombiProTextStyles.headlineSmall,
      titleLarge: PlombiProTextStyles.titleLarge,
      titleMedium: PlombiProTextStyles.titleMedium,
      titleSmall: PlombiProTextStyles.titleSmall,
      bodyLarge: PlombiProTextStyles.bodyLarge,
      bodyMedium: PlombiProTextStyles.bodyMedium,
      bodySmall: PlombiProTextStyles.bodySmall,
      labelLarge: PlombiProTextStyles.labelLarge,
      labelMedium: PlombiProTextStyles.labelMedium,
      labelSmall: PlombiProTextStyles.labelSmall,
    ),

    // Font Family from PlombiProTextStyles
    fontFamily: PlombiProTextStyles.fontFamily,
  );

  /// Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: primaryLight,
      primaryContainer: primaryDark,
      secondary: accentLight,
      secondaryContainer: accentOrange,
      surface: surfaceDark,
      error: errorRed,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.black,
    ),

    // Scaffold
    scaffoldBackgroundColor: surfaceDark,

    // App Bar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: surfaceDark,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 4,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.black,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    // Font Family
    fontFamily: 'Roboto',
  );
}
