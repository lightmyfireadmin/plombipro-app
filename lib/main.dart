import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_stripe/flutter_stripe.dart'; // Uncomment if Stripe UI is used

import 'config/router.dart';
import 'config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flutter_dotenv to load our .env file
  await dotenv.load(fileName: 'lib/.env');

  // Initialize supabase_flutter
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Stripe publishable key (as per guide page 33)
  // Uncomment and ensure flutter_stripe is correctly configured if you intend to use Stripe UI components.
  // Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

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