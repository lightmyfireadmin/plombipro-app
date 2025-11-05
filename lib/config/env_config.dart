class EnvConfig {
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';
  static String stripePublishableKey = '';

  static void init() {
    supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
    stripePublishableKey = const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not set. ''Use --dart-define=SUPABASE_URL=YOUR_URL');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not set. ''Use --dart-define=SUPABASE_ANON_KEY=YOUR_KEY');
    }
  }
}