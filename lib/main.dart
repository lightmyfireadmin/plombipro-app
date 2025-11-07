import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_stripe/flutter_stripe.dart'; // Uncomment if Stripe UI is used

import 'config/router.dart';
import 'config/app_theme.dart';
import 'services/error_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read environment variables from dart-define
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  // Initialize Sentry for error tracking (optional)
  if (sentryDsn.isNotEmpty) {
    await ErrorService.initialize(sentryDsn: sentryDsn);
  }

  // Initialize supabase_flutter
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Initialize Stripe publishable key (as per guide page 33)
  // Uncomment and ensure flutter_stripe is correctly configured if you intend to use Stripe UI components.
  // const stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: '');
  // if (stripePublishableKey.isNotEmpty) {
  //   Stripe.publishableKey = stripePublishableKey;
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PlombiPro',
      debugShowCheckedModeBanner: false,

      // Configure go_router
      routerConfig: AppRouter.router,

      // Set up the theme with Material 3 and primary color
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)), // French blue
        useMaterial3: true,
        // Satoshi-like font for headings and main UI (using Outfit as alternative)
        textTheme: GoogleFonts.outfitTextTheme().copyWith(
          // Inter for body text, paragraphs, bills, quotes (more official)
          bodySmall: GoogleFonts.inter(fontSize: 12),
          bodyMedium: GoogleFonts.inter(fontSize: 14),
          bodyLarge: GoogleFonts.inter(fontSize: 16),
        ),
        // Primary font family for app
        fontFamily: GoogleFonts.outfit().fontFamily,
      ),
      // Custom Material Design 3 theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light theme

      // Set up localization for French
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', ''), // French, no country code
      ],
      locale: const Locale('fr'), // Explicitly set default locale
    );
  }
}