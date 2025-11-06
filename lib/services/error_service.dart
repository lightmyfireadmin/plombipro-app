import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized error handling service for PlombiPro
///
/// This service provides:
/// - User-friendly error messages
/// - Error logging and tracking with Sentry
/// - Standardized error handling across the app
class ErrorService {
  static bool _isInitialized = false;

  /// Initialize Sentry for error tracking
  /// Call this once during app startup
  static Future<void> initialize({String? sentryDsn}) async {
    if (_isInitialized) return;

    if (sentryDsn != null && sentryDsn.isNotEmpty) {
      await SentryFlutter.init(
        (options) {
          options.dsn = sentryDsn;
          options.environment = kReleaseMode ? 'production' : 'development';
          options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
          options.enableAutoPerformanceTracing = true;
          options.attachScreenshot = true;
          options.attachViewHierarchy = true;
        },
      );
      _isInitialized = true;
    }
  }

  /// Handle an error and show user-friendly message
  static void handleError(
    BuildContext? context,
    dynamic error, {
    String? customMessage,
    StackTrace? stackTrace,
    bool showSnackBar = true,
    Map<String, dynamic>? additionalData,
  }) {
    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('❌ Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }

    // Get user-friendly message
    final friendlyMessage = customMessage ?? _getFriendlyMessage(error);

    // Show snackbar to user if context available
    if (context != null && showSnackBar && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyMessage),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    // Log to Sentry
    _logToSentry(error, stackTrace, additionalData);
  }

  /// Handle success messages
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Handle warning messages
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Handle info messages
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Log error to Sentry
  static void _logToSentry(
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  ) {
    if (!_isInitialized) return;

    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap(additionalData ?? {}),
    );
  }

  /// Convert technical errors to user-friendly messages
  static String _getFriendlyMessage(dynamic error) {
    // Handle Supabase Auth errors
    if (error is AuthException) {
      switch (error.statusCode) {
        case '400':
          if (error.message.toLowerCase().contains('email')) {
            return 'Adresse email invalide ou déjà utilisée.';
          }
          if (error.message.toLowerCase().contains('password')) {
            return 'Mot de passe invalide. Il doit contenir au moins 6 caractères.';
          }
          return 'Données invalides. Veuillez vérifier vos informations.';
        case '401':
          return 'Email ou mot de passe incorrect.';
        case '422':
          return 'Veuillez vérifier votre email pour confirmer votre compte.';
        case '429':
          return 'Trop de tentatives. Veuillez réessayer dans quelques minutes.';
        default:
          return error.message;
      }
    }

    // Handle Postgres errors
    if (error is PostgrestException) {
      if (error.code == '23505') {
        return 'Cet enregistrement existe déjà.';
      }
      if (error.code == '23503') {
        return 'Impossible de supprimer car il est référencé ailleurs.';
      }
      if (error.code?.startsWith('42') ?? false) {
        return 'Erreur de base de données. Veuillez contacter le support.';
      }
      return 'Erreur lors de l\'opération. Veuillez réessayer.';
    }

    // Handle network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException') ||
        error.toString().contains('TimeoutException')) {
      return 'Problème de connexion internet. Veuillez vérifier votre connexion.';
    }

    // Handle file/storage errors
    if (error.toString().contains('FileSystemException') ||
        error.toString().contains('StorageException')) {
      return 'Erreur d\'accès au fichier. Vérifiez les permissions.';
    }

    // Handle permission errors
    if (error.toString().contains('PermissionDenied')) {
      return 'Permission refusée. Veuillez autoriser l\'accès dans les paramètres.';
    }

    // Handle format errors
    if (error is FormatException) {
      return 'Format de données invalide.';
    }

    // Handle type errors
    if (error is TypeError) {
      return 'Erreur de traitement des données.';
    }

    // Handle generic errors with keywords
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('not found')) {
      return 'Élément introuvable.';
    }
    if (errorString.contains('already exists')) {
      return 'Cet élément existe déjà.';
    }
    if (errorString.contains('invalid')) {
      return 'Données invalides. Veuillez vérifier vos informations.';
    }
    if (errorString.contains('expired')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }
    if (errorString.contains('denied') || errorString.contains('forbidden')) {
      return 'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
    }

    // Default message
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  /// Log a custom event to Sentry
  static void logEvent(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? additionalData,
  }) {
    if (!_isInitialized) return;

    Sentry.captureMessage(
      message,
      level: level,
      hint: Hint.withMap(additionalData ?? {}),
    );
  }

  /// Set user context for error tracking
  static void setUserContext({
    required String userId,
    String? email,
    String? companyName,
  }) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: userId,
        email: email,
        data: companyName != null ? {'companyName': companyName} : null,
      ));
    });
  }

  /// Clear user context (e.g., on logout)
  static void clearUserContext() {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  /// Add breadcrumb for tracking user actions
  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    if (!_isInitialized) return;

    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      data: data,
      level: level,
      timestamp: DateTime.now(),
    ));
  }

  /// Show error dialog for critical errors
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? details,
  }) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Détails techniques'),
                children: [
                  SelectableText(
                    details,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
