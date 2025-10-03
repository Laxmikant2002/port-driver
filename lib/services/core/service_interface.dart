import 'package:flutter/foundation.dart';

/// {@template service_interface}
/// Base interface for all services in the application.
/// Provides common lifecycle methods and error handling.
/// {@endtemplate}
abstract class ServiceInterface {
  /// {@macro service_interface}
  const ServiceInterface();

  /// Initialize the service
  Future<void> initialize();

  /// Dispose the service and clean up resources
  Future<void> dispose();

  /// Check if the service is initialized
  bool get isInitialized;

  /// Service name for logging and debugging
  String get serviceName;
}

/// {@template singleton_service}
/// Base class for singleton services with proper lifecycle management.
/// {@endtemplate}
abstract class SingletonService implements ServiceInterface {
  /// {@macro singleton_service}
  const SingletonService();

  /// Get the singleton instance
  static T getInstance<T extends SingletonService>() {
    throw UnimplementedError('getInstance must be implemented by subclasses');
  }
}

/// {@template service_error}
/// Base class for service-specific errors.
/// {@endtemplate}
abstract class ServiceError implements Exception {
  /// {@macro service_error}
  const ServiceError({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  @override
  String toString() => 'ServiceError: $message';
}

/// {@template service_result}
/// Generic result wrapper for service operations.
/// {@endtemplate}
sealed class ServiceResult<T> {
  /// {@macro service_result}
  const ServiceResult();

  /// Success result
  const factory ServiceResult.success(T data) = ServiceSuccess<T>;

  /// Failure result
  const factory ServiceResult.failure(ServiceError error) = ServiceFailure<T>;

  /// Check if result is successful
  bool get isSuccess => this is ServiceSuccess<T>;

  /// Check if result is failure
  bool get isFailure => this is ServiceFailure<T>;

  /// Get data if successful, null otherwise
  T? get data => isSuccess ? (this as ServiceSuccess<T>).data : null;

  /// Get error if failed, null otherwise
  ServiceError? get error => isFailure ? (this as ServiceFailure<T>).error : null;
}

/// {@template service_success}
/// Success result containing data.
/// {@endtemplate}
final class ServiceSuccess<T> extends ServiceResult<T> {
  /// {@macro service_success}
  const ServiceSuccess(this.data);

  final T data;

  @override
  String toString() => 'ServiceSuccess(data: $data)';
}

/// {@template service_failure}
/// Failure result containing error.
/// {@endtemplate}
final class ServiceFailure<T> extends ServiceResult<T> {
  /// {@macro service_failure}
  const ServiceFailure(this.error);

  final ServiceError error;

  @override
  String toString() => 'ServiceFailure(error: $error)';
}

/// {@template service_logger}
/// Service for logging service operations.
/// {@endtemplate}
class ServiceLogger {
  /// {@macro service_logger}
  const ServiceLogger();

  /// Log service initialization
  void logInitialization(String serviceName) {
    debugPrint('🔧 Initializing service: $serviceName');
  }

  /// Log service disposal
  void logDisposal(String serviceName) {
    debugPrint('🗑️ Disposing service: $serviceName');
  }

  /// Log service operation
  void logOperation(String serviceName, String operation, {Object? data}) {
    debugPrint('⚙️ $serviceName: $operation${data != null ? ' - $data' : ''}');
  }

  /// Log service error
  void logError(String serviceName, String operation, Object error) {
    debugPrint('❌ $serviceName: $operation failed - $error');
  }

  /// Log service success
  void logSuccess(String serviceName, String operation, {Object? data}) {
    debugPrint('✅ $serviceName: $operation succeeded${data != null ? ' - $data' : ''}');
  }
}

/// {@template service_registry}
/// Registry for managing service instances and their lifecycle.
/// {@endtemplate}
class ServiceRegistry {
  /// {@macro service_registry}
  const ServiceRegistry();

  static final Map<Type, ServiceInterface> _services = {};
  static final ServiceLogger _logger = const ServiceLogger();

  /// Register a service instance
  static void register<T extends ServiceInterface>(T service) {
    _services[T] = service;
    _logger.logInitialization(service.serviceName);
  }

  /// Get a service instance
  static T get<T extends ServiceInterface>() {
    final service = _services[T];
    if (service == null) {
      throw _ServiceNotFoundError(
        message: 'Service ${T.toString()} not registered',
        code: 'SERVICE_NOT_FOUND',
      );
    }
    return service as T;
  }

  /// Check if service is registered
  static bool isRegistered<T extends ServiceInterface>() {
    return _services.containsKey(T);
  }

  /// Initialize all registered services
  static Future<void> initializeAll() async {
    for (final service in _services.values) {
      if (!service.isInitialized) {
        await service.initialize();
      }
    }
  }

  /// Dispose all registered services
  static Future<void> disposeAll() async {
    for (final service in _services.values) {
      await service.dispose();
      _logger.logDisposal(service.serviceName);
    }
    _services.clear();
  }

  /// Get all registered service names
  static List<String> get registeredServices {
    return _services.values.map((s) => s.serviceName).toList();
  }
}

/// Concrete implementation of ServiceError for service not found
class _ServiceNotFoundError extends ServiceError {
  const _ServiceNotFoundError({
    required super.message,
    super.code,
    super.details,
  });
}
