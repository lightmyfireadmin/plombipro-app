/// ============================================================================
/// ULTIMATE DATABASE EXCEPTION HANDLING SYSTEM
/// Provides comprehensive, specific error handling for all database operations
/// ============================================================================

/// Base class for all database-related exceptions
class DatabaseException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const DatabaseException({
    required this.message,
    required this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'DatabaseException [$code]: $message';
  }

  /// Returns a user-friendly error message
  String get userMessage {
    return message;
  }

  /// Returns a detailed error message for logging
  String get detailedMessage {
    final buffer = StringBuffer();
    buffer.writeln('DatabaseException:');
    buffer.writeln('  Code: $code');
    buffer.writeln('  Message: $message');
    if (originalError != null) {
      buffer.writeln('  Original Error: $originalError');
    }
    if (stackTrace != null) {
      buffer.writeln('  Stack Trace:');
      buffer.writeln(stackTrace.toString());
    }
    return buffer.toString();
  }
}

/// ============================================================================
/// SECURITY EXCEPTIONS
/// ============================================================================

/// Thrown when Row Level Security (RLS) policy denies access
class RLSViolationException extends DatabaseException {
  final String? tableName;

  RLSViolationException({
    required String message,
    this.tableName,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'RLS_VIOLATION',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory RLSViolationException.accessDenied({
    String? tableName,
    String? operation,
  }) {
    return RLSViolationException(
      message: operation != null
          ? 'Accès refusé: vous n\'avez pas les permissions pour $operation sur ${tableName ?? "cette ressource"}'
          : 'Accès refusé à ${tableName ?? "cette ressource"}',
      tableName: tableName,
    );
  }

  @override
  String get userMessage =>
      'Vous n\'avez pas les permissions nécessaires pour effectuer cette opération.';
}

/// Thrown when authentication fails or user is not authenticated
class AuthenticationException extends DatabaseException {
  AuthenticationException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'AUTH_FAILED',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory AuthenticationException.notAuthenticated() {
    return AuthenticationException(
      message: 'Utilisateur non authentifié',
    );
  }

  @override
  String get userMessage =>
      'Vous devez être connecté pour effectuer cette opération.';
}

/// ============================================================================
/// CONSTRAINT VIOLATION EXCEPTIONS
/// ============================================================================

/// Thrown when a unique constraint is violated (e.g., duplicate key)
class DuplicateKeyException extends DatabaseException {
  final String? fieldName;
  final dynamic duplicateValue;

  DuplicateKeyException({
    required String message,
    this.fieldName,
    this.duplicateValue,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'DUPLICATE_KEY',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory DuplicateKeyException.fromField(String fieldName,
      [dynamic value]) {
    return DuplicateKeyException(
      message: value != null
          ? 'La valeur "$value" existe déjà pour le champ $fieldName'
          : 'Une valeur en double a été détectée pour $fieldName',
      fieldName: fieldName,
      duplicateValue: value,
    );
  }

  @override
  String get userMessage {
    if (fieldName != null) {
      final friendlyFieldName = _getFriendlyFieldName(fieldName!);
      return 'Cette $friendlyFieldName existe déjà dans le système.';
    }
    return 'Cette valeur existe déjà.';
  }

  String _getFriendlyFieldName(String field) {
    const fieldMap = {
      'email': 'adresse e-mail',
      'phone': 'numéro de téléphone',
      'invoice_number': 'numéro de facture',
      'quote_number': 'numéro de devis',
      'reference': 'référence',
      'siret': 'numéro SIRET',
      'vat_number': 'numéro de TVA',
    };
    return fieldMap[field.toLowerCase()] ?? field;
  }
}

/// Thrown when a foreign key constraint is violated
class ForeignKeyViolationException extends DatabaseException {
  final String? constraintName;
  final String? tableName;
  final String? referencedTable;

  ForeignKeyViolationException({
    required String message,
    this.constraintName,
    this.tableName,
    this.referencedTable,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'FOREIGN_KEY_VIOLATION',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory ForeignKeyViolationException.referenceNotFound(
    String resourceType,
  ) {
    return ForeignKeyViolationException(
      message: 'La ressource référencée ($resourceType) n\'existe pas',
      referencedTable: resourceType,
    );
  }

  factory ForeignKeyViolationException.cannotDelete(
    String resourceType,
    String dependentType,
  ) {
    return ForeignKeyViolationException(
      message:
          'Impossible de supprimer ce $resourceType car il est référencé par des $dependentType',
      tableName: resourceType,
      referencedTable: dependentType,
    );
  }

  @override
  String get userMessage {
    if (referencedTable != null && tableName != null) {
      return 'Impossible de supprimer: cette ressource est utilisée ailleurs.';
    }
    return 'Cette opération viole une contrainte de référence.';
  }
}

/// Thrown when a check constraint is violated
class CheckConstraintViolationException extends DatabaseException {
  final String? constraintName;
  final String? fieldName;

  CheckConstraintViolationException({
    required String message,
    this.constraintName,
    this.fieldName,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'CHECK_CONSTRAINT_VIOLATION',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory CheckConstraintViolationException.invalidValue(
    String fieldName,
    String reason,
  ) {
    return CheckConstraintViolationException(
      message: 'Valeur invalide pour $fieldName: $reason',
      fieldName: fieldName,
    );
  }

  @override
  String get userMessage =>
      fieldName != null
          ? 'La valeur fournie pour $fieldName est invalide.'
          : 'Les données fournies ne respectent pas les contraintes.';
}

/// Thrown when a NOT NULL constraint is violated
class NotNullViolationException extends DatabaseException {
  final String? fieldName;

  NotNullViolationException({
    required String message,
    this.fieldName,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'NOT_NULL_VIOLATION',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory NotNullViolationException.missingField(String fieldName) {
    return NotNullViolationException(
      message: 'Le champ obligatoire "$fieldName" est manquant',
      fieldName: fieldName,
    );
  }

  @override
  String get userMessage =>
      fieldName != null
          ? 'Le champ "$fieldName" est obligatoire.'
          : 'Un champ obligatoire est manquant.';
}

/// ============================================================================
/// OPERATION EXCEPTIONS
/// ============================================================================

/// Thrown when a record is not found in the database
class RecordNotFoundException extends DatabaseException {
  final String? resourceType;
  final String? resourceId;

  RecordNotFoundException({
    required String message,
    this.resourceType,
    this.resourceId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'NOT_FOUND',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory RecordNotFoundException.byId(String resourceType, String id) {
    return RecordNotFoundException(
      message: '$resourceType avec l\'ID "$id" introuvable',
      resourceType: resourceType,
      resourceId: id,
    );
  }

  factory RecordNotFoundException.generic(String resourceType) {
    return RecordNotFoundException(
      message: '$resourceType introuvable',
      resourceType: resourceType,
    );
  }

  @override
  String get userMessage {
    final type = _getFriendlyResourceType(resourceType);
    return resourceId != null
        ? '$type introuvable.'
        : 'La ressource demandée est introuvable.';
  }

  String _getFriendlyResourceType(String? type) {
    if (type == null) return 'Ressource';

    const typeMap = {
      'client': 'Client',
      'quote': 'Devis',
      'invoice': 'Facture',
      'product': 'Produit',
      'payment': 'Paiement',
      'appointment': 'Rendez-vous',
      'job_site': 'Chantier',
    };
    return typeMap[type.toLowerCase()] ?? type;
  }
}

/// Thrown when a database operation times out
class DatabaseTimeoutException extends DatabaseException {
  final Duration? timeout;

  DatabaseTimeoutException({
    required String message,
    this.timeout,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'TIMEOUT',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String get userMessage =>
      'L\'opération a pris trop de temps. Veuillez réessayer.';
}

/// Thrown when there's a network connectivity issue
class DatabaseConnectionException extends DatabaseException {
  DatabaseConnectionException({
    required String message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'CONNECTION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory DatabaseConnectionException.networkError() {
    return DatabaseConnectionException(
      message: 'Erreur de connexion au serveur',
    );
  }

  @override
  String get userMessage =>
      'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
}

/// ============================================================================
/// VALIDATION EXCEPTIONS
/// ============================================================================

/// Thrown when data validation fails before database operation
class ValidationException extends DatabaseException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException({
    required String message,
    this.fieldErrors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'VALIDATION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory ValidationException.multipleFields(
      Map<String, List<String>> errors) {
    final errorMessages =
        errors.entries.map((e) => '${e.key}: ${e.value.join(", ")}').join('; ');
    return ValidationException(
      message: 'Erreurs de validation: $errorMessages',
      fieldErrors: errors,
    );
  }

  factory ValidationException.singleField(String field, String error) {
    return ValidationException(
      message: 'Erreur de validation pour $field: $error',
      fieldErrors: {
        field: [error]
      },
    );
  }

  @override
  String get userMessage {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final firstError = fieldErrors!.entries.first;
      return '${firstError.key}: ${firstError.value.first}';
    }
    return 'Les données fournies sont invalides.';
  }
}

/// ============================================================================
/// TRANSACTION EXCEPTIONS
/// ============================================================================

/// Thrown when a transaction fails
class TransactionException extends DatabaseException {
  final String? transactionName;

  TransactionException({
    required String message,
    this.transactionName,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'TRANSACTION_FAILED',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String get userMessage =>
      'L\'opération a échoué. Aucune modification n\'a été effectuée.';
}

/// ============================================================================
/// EXCEPTION PARSER
/// ============================================================================

/// Utility class to parse database errors and convert them to specific exceptions
class DatabaseExceptionParser {
  /// Parses a database error and returns the appropriate specific exception
  static DatabaseException parse(
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    if (error == null) {
      return DatabaseException(
        message: 'Erreur de base de données inconnue',
        code: 'UNKNOWN',
        stackTrace: stackTrace,
      );
    }

    final errorString = error.toString().toLowerCase();
    final errorMessage = error.toString();

    // RLS Violations
    if (errorString.contains('row-level security') ||
        errorString.contains('rls') ||
        errorString.contains('policy') && errorString.contains('denied')) {
      return RLSViolationException.accessDenied();
    }

    // Authentication
    if (errorString.contains('not authenticated') ||
        errorString.contains('invalid token') ||
        errorString.contains('jwt')) {
      return AuthenticationException.notAuthenticated();
    }

    // Duplicate Key
    if (errorString.contains('duplicate key') ||
        errorString.contains('unique constraint') ||
        errorString.contains('already exists')) {
      final field = _extractFieldName(errorString);
      return DuplicateKeyException.fromField(field ?? 'unknown');
    }

    // Foreign Key Violations
    if (errorString.contains('foreign key') ||
        errorString.contains('violates foreign key constraint')) {
      if (errorString.contains('delete')) {
        return ForeignKeyViolationException.cannotDelete(
            'ressource', 'éléments dépendants');
      }
      return ForeignKeyViolationException.referenceNotFound('ressource');
    }

    // Check Constraints
    if (errorString.contains('check constraint') ||
        errorString.contains('violates check')) {
      final field = _extractFieldName(errorString);
      return CheckConstraintViolationException.invalidValue(
        field ?? 'unknown',
        'contrainte de validation',
      );
    }

    // NOT NULL
    if (errorString.contains('not null') ||
        errorString.contains('null value')) {
      final field = _extractFieldName(errorString);
      return NotNullViolationException.missingField(field ?? 'unknown');
    }

    // Not Found
    if (errorString.contains('not found') ||
        errorString.contains('no rows') ||
        errorString.contains('404')) {
      return RecordNotFoundException.generic('Ressource');
    }

    // Timeout
    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return DatabaseTimeoutException(
        message: errorMessage,
      );
    }

    // Connection
    if (errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('offline')) {
      return DatabaseConnectionException.networkError();
    }

    // Generic fallback
    return DatabaseException(
      message: errorMessage,
      code: 'DATABASE_ERROR',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Extracts field name from error message
  static String? _extractFieldName(String errorMessage) {
    // Try to extract field name from common error patterns
    final patterns = [
      RegExp(r'column "([^"]+)"'),
      RegExp(r'field "([^"]+)"'),
      RegExp(r'key \(([^)]+)\)'),
      RegExp(r'constraint "([^"]+)"'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(errorMessage);
      if (match != null && match.groupCount > 0) {
        return match.group(1);
      }
    }

    return null;
  }
}

/// ============================================================================
/// EXCEPTION HANDLER MIXIN
/// ============================================================================

/// Mixin to provide consistent error handling across repositories and services
mixin DatabaseExceptionHandler {
  /// Wraps a database operation and converts errors to specific exceptions
  Future<T> handleDatabaseOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      return await operation();
    } on DatabaseException {
      rethrow; // Already a DatabaseException, just rethrow
    } catch (error, stackTrace) {
      // Parse and throw specific exception
      throw DatabaseExceptionParser.parse(error, stackTrace);
    }
  }

  /// Handles a database operation with optional logging
  Future<T> handleDatabaseOperationWithLogging<T>(
    Future<T> Function() operation, {
    required String operationName,
    void Function(String message)? logger,
  }) async {
    try {
      logger?.call('Starting $operationName');
      final result = await operation();
      logger?.call('Completed $operationName successfully');
      return result;
    } on DatabaseException catch (e) {
      logger?.call('Database error in $operationName: ${e.detailedMessage}');
      rethrow;
    } catch (error, stackTrace) {
      logger?.call('Unexpected error in $operationName: $error');
      throw DatabaseExceptionParser.parse(error, stackTrace);
    }
  }
}
