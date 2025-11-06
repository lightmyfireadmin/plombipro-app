import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration for PlombiPro
/// Uses flutter_dotenv to load from lib/.env file
///
/// Usage:
/// 1. Copy lib/.env.example to lib/.env
/// 2. Fill in your actual values
/// 3. EnvConfig.init() is called from main.dart before runApp()
class EnvConfig {
  static String get supabaseUrl => _getRequired('SUPABASE_URL');
  static String get supabaseAnonKey => _getRequired('SUPABASE_ANON_KEY');
  static String get supabaseJwtSecret => _getRequired('SUPABASE_JWT_SECRET');

  static String get stripePublishableKey => _getRequired('STRIPE_PUBLISHABLE_KEY');
  static String get stripeSecretKey => _getOptional('STRIPE_SECRET_KEY') ?? '';
  static String get stripeWebhookSecret => _getOptional('STRIPE_WEBHOOK_SECRET') ?? '';

  static String get sendGridApiKey => _getOptional('SENDGRID_API_KEY') ?? '';

  static String get chorusProClientId => _getOptional('CHORUS_PRO_CLIENT_ID') ?? '';
  static String get chorusProClientSecret => _getOptional('CHORUS_PRO_CLIENT_SECRET') ?? '';
  static String get chorusProApiUrl => _getOptional('CHORUS_PRO_API_URL') ?? 'https://api.chorus-pro.gouv.fr/';

  static String get ocrProcessorUrl => _getOptional('OCR_PROCESSOR_FUNCTION_URL') ?? '';
  static String get invoiceGeneratorUrl => _getOptional('INVOICE_GENERATOR_FUNCTION_URL') ?? '';
  static String get facturxGeneratorUrl => _getOptional('FACTURX_GENERATOR_FUNCTION_URL') ?? '';
  static String get chorusProSubmitterUrl => _getOptional('CHORUS_PRO_SUBMITTER_FUNCTION_URL') ?? '';
  static String get sendEmailUrl => _getOptional('SEND_EMAIL_FUNCTION_URL') ?? '';

  static int get rateLimitPerMinute => int.tryParse(_getOptional('RATE_LIMIT_PER_MINUTE') ?? '60') ?? 60;
  static int get rateLimitPerHour => int.tryParse(_getOptional('RATE_LIMIT_PER_HOUR') ?? '1000') ?? 1000;

  static String get environment => _getOptional('ENVIRONMENT') ?? 'development';
  static bool get isDebugMode => _getOptional('DEBUG_MODE')?.toLowerCase() == 'true';
  static String get supportEmail => _getOptional('SUPPORT_EMAIL') ?? 'support@plombipro.com';

  /// Gets a required environment variable, throws if not found
  static String _getRequired(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception(
        '$key is not set. Please check your lib/.env file and ensure it matches lib/.env.example'
      );
    }
    return value;
  }

  /// Gets an optional environment variable, returns null if not found
  static String? _getOptional(String key) {
    return dotenv.env[key];
  }

  /// Validates that all required environment variables are set
  /// Call this during app initialization
  static void validate() {
    // Accessing these will throw if not set
    supabaseUrl;
    supabaseAnonKey;
    supabaseJwtSecret;
    stripePublishableKey;

    print('✓ Environment configuration validated');
    print('  Environment: $environment');
    print('  Debug mode: $isDebugMode');
  }
}