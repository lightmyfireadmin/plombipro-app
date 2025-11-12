import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_stripe/flutter_stripe.dart'; // Uncomment if Stripe UI is used

import 'config/router.dart';
import 'config/app_theme.dart';
import 'services/error_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read environment variables from dart-define with fallback defaults
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://itugqculhbghypclhyfb.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml0dWdxY3VsaGJnaHlwY2xoeWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3MTAxODEsImV4cCI6MjA3ODI4NjE4MX0.eSNzgh3pMHaPYCkzJ8L1UcoqzMSgHTJvg4c9IOGv4eI',
  );
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  // Validate Supabase credentials
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'FATAL: Missing Supabase credentials. '
      'Build with: flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }

  // Initialize Firebase (required for Firebase App Distribution and other Firebase services)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  // Wrap app with ProviderScope for Riverpod state management
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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