import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Base class for all failures in the application
/// Uses Freezed for immutable data classes with pattern matching
@freezed
class Failure with _$Failure {
  const Failure._();

  /// Server/API failure
  const factory Failure.server({
    required String message,
    int? statusCode,
    @Default('') String code,
  }) = ServerFailure;

  /// Network connectivity failure
  const factory Failure.network({
    required String message,
    @Default('NO_CONNECTION') String code,
  }) = NetworkFailure;

  /// Database/Cache failure
  const factory Failure.database({
    required String message,
    @Default('') String code,
  }) = DatabaseFailure;

  /// Authentication failure
  const factory Failure.authentication({
    required String message,
    @Default('UNAUTHORIZED') String code,
  }) = AuthenticationFailure;

  /// Authorization/Permission failure
  const factory Failure.authorization({
    required String message,
    @Default('FORBIDDEN') String code,
  }) = AuthorizationFailure;

  /// Validation failure (invalid input)
  const factory Failure.validation({
    required String message,
    Map<String, String>? fieldErrors,
    @Default('VALIDATION_ERROR') String code,
  }) = ValidationFailure;

  /// Not found failure (resource doesn't exist)
  const factory Failure.notFound({
    required String message,
    @Default('NOT_FOUND') String code,
  }) = NotFoundFailure;

  /// Conflict failure (resource already exists, duplicate)
  const factory Failure.conflict({
    required String message,
    @Default('CONFLICT') String code,
  }) = ConflictFailure;

  /// Timeout failure
  const factory Failure.timeout({
    required String message,
    @Default('TIMEOUT') String code,
  }) = TimeoutFailure;

  /// Unexpected/Unknown failure
  const factory Failure.unexpected({
    required String message,
    Object? exception,
    StackTrace? stackTrace,
    @Default('UNEXPECTED_ERROR') String code,
  }) = UnexpectedFailure;

  /// Business logic failure
  const factory Failure.business({
    required String message,
    @Default('BUSINESS_ERROR') String code,
  }) = BusinessFailure;

  /// Get user-friendly message
  String get userMessage => when(
        server: (msg, _, __) => msg,
        network: (msg, _) => 'Problème de connexion internet. Veuillez réessayer.',
        database: (msg, _) => 'Erreur de base de données. Veuillez réessayer.',
        authentication: (msg, _) => 'Session expirée. Veuillez vous reconnecter.',
        authorization: (msg, _) => 'Vous n\'avez pas les permissions nécessaires.',
        validation: (msg, _, __) => msg,
        notFound: (msg, _) => msg,
        conflict: (msg, _) => msg,
        timeout: (msg, _) => 'La requête a expiré. Veuillez réessayer.',
        unexpected: (msg, _, __, ___) => 'Une erreur inattendue s\'est produite.',
        business: (msg, _) => msg,
      );

  /// Whether this is a critical error that should be reported
  bool get isCritical => when(
        server: (_, statusCode, __) => statusCode != null && statusCode >= 500,
        network: (_, __) => false,
        database: (_, __) => true,
        authentication: (_, __) => false,
        authorization: (_, __) => false,
        validation: (_, __, ___) => false,
        notFound: (_, __) => false,
        conflict: (_, __) => false,
        timeout: (_, __) => false,
        unexpected: (_, __, ___, ____) => true,
        business: (_, __) => false,
      );
}

/// Extension to convert exceptions to failures
extension ExceptionToFailure on Exception {
  Failure toFailure() {
    if (this is Failure) {
      return this as Failure;
    }
    return Failure.unexpected(
      message: toString(),
      exception: this,
    );
  }
}
