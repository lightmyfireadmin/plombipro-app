import 'dart:developer' as developer;

/// ============================================================================
/// COMPREHENSIVE LOGGING SYSTEM
/// Provides structured logging for all application operations
/// ============================================================================

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Main application logger with structured logging capabilities
class AppLogger {
  final String name;
  static final Map<String, AppLogger> _loggers = {};

  /// Private constructor
  AppLogger._(this.name);

  /// Factory constructor to get or create a logger instance
  factory AppLogger(String name) {
    return _loggers.putIfAbsent(name, () => AppLogger._(name));
  }

  /// Log a debug message
  void debug(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.debug, message, data: data, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  void info(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.info, message, data: data, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  void warning(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.warning, message, data: data, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  void error(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, data: data, error: error, stackTrace: stackTrace);
  }

  /// Log a critical error message
  void critical(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.critical, message, data: data, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelText = level.name.toUpperCase().padRight(8);

    final buffer = StringBuffer();
    buffer.write('[$timestamp] $levelText [$name] $message');

    if (data != null && data.isNotEmpty) {
      buffer.write(' | Data: ${data.toString()}');
    }

    if (error != null) {
      buffer.write(' | Error: $error');
    }

    final logMessage = buffer.toString();

    // Use dart:developer for better integration with DevTools
    developer.log(
      message,
      time: DateTime.now(),
      name: name,
      level: _getLevelValue(level),
      error: error,
      stackTrace: stackTrace,
    );

    // Also print to console for debugging
    if (_shouldPrint(level)) {
      print(logMessage);
      if (stackTrace != null) {
        print('Stack Trace:\n$stackTrace');
      }
    }
  }

  /// Get numeric level value for dart:developer
  int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500; // FINE
      case LogLevel.info:
        return 800; // INFO
      case LogLevel.warning:
        return 900; // WARNING
      case LogLevel.error:
        return 1000; // SEVERE
      case LogLevel.critical:
        return 1200; // SHOUT
    }
  }

  /// Determine if log should be printed based on level
  bool _shouldPrint(LogLevel level) {
    // In production, only print warnings and above
    // In debug mode, print everything
    const bool isDebugMode = true; // TODO: Get from environment or build mode

    if (isDebugMode) {
      return true; // Print all logs in debug mode
    }

    // In production, only print warnings and above
    return level.index >= LogLevel.warning.index;
  }

  /// Log database operation
  void logDatabaseOperation({
    required String operation,
    required String table,
    String? recordId,
    Map<String, dynamic>? data,
    Duration? duration,
  }) {
    final message = 'DB Operation: $operation on $table';
    final logData = <String, dynamic>{
      'operation': operation,
      'table': table,
      if (recordId != null) 'recordId': recordId,
      if (duration != null) 'duration_ms': duration.inMilliseconds,
      if (data != null) 'data': data,
    };
    info(message, data: logData);
  }

  /// Log database error
  void logDatabaseError({
    required String operation,
    required String table,
    required Object error,
    StackTrace? stackTrace,
  }) {
    final message = 'DB Error: $operation on $table failed';
    final logData = <String, dynamic>{
      'operation': operation,
      'table': table,
    };
    this.error(message, data: logData, error: error, stackTrace: stackTrace);
  }

  /// Log API call
  void logApiCall({
    required String endpoint,
    required String method,
    Map<String, dynamic>? params,
    Duration? duration,
  }) {
    final message = 'API Call: $method $endpoint';
    final logData = <String, dynamic>{
      'method': method,
      'endpoint': endpoint,
      if (params != null) 'params': params,
      if (duration != null) 'duration_ms': duration.inMilliseconds,
    };
    info(message, data: logData);
  }

  /// Log API error
  void logApiError({
    required String endpoint,
    required String method,
    required Object error,
    StackTrace? stackTrace,
  }) {
    final message = 'API Error: $method $endpoint failed';
    final logData = <String, dynamic>{
      'method': method,
      'endpoint': endpoint,
    };
    this.error(message, data: logData, error: error, stackTrace: stackTrace);
  }

  /// Log user action
  void logUserAction({
    required String action,
    String? screen,
    Map<String, dynamic>? data,
  }) {
    final message = 'User Action: $action';
    final logData = <String, dynamic>{
      'action': action,
      if (screen != null) 'screen': screen,
      if (data != null) ...data,
    };
    info(message, data: logData);
  }

  /// Log navigation
  void logNavigation({
    required String from,
    required String to,
    Map<String, dynamic>? params,
  }) {
    final message = 'Navigation: $from -> $to';
    final logData = <String, dynamic>{
      'from': from,
      'to': to,
      if (params != null) 'params': params,
    };
    debug(message, data: logData);
  }

  /// Log performance metric
  void logPerformance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? data,
  }) {
    final message = 'Performance: $operation took ${duration.inMilliseconds}ms';
    final logData = <String, dynamic>{
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      if (data != null) ...data,
    };

    // Warn if operation is slow (> 1 second)
    if (duration.inMilliseconds > 1000) {
      warning(message, data: logData);
    } else {
      debug(message, data: logData);
    }
  }
}

/// ============================================================================
/// LOGGER MIXIN
/// Provides easy access to logger in classes
/// ============================================================================

mixin LoggerMixin {
  late final AppLogger _logger = AppLogger(runtimeType.toString());

  AppLogger get logger => _logger;
}

/// ============================================================================
/// PERFORMANCE TIMER
/// Utility class for measuring operation duration
/// ============================================================================

class PerformanceTimer {
  final String operation;
  final AppLogger logger;
  final Stopwatch _stopwatch;
  final Map<String, dynamic>? data;

  PerformanceTimer({
    required this.operation,
    required this.logger,
    this.data,
  }) : _stopwatch = Stopwatch()..start();

  /// Stop the timer and log the performance
  void stop() {
    _stopwatch.stop();
    logger.logPerformance(
      operation: operation,
      duration: _stopwatch.elapsed,
      data: data,
    );
  }

  /// Get elapsed time
  Duration get elapsed => _stopwatch.elapsed;
}

/// ============================================================================
/// DATABASE OPERATION LOGGER MIXIN
/// Provides database-specific logging methods
/// ============================================================================

mixin DatabaseLoggerMixin on LoggerMixin {
  /// Wrap a database operation with logging
  Future<T> loggedDatabaseOperation<T>({
    required String operation,
    required String table,
    required Future<T> Function() function,
    String? recordId,
    Map<String, dynamic>? data,
  }) async {
    final timer = PerformanceTimer(
      operation: '$operation on $table',
      logger: logger,
      data: {
        'table': table,
        'operation': operation,
        if (recordId != null) 'recordId': recordId,
        if (data != null) ...data,
      },
    );

    try {
      logger.logDatabaseOperation(
        operation: operation,
        table: table,
        recordId: recordId,
        data: data,
      );

      final result = await function();

      timer.stop();
      logger.debug('$operation on $table succeeded');

      return result;
    } catch (error, stackTrace) {
      timer.stop();
      logger.logDatabaseError(
        operation: operation,
        table: table,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

/// ============================================================================
/// COMMON LOGGER INSTANCES
/// ============================================================================

class AppLoggers {
  static final database = AppLogger('Database');
  static final repository = AppLogger('Repository');
  static final service = AppLogger('Service');
  static final ui = AppLogger('UI');
  static final navigation = AppLogger('Navigation');
  static final network = AppLogger('Network');
  static final auth = AppLogger('Auth');
  static final storage = AppLogger('Storage');
}
