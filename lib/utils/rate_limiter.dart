/// Rate limiting utility to prevent API abuse
/// Implements token bucket algorithm for client-side rate limiting
library rate_limiter;

import 'dart:collection';

/// Rate limiter using token bucket algorithm
class RateLimiter {
  final int maxRequestsPerMinute;
  final int maxRequestsPerHour;

  final Queue<DateTime> _minuteWindow = Queue<DateTime>();
  final Queue<DateTime> _hourWindow = Queue<DateTime>();

  RateLimiter({
    this.maxRequestsPerMinute = 60,
    this.maxRequestsPerHour = 1000,
  });

  /// Check if a request can be made and record it
  /// Returns true if allowed, false if rate limit exceeded
  bool allowRequest() {
    final now = DateTime.now();

    // Clean up old entries from minute window
    _minuteWindow.removeWhere((timestamp) =>
      now.difference(timestamp).inMinutes >= 1
    );

    // Clean up old entries from hour window
    _hourWindow.removeWhere((timestamp) =>
      now.difference(timestamp).inHours >= 1
    );

    // Check rate limits
    if (_minuteWindow.length >= maxRequestsPerMinute) {
      return false;
    }

    if (_hourWindow.length >= maxRequestsPerHour) {
      return false;
    }

    // Record the request
    _minuteWindow.add(now);
    _hourWindow.add(now);

    return true;
  }

  /// Get the number of requests made in the last minute
  int get requestsInLastMinute {
    final now = DateTime.now();
    _minuteWindow.removeWhere((timestamp) =>
      now.difference(timestamp).inMinutes >= 1
    );
    return _minuteWindow.length;
  }

  /// Get the number of requests made in the last hour
  int get requestsInLastHour {
    final now = DateTime.now();
    _hourWindow.removeWhere((timestamp) =>
      now.difference(timestamp).inHours >= 1
    );
    return _hourWindow.length;
  }

  /// Get remaining requests in the current minute
  int get remainingRequestsThisMinute {
    return maxRequestsPerMinute - requestsInLastMinute;
  }

  /// Get remaining requests in the current hour
  int get remainingRequestsThisHour {
    return maxRequestsPerHour - requestsInLastHour;
  }

  /// Reset all rate limit counters
  void reset() {
    _minuteWindow.clear();
    _hourWindow.clear();
  }
}

/// Global rate limiter instance
/// Configure this in main.dart based on EnvConfig
late RateLimiter globalRateLimiter;

/// Initialize the global rate limiter
void initializeRateLimiter({
  required int maxRequestsPerMinute,
  required int maxRequestsPerHour,
}) {
  globalRateLimiter = RateLimiter(
    maxRequestsPerMinute: maxRequestsPerMinute,
    maxRequestsPerHour: maxRequestsPerHour,
  );
}

/// Exception thrown when rate limit is exceeded
class RateLimitException implements Exception {
  final String message;
  final int remainingMinute;
  final int remainingHour;

  RateLimitException({
    required this.message,
    required this.remainingMinute,
    required this.remainingHour,
  });

  @override
  String toString() => 'RateLimitException: $message';
}

/// Middleware function to check rate limits before making API calls
/// Usage: await checkRateLimit() before making API call
Future<void> checkRateLimit() async {
  if (!globalRateLimiter.allowRequest()) {
    throw RateLimitException(
      message: 'Limite de requêtes dépassée. Veuillez réessayer dans quelques instants.',
      remainingMinute: globalRateLimiter.remainingRequestsThisMinute,
      remainingHour: globalRateLimiter.remainingRequestsThisHour,
    );
  }
}
