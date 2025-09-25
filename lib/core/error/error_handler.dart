import 'dart:io';

/// Custom exception types for better error handling
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);
  
  final String message;
  final String? code;
  
  @override
  String toString() => 'AppException: $message${code != null ? ' ($code)' : ''}';
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.code]);
}

class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

class TimeoutException extends AppException {
  const TimeoutException(super.message, [super.code]);
}

class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// Error handling service for consistent error management
class ErrorHandler {
  /// Converts any error to a user-friendly message
  static String getDisplayMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }
    
    if (error is HttpException) {
      return 'Server error. Please try again later.';
    }
    
    if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    }
    
    if (error is TypeError) {
      return 'Something went wrong. Please try again.';
    }
    
    // Handle string errors from APIs
    if (error is String) {
      return error.isNotEmpty ? error : 'An unexpected error occurred.';
    }
    
    // Default fallback
    return 'Something went wrong. Please try again.';
  }
  
  /// Maps HTTP status codes to appropriate exceptions
  static AppException mapHttpError(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ValidationException(message, 'BAD_REQUEST');
      case 401:
        return AuthenticationException('Authentication failed. Please login again.', 'UNAUTHORIZED');
      case 403:
        return AuthenticationException('Access denied.', 'FORBIDDEN');
      case 404:
        return ServerException('Resource not found.', 'NOT_FOUND');
      case 408:
        return TimeoutException('Request timeout. Please try again.', 'TIMEOUT');
      case 422:
        return ValidationException(message, 'VALIDATION_ERROR');
      case 429:
        return ServerException('Too many requests. Please try again later.', 'RATE_LIMIT');
      case 500:
        return ServerException('Internal server error. Please try again later.', 'INTERNAL_ERROR');
      case 502:
        return NetworkException('Bad gateway. Please try again later.', 'BAD_GATEWAY');
      case 503:
        return ServerException('Service unavailable. Please try again later.', 'SERVICE_UNAVAILABLE');
      case 504:
        return TimeoutException('Gateway timeout. Please try again.', 'GATEWAY_TIMEOUT');
      default:
        if (statusCode >= 500) {
          return ServerException('Server error. Please try again later.', 'SERVER_ERROR');
        } else if (statusCode >= 400) {
          return ValidationException(message, 'CLIENT_ERROR');
        } else {
          return ServerException('Unexpected error occurred.', 'UNKNOWN_ERROR');
        }
    }
  }
  
  /// Creates appropriate exception based on error type
  static AppException createException(dynamic error) {
    if (error is AppException) {
      return error;
    }
    
    if (error is SocketException) {
      return const NetworkException('No internet connection. Please check your network and try again.');
    }
    
    if (error is HttpException) {
      return ServerException('Server error: ${error.message}');
    }
    
    if (error is FormatException) {
      return ValidationException('Invalid data format: ${error.message}');
    }
    
    return ServerException(getDisplayMessage(error));
  }
  
  /// Logs error for debugging (in development) or analytics (in production)
  static void logError(dynamic error, StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    // In development, print to console
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      print('ERROR${context != null ? ' [$context]' : ''}: $error');
      if (stackTrace != null) {
        print('STACK TRACE: $stackTrace');
      }
      if (additionalData != null) {
        print('ADDITIONAL DATA: $additionalData');
      }
    }
    
    // In production, send to analytics/crash reporting
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, context: context);
    // Analytics.trackError(error, context, additionalData);
  }
  
  /// Handles error with logging and returns user message
  static String handleError(dynamic error, {
    String? context,
    Map<String, dynamic>? additionalData,
    StackTrace? stackTrace,
  }) {
    logError(error, stackTrace, context: context, additionalData: additionalData);
    return getDisplayMessage(error);
  }
}

/// Mixin for error handling in BLoCs
mixin ErrorHandlerMixin {
  /// Handles error and returns formatted message
  String handleError(dynamic error, {String? context}) {
    return ErrorHandler.handleError(
      error,
      context: context ?? runtimeType.toString(),
    );
  }
  
  /// Creates appropriate exception
  AppException createException(dynamic error) {
    return ErrorHandler.createException(error);
  }
  
  /// Logs error for debugging
  void logError(dynamic error, StackTrace? stackTrace, {String? context}) {
    ErrorHandler.logError(
      error,
      stackTrace,
      context: context ?? runtimeType.toString(),
    );
  }
}

/// Result wrapper for handling success/failure states
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.error, [this.stackTrace]);
  final AppException error;
  final StackTrace? stackTrace;
  
  String get message => error.message;
}

/// Extensions for Result handling
extension ResultExtensions<T> on Result<T> {
  /// Returns true if result is success
  bool get isSuccess => this is Success<T>;
  
  /// Returns true if result is failure
  bool get isFailure => this is Failure<T>;
  
  /// Returns data if success, null if failure
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  
  /// Returns error if failure, null if success
  AppException? get errorOrNull => isFailure ? (this as Failure<T>).error : null;
  
  /// Executes callback on success
  Result<T> onSuccess(void Function(T data) callback) {
    if (isSuccess) {
      callback((this as Success<T>).data);
    }
    return this;
  }
  
  /// Executes callback on failure
  Result<T> onFailure(void Function(AppException error) callback) {
    if (isFailure) {
      callback((this as Failure<T>).error);
    }
    return this;
  }
  
  /// Maps success data to new type
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T> success => Success(mapper(success.data)),
      Failure<T> failure => Failure(failure.error, failure.stackTrace),
    };
  }
  
  /// Returns data or throws error
  T getOrThrow() {
    return switch (this) {
      Success<T> success => success.data,
      Failure<T> failure => throw failure.error,
    };
  }
  
  /// Returns data or default value
  T getOrDefault(T defaultValue) {
    return switch (this) {
      Success<T> success => success.data,
      Failure<T> _ => defaultValue,
    };
  }
}