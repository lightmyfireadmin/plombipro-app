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

  try {
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

    debugPrint('🚀 Initializing PlombiPro...');

    // Initialize Firebase (required for Firebase App Distribution and other Firebase services)
    debugPrint('📱 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');

    // Initialize Sentry for error tracking (optional)
    if (sentryDsn.isNotEmpty) {
      debugPrint('📊 Initializing Sentry...');
      await ErrorService.initialize(sentryDsn: sentryDsn);
      debugPrint('✅ Sentry initialized successfully');
    }

    // Initialize supabase_flutter
    debugPrint('🔐 Initializing Supabase...');
    debugPrint('   URL: $supabaseUrl');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint('✅ Supabase initialized successfully');

    // Initialize Stripe publishable key (as per guide page 33)
    // Uncomment and ensure flutter_stripe is correctly configured if you intend to use Stripe UI components.
    // const stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: '');
    // if (stripePublishableKey.isNotEmpty) {
    //   Stripe.publishableKey = stripePublishableKey;
    // }

    debugPrint('✅ All services initialized successfully');
    debugPrint('🎉 Starting PlombiPro app...');

    // Wrap app with ProviderScope for Riverpod state management
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (error, stackTrace) {
    // Catch any initialization errors and show error screen
    debugPrint('❌ FATAL ERROR during initialization: $error');
    debugPrint('Stack trace: $stackTrace');

    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red.shade50,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Erreur d\'initialisation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'L\'application a rencontré une erreur lors du démarrage.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détails de l\'erreur:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Veuillez contacter le support technique.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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

      // CRITICAL: Force light theme only to prevent white-on-white text fields
      // Some devices ignore themeMode and try to apply dark theme when darkTheme is provided
      // By only providing theme (not darkTheme), we ensure consistent light theme always
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,

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