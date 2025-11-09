import 'package:freezed_annotation/freezed_annotation.dart';
import '../error/failures.dart';

part 'result.freezed.dart';

/// Result type for handling success/failure cases
/// Inspired by Rust's Result and functional programming patterns
@freezed
class Result<T> with _$Result<T> {
  const Result._();

  /// Success case with data
  const factory Result.success(T data) = Success<T>;

  /// Failure case with error
  const factory Result.failure(Failure failure) = Error<T>;

  /// Whether this result is successful
  bool get isSuccess => this is Success<T>;

  /// Whether this result is a failure
  bool get isFailure => this is Error<T>;

  /// Get the data if successful, null otherwise
  T? get dataOrNull => when(
        success: (data) => data,
        failure: (_) => null,
      );

  /// Get the failure if error, null otherwise
  Failure? get failureOrNull => when(
        success: (_) => null,
        failure: (failure) => failure,
      );

  /// Get the data or throw if failure
  T getOrThrow() => when(
        success: (data) => data,
        failure: (failure) => throw failure,
      );

  /// Get the data or return a default value
  T getOrElse(T Function() defaultValue) => when(
        success: (data) => data,
        failure: (_) => defaultValue(),
      );

  /// Map the success value to another type
  Result<R> map<R>(R Function(T data) transform) => when(
        success: (data) => Result.success(transform(data)),
        failure: (failure) => Result.failure(failure),
      );

  /// Map the failure to another failure
  Result<T> mapFailure(Failure Function(Failure failure) transform) => when(
        success: (data) => Result.success(data),
        failure: (failure) => Result.failure(transform(failure)),
      );

  /// Chain multiple async operations
  Future<Result<R>> flatMap<R>(
    Future<Result<R>> Function(T data) transform,
  ) async =>
      when(
        success: (data) => transform(data),
        failure: (failure) => Future.value(Result.failure(failure)),
      );

  /// Execute a function if successful
  Result<T> onSuccess(void Function(T data) action) {
    when(
      success: (data) => action(data),
      failure: (_) => null,
    );
    return this;
  }

  /// Execute a function if failed
  Result<T> onFailure(void Function(Failure failure) action) {
    when(
      success: (_) => null,
      failure: (failure) => action(failure),
    );
    return this;
  }

  /// Fold the result into a single value
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      when(
        success: onSuccess,
        failure: onFailure,
      );
}

/// Extension for Future<Result<T>>
extension FutureResultX<T> on Future<Result<T>> {
  /// Map the success value asynchronously
  Future<Result<R>> mapAsync<R>(R Function(T data) transform) async {
    final result = await this;
    return result.map(transform);
  }

  /// Chain multiple async operations
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T data) transform,
  ) async {
    final result = await this;
    return result.flatMap(transform);
  }

  /// Execute a function if successful
  Future<Result<T>> onSuccessAsync(void Function(T data) action) async {
    final result = await this;
    return result.onSuccess(action);
  }

  /// Execute a function if failed
  Future<Result<T>> onFailureAsync(
    void Function(Failure failure) action,
  ) async {
    final result = await this;
    return result.onFailure(action);
  }

  /// Get the data or null
  Future<T?> getDataOrNull() async {
    final result = await this;
    return result.dataOrNull;
  }

  /// Get the data or throw
  Future<T> getOrThrowAsync() async {
    final result = await this;
    return result.getOrThrow();
  }
}

/// Helper function to wrap try-catch in Result
Future<Result<T>> resultFromAsync<T>(
  Future<T> Function() operation, {
  Failure Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    final data = await operation();
    return Result.success(data);
  } on Failure catch (failure) {
    return Result.failure(failure);
  } catch (error, stackTrace) {
    if (onError != null) {
      return Result.failure(onError(error, stackTrace));
    }
    return Result.failure(
      Failure.unexpected(
        message: error.toString(),
        exception: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

/// Helper function to wrap synchronous try-catch in Result
Result<T> resultFrom<T>(
  T Function() operation, {
  Failure Function(Object error, StackTrace stackTrace)? onError,
}) {
  try {
    final data = operation();
    return Result.success(data);
  } on Failure catch (failure) {
    return Result.failure(failure);
  } catch (error, stackTrace) {
    if (onError != null) {
      return Result.failure(onError(error, stackTrace));
    }
    return Result.failure(
      Failure.unexpected(
        message: error.toString(),
        exception: error,
        stackTrace: stackTrace,
      ),
    );
  }
}
