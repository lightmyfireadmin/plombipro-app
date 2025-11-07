import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized error handling service for better user experience
/// Provides consistent error messages and logging across the app
class ErrorHandler {
  /// Handle errors with a user-friendly message
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    String message = _getErrorMessage(error);

    if (customMessage != null) {
      message = customMessage;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          action: onRetry != null
              ? SnackBarAction(
                  label: 'Réessayer',
                  textColor: Colors.white,
                  onPressed: onRetry,
                )
              : null,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    // Log error for debugging
    debugPrint('ErrorHandler: $error');
  }

  /// Show success message
  static void showSuccess(
    BuildContext context,
    String message,
  ) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show info message
  static void showInfo(
    BuildContext context,
    String message,
  ) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show warning message
  static void showWarning(
    BuildContext context,
    String message,
  ) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Show error dialog for critical errors
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onConfirm,
  }) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Get user-friendly error message based on error type
  static String _getErrorMessage(dynamic error) {
    // Handle Supabase AuthException
    if (error is AuthException) {
      switch (error.statusCode) {
        case '400':
          return 'Requête invalide. Veuillez vérifier vos informations.';
        case '401':
          return 'Email ou mot de passe incorrect.';
        case '422':
          return 'Email déjà utilisé.';
        case '429':
          return 'Trop de tentatives. Veuillez réessayer plus tard.';
        default:
          return error.message;
      }
    }

    // Handle Supabase PostgrestException
    if (error is PostgrestException) {
      switch (error.code) {
        case '23505':
          return 'Cette entrée existe déjà.';
        case '23503':
          return 'Impossible de supprimer : données liées existantes.';
        case 'PGRST116':
          return 'Aucune donnée trouvée.';
        default:
          return 'Erreur de base de données: ${error.message}';
      }
    }

    // Handle network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return 'Pas de connexion internet. Veuillez vérifier votre connexion.';
    }

    // Handle timeout errors
    if (error.toString().contains('TimeoutException')) {
      return 'La requête a expiré. Veuillez réessayer.';
    }

    // Handle format exceptions
    if (error is FormatException) {
      return 'Format de données invalide.';
    }

    // Default error message
    return 'Une erreur est survenue: ${error.toString()}';
  }

  /// Wrap async operations with error handling
  static Future<T?> tryCatch<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? errorMessage,
    VoidCallback? onError,
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (error) {
      if (showError && context.mounted) {
        handleError(
          context,
          error,
          customMessage: errorMessage,
          onRetry: onError,
        );
      }
      return null;
    }
  }

  /// Validate input and show error if invalid
  static bool validateInput(
    BuildContext context,
    bool isValid,
    String errorMessage,
  ) {
    if (!isValid && context.mounted) {
      showWarning(context, errorMessage);
    }
    return isValid;
  }
}

/// Extension to make error handling easier
extension ErrorHandlerExtension on BuildContext {
  void handleError(dynamic error, {String? customMessage, VoidCallback? onRetry}) {
    ErrorHandler.handleError(this, error, customMessage: customMessage, onRetry: onRetry);
  }

  void showSuccess(String message) {
    ErrorHandler.showSuccess(this, message);
  }

  void showInfo(String message) {
    ErrorHandler.showInfo(this, message);
  }

  void showWarning(String message) {
    ErrorHandler.showWarning(this, message);
  }

  Future<void> showErrorDialog(String title, String message, {VoidCallback? onConfirm}) {
    return ErrorHandler.showErrorDialog(this, title, message, onConfirm: onConfirm);
  }

  Future<bool> showConfirmationDialog(
    String title,
    String message, {
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) {
    return ErrorHandler.showConfirmationDialog(
      this,
      title,
      message,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }
}
