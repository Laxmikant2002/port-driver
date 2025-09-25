import 'package:equatable/equatable.dart';

/// A generic result type that represents either success or failure.
/// 
/// This provides consistent error handling throughout the application
/// and eliminates the need for null checks and exception handling in UI code.
sealed class Result<T> extends Equatable {
  const Result();

  /// Creates a successful result with data
  const factory Result.success(T data) = Success<T>;
  
  /// Creates a failure result with error information
  const factory Result.failure(AppError error) = Failure<T>;

  /// Returns true if this result represents a success
  bool get isSuccess => this is Success<T>;
  
  /// Returns true if this result represents a failure
  bool get isFailure => this is Failure<T>;

  /// Returns the data if success, throws if failure
  T get data {
    return switch (this) {
      Success<T>(:final data) => data,
      Failure<T>() => throw StateError('Cannot get data from failure result'),
    };
  }

  /// Returns the error if failure, throws if success
  AppError get error {
    return switch (this) {
      Success<T>() => throw StateError('Cannot get error from success result'),
      Failure<T>(:final error) => error,
    };
  }

  /// Transforms the data if this is a success, otherwise returns failure as-is
  Result<U> map<U>(U Function(T data) mapper) {
    return switch (this) {
      Success<T>(:final data) => Result.success(mapper(data)),
      Failure<T>(:final error) => Result.failure(error),
    };
  }

  /// Chains operations that return Results
  Result<U> flatMap<U>(Result<U> Function(T data) mapper) {
    return switch (this) {
      Success<T>(:final data) => mapper(data),
      Failure<T>(:final error) => Result.failure(error),
    };
  }

  /// Executes different callbacks based on success/failure
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Failure<T>(:final error) => onFailure(error),
    };
  }

  /// Returns data if success, or defaultValue if failure
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(:final data) => data,
      Failure<T>() => defaultValue,
    };
  }
}

/// Success case of Result
final class Success<T> extends Result<T> {
  const Success(this.data);
  
  final T data;

  @override
  List<Object?> get props => [data];

  @override
  String toString() => 'Success($data)';
}

/// Failure case of Result
final class Failure<T> extends Result<T> {
  const Failure(this.error);
  
  final AppError error;

  @override
  List<Object?> get props => [error];

  @override
  String toString() => 'Failure($error)';
}

/// Represents application errors with structured information
class AppError extends Equatable {
  const AppError({
    required this.message,
    required this.type,
    this.code,
    this.details,
    this.stackTrace,
  });

  /// User-friendly error message
  final String message;
  
  /// Type of error for categorization
  final AppErrorType type;
  
  /// Optional error code from backend
  final String? code;
  
  /// Additional error details
  final Map<String, dynamic>? details;
  
  /// Stack trace for debugging
  final StackTrace? stackTrace;

  /// Creates a network-related error
  factory AppError.network(String message, {String? code}) {
    return AppError(
      message: message,
      type: AppErrorType.network,
      code: code,
    );
  }

  /// Creates a validation error
  factory AppError.validation(String message, {Map<String, dynamic>? details}) {
    return AppError(
      message: message,
      type: AppErrorType.validation,
      details: details,
    );
  }

  /// Creates an authentication error
  factory AppError.authentication(String message) {
    return AppError(
      message: message,
      type: AppErrorType.authentication,
    );
  }

  /// Creates an authorization error
  factory AppError.authorization(String message) {
    return AppError(
      message: message,
      type: AppErrorType.authorization,
    );
  }

  /// Creates a server error
  factory AppError.server(String message, {String? code}) {
    return AppError(
      message: message,
      type: AppErrorType.server,
      code: code,
    );
  }

  /// Creates an unknown error
  factory AppError.unknown(String message, {StackTrace? stackTrace}) {
    return AppError(
      message: message,
      type: AppErrorType.unknown,
      stackTrace: stackTrace,
    );
  }

  @override
  List<Object?> get props => [message, type, code, details];

  @override
  String toString() => 'AppError($type: $message)';
}

/// Types of application errors
enum AppErrorType {
  network,
  validation,
  authentication,
  authorization,
  server,
  unknown,
}

/// Extension to convert exceptions to Results
extension ResultExtension<T> on Future<T> {
  /// Wraps a Future in a Result, catching exceptions
  Future<Result<T>> toResult() async {
    try {
      final data = await this;
      return Result.success(data);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }
}