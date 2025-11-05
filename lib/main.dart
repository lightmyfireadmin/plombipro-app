import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_stripe/flutter_stripe.dart'; // Uncomment if Stripe UI is used

import 'config/router.dart';
import 'config/env_config.dart';
import 'utils/rate_limiter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flutter_dotenv to load our .env file
  await dotenv.load(fileName: 'lib/.env');

  // Validate environment configuration
  EnvConfig.validate();

  // Initialize rate limiter
  initializeRateLimiter(
    maxRequestsPerMinute: EnvConfig.rateLimitPerMinute,
    maxRequestsPerHour: EnvConfig.rateLimitPerHour,
  );

  // Initialize supabase_flutter using EnvConfig
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  // Initialize Stripe publishable key (as per guide page 33)
  // Uncomment and ensure flutter_stripe is correctly configured if you intend to use Stripe UI components.
  // Stripe.publishableKey = EnvConfig.stripePublishableKey;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PlombiPro',
      // Configure go_router
      routerConfig: AppRouter.router,

      // Set up the theme with Material 3 and primary color
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)), // French blue
        useMaterial3: true,
      ),

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