import 'package:equatable/equatable.dart';

/// Modern data state management with comprehensive error handling
abstract class DataState<T> extends Equatable {
  const DataState({this.data, this.error, this.isLoading = false});
  
  final T? data;
  final DataError? error;
  final bool isLoading;

  /// Returns true if the state represents a successful operation
  bool get isSuccess => this is DataSuccess<T>;
  
  /// Returns true if the state represents a failed operation
  bool get isFailure => this is DataFailed<T>;
  
  /// Returns true if the state represents a loading operation
  bool get isLoadingState => this is DataLoading<T>;
  
  /// Returns true if the state has data
  bool get hasData => data != null;
  
  /// Returns true if the state has an error
  bool get hasError => error != null;

  @override
  List<Object?> get props => [data, error, isLoading];
}

/// Success state with data
class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data, isLoading: false);
  
  @override
  List<Object?> get props => [data];
}

/// Loading state
class DataLoading<T> extends DataState<T> {
  const DataLoading({T? data}) : super(data: data, isLoading: true);
  
  @override
  List<Object?> get props => [data, isLoading];
}

/// Failed state with error
class DataFailed<T> extends DataState<T> {
  const DataFailed(DataError error, {T? data}) : super(data: data, error: error, isLoading: false);
  
  @override
  List<Object?> get props => [data, error];
}

/// Comprehensive error model with structured information
class DataError extends Equatable {
  DataError({
    required this.message,
    required this.type,
    this.statusCode,
    this.code,
    this.details,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// User-friendly error message
  final String message;
  
  /// Type of error for categorization
  final DataErrorType type;
  
  /// HTTP status code if applicable
  final int? statusCode;
  
  /// Optional error code from backend
  final String? code;
  
  /// Additional error details
  final Map<String, dynamic>? details;
  
  /// Stack trace for debugging
  final StackTrace? stackTrace;
  
  /// Timestamp when error occurred
  final DateTime timestamp;

  /// Creates a network-related error
  factory DataError.network(String message, {String? code, int? statusCode}) {
    return DataError(
      message: message,
      type: DataErrorType.network,
      code: code,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a validation error
  factory DataError.validation(String message, {Map<String, dynamic>? details}) {
    return DataError(
      message: message,
      type: DataErrorType.validation,
      details: details,
      timestamp: DateTime.now(),
    );
  }

  /// Creates an authentication error
  factory DataError.authentication(String message, {int? statusCode}) {
    return DataError(
      message: message,
      type: DataErrorType.authentication,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }

  /// Creates an authorization error
  factory DataError.authorization(String message, {int? statusCode}) {
    return DataError(
      message: message,
      type: DataErrorType.authorization,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a server error
  factory DataError.server(String message, {String? code, int? statusCode}) {
    return DataError(
      message: message,
      type: DataErrorType.server,
      code: code,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }

  /// Creates an unknown error
  factory DataError.unknown(String message, {StackTrace? stackTrace}) {
    return DataError(
      message: message,
      type: DataErrorType.unknown,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );
  }

  /// Creates an offline error
  factory DataError.offline(String message) {
    return DataError(
      message: message,
      type: DataErrorType.offline,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a timeout error
  factory DataError.timeout(String message) {
    return DataError(
      message: message,
      type: DataErrorType.timeout,
      timestamp: DateTime.now(),
    );
  }

  /// Get user-friendly error message
  String getErrorMessage() {
    switch (type) {
      case DataErrorType.network:
        return 'Network error: $message';
      case DataErrorType.validation:
        return 'Validation error: $message';
      case DataErrorType.authentication:
        return 'Authentication failed: $message';
      case DataErrorType.authorization:
        return 'Access denied: $message';
      case DataErrorType.server:
        return 'Server error: $message';
      case DataErrorType.offline:
        return 'No internet connection: $message';
      case DataErrorType.timeout:
        return 'Request timeout: $message';
      case DataErrorType.unknown:
        return 'An unexpected error occurred: $message';
    }
  }

  /// Get error severity level
  ErrorSeverity get severity {
    switch (type) {
      case DataErrorType.authentication:
      case DataErrorType.authorization:
        return ErrorSeverity.critical;
      case DataErrorType.server:
      case DataErrorType.network:
        return ErrorSeverity.high;
      case DataErrorType.validation:
      case DataErrorType.timeout:
        return ErrorSeverity.medium;
      case DataErrorType.offline:
      case DataErrorType.unknown:
        return ErrorSeverity.low;
    }
  }

  @override
  List<Object?> get props => [message, type, statusCode, code, details, timestamp];

  @override
  String toString() => 'DataError($type: $message)';
}

/// Types of data errors
enum DataErrorType {
  network,
  validation,
  authentication,
  authorization,
  server,
  offline,
  timeout,
  unknown,
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}


/// Extension for easy DataState creation
extension DataStateExtension<T> on T {
  /// Creates a success state
  DataSuccess<T> toSuccess() => DataSuccess(this);
}

/// Extension for Future to convert to DataState
extension FutureDataStateExtension<T> on Future<T> {
  /// Converts Future to DataState with proper error handling
  Future<DataState<T>> toDataState() async {
    try {
      final data = await this;
      return DataSuccess(data);
    } on DataError catch (e) {
      return DataFailed<T>(e);
    } catch (e, stackTrace) {
      return DataFailed<T>(
        DataError.unknown(
          e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }
}