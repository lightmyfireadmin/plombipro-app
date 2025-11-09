import '../utils/result.dart';
import '../error/failures.dart';

/// Base repository interface
/// All repositories should extend this to ensure consistent error handling
abstract class BaseRepository {
  /// Execute a repository operation with consistent error handling
  Future<Result<T>> execute<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      final data = await operation();
      return Result.success(data);
    } on Failure catch (failure) {
      // Already a Failure, just wrap it
      return Result.failure(failure);
    } on Exception catch (error, stackTrace) {
      // Convert exception to appropriate failure type
      return Result.failure(_handleException(error, stackTrace, errorMessage));
    } catch (error, stackTrace) {
      // Unknown error
      return Result.failure(
        Failure.unexpected(
          message: errorMessage ?? 'Une erreur inattendue s\'est produite',
          exception: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Handle different exception types and convert to Failure
  Failure _handleException(
    Exception error,
    StackTrace stackTrace,
    String? customMessage,
  ) {
    final errorMessage = error.toString();

    // Network errors
    if (errorMessage.contains('SocketException') ||
        errorMessage.contains('NetworkException') ||
        errorMessage.contains('Failed host lookup')) {
      return Failure.network(
        message:
            customMessage ?? 'Problème de connexion. Vérifiez votre internet.',
      );
    }

    // Timeout errors
    if (errorMessage.contains('TimeoutException') ||
        errorMessage.contains('deadline')) {
      return Failure.timeout(
        message:
            customMessage ?? 'La requête a expiré. Veuillez réessayer.',
      );
    }

    // Database errors
    if (errorMessage.contains('PostgrestException') ||
        errorMessage.contains('Database') ||
        errorMessage.contains('SQL')) {
      return Failure.database(
        message: customMessage ??
            'Erreur de base de données. Veuillez réessayer.',
      );
    }

    // Authentication errors
    if (errorMessage.contains('AuthException') ||
        errorMessage.contains('401') ||
        errorMessage.contains('Unauthorized')) {
      return Failure.authentication(
        message: customMessage ??
            'Session expirée. Veuillez vous reconnecter.',
      );
    }

    // Authorization errors
    if (errorMessage.contains('403') || errorMessage.contains('Forbidden')) {
      return Failure.authorization(
        message: customMessage ??
            'Vous n\'avez pas les permissions nécessaires.',
      );
    }

    // Not found errors
    if (errorMessage.contains('404') || errorMessage.contains('Not Found')) {
      return Failure.notFound(
        message: customMessage ?? 'Ressource introuvable.',
      );
    }

    // Conflict errors
    if (errorMessage.contains('409') ||
        errorMessage.contains('Conflict') ||
        errorMessage.contains('duplicate')) {
      return Failure.conflict(
        message: customMessage ?? 'Cette ressource existe déjà.',
      );
    }

    // Server errors (5xx)
    if (errorMessage.contains('500') ||
        errorMessage.contains('502') ||
        errorMessage.contains('503') ||
        errorMessage.contains('504')) {
      return Failure.server(
        message: customMessage ??
            'Erreur serveur. Veuillez réessayer plus tard.',
      );
    }

    // Default to unexpected error
    return Failure.unexpected(
      message: customMessage ?? 'Une erreur inattendue s\'est produite',
      exception: error,
      stackTrace: stackTrace,
    );
  }

  /// Execute multiple operations and combine results
  Future<Result<List<T>>> executeAll<T>(
    List<Future<T> Function()> operations,
  ) async {
    try {
      final results = await Future.wait(
        operations.map((op) => op()),
      );
      return Result.success(results);
    } catch (error, stackTrace) {
      return Result.failure(
        Failure.unexpected(
          message: 'Erreur lors de l\'exécution de plusieurs opérations',
          exception: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
