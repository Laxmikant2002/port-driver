/// Modern Services Architecture
/// 
/// This file provides a clean, organized export of all services
/// following modern Flutter/Dart patterns and best practices.

// Core service interfaces and utilities
export 'core/service_interface.dart';

// Service modules
export 'document/document.dart';
export 'location/location.dart';
export 'notification/notification.dart';
export 'network/network.dart';
export 'system/system.dart';
export 'earnings/earnings.dart';
export 'offline/offline.dart';
export 'analytics/analytics.dart';
export 'trip_history/trip_history.dart';

/// {@template services_registry}
/// Main registry for all service modules.
/// Provides centralized access to all service modules.
/// {@endtemplate}
class ServicesRegistry {
  /// {@macro services_registry}
  const ServicesRegistry();

  static DocumentServiceModule? _documentModule;
  static LocationServiceModule? _locationModule;
  static NotificationServiceModule? _notificationModule;
  static NetworkServiceModule? _networkModule;
  static SystemServiceModule? _systemModule;

  /// Initialize all service modules
  static Future<void> initializeAll() async {
    await _documentModule?.initialize();
    await _locationModule?.initialize();
    await _notificationModule?.initialize();
    await _networkModule?.initialize();
    await _systemModule?.initialize();
  }

  /// Dispose all service modules
  static Future<void> disposeAll() async {
    await _documentModule?.dispose();
    await _locationModule?.dispose();
    await _notificationModule?.dispose();
    await _networkModule?.dispose();
    await _systemModule?.dispose();
  }

  /// Get document service module
  static DocumentServiceModule get documentModule {
    if (_documentModule == null) {
      throw StateError('Document service module not initialized');
    }
    return _documentModule!;
  }

  /// Get location service module
  static LocationServiceModule get locationModule {
    if (_locationModule == null) {
      throw StateError('Location service module not initialized');
    }
    return _locationModule!;
  }

  /// Get notification service module
  static NotificationServiceModule get notificationModule {
    if (_notificationModule == null) {
      throw StateError('Notification service module not initialized');
    }
    return _notificationModule!;
  }

  /// Get network service module
  static NetworkServiceModule get networkModule {
    if (_networkModule == null) {
      throw StateError('Network service module not initialized');
    }
    return _networkModule!;
  }

  /// Get system service module
  static SystemServiceModule get systemModule {
    if (_systemModule == null) {
      throw StateError('System service module not initialized');
    }
    return _systemModule!;
  }

  /// Register document service module
  static void registerDocumentModule(DocumentServiceModule module) {
    _documentModule = module;
  }

  /// Register location service module
  static void registerLocationModule(LocationServiceModule module) {
    _locationModule = module;
  }

  /// Register notification service module
  static void registerNotificationModule(NotificationServiceModule module) {
    _notificationModule = module;
  }

  /// Register network service module
  static void registerNetworkModule(NetworkServiceModule module) {
    _networkModule = module;
  }

  /// Register system service module
  static void registerSystemModule(SystemServiceModule module) {
    _systemModule = module;
  }

  /// Get health status of all modules
  static Map<String, Map<String, bool>> getHealthStatus() {
    return {
      'document': _documentModule?.healthStatus ?? {},
      'location': _locationModule?.healthStatus ?? {},
      'notification': _notificationModule?.healthStatus ?? {},
      'network': _networkModule?.healthStatus ?? {},
      'system': _systemModule?.healthStatus ?? {},
    };
  }

  /// Check if all modules are healthy
  static bool get isHealthy {
    final healthStatus = getHealthStatus();
    return healthStatus.values.every((module) => 
      module.values.every((service) => service)
    );
  }
}

/// {@template service_factory}
/// Factory for creating service instances with proper dependency injection.
/// {@endtemplate}
class ServiceFactory {
  /// {@macro service_factory}
  const ServiceFactory();

  /// Create document service module
  static DocumentServiceModule createDocumentModule({
    required DocumentsRepo documentsRepo,
    required DocumentServiceInterface uploadService,
    required DocumentQualityServiceInterface qualityService,
    required DocumentExpiryServiceInterface expiryService,
    required DocumentBackupServiceInterface backupService,
    required DocumentVerificationServiceInterface verificationService,
  }) {
    return DocumentServiceModule(
      documentsRepo: documentsRepo,
      uploadService: uploadService,
      qualityService: qualityService,
      expiryService: expiryService,
      backupService: backupService,
      verificationService: verificationService,
    );
  }

  /// Create location service module
  static LocationServiceModule createLocationModule({
    required LocationServiceInterface locationService,
    required MapServiceInterface mapService,
    required GeocodingServiceInterface geocodingService,
  }) {
    return LocationServiceModule(
      locationService: locationService,
      mapService: mapService,
      geocodingService: geocodingService,
    );
  }

  /// Create notification service module
  static NotificationServiceModule createNotificationModule({
    required NotificationServiceInterface notificationService,
    required NotificationPreferencesServiceInterface preferencesService,
    required PushNotificationServiceInterface pushService,
  }) {
    return NotificationServiceModule(
      notificationService: notificationService,
      preferencesService: preferencesService,
      pushService: pushService,
    );
  }

  /// Create network service module
  static NetworkServiceModule createNetworkModule({
    required SocketServiceInterface socketService,
    required ConnectivityServiceInterface connectivityService,
    required OfflineServiceInterface offlineService,
  }) {
    return NetworkServiceModule(
      socketService: socketService,
      connectivityService: connectivityService,
      offlineService: offlineService,
    );
  }

  /// Create system service module
  static SystemServiceModule createSystemModule({
    required PerformanceServiceInterface performanceService,
    required DeveloperServiceInterface developerService,
    required RouteServiceInterface routeService,
  }) {
    return SystemServiceModule(
      performanceService: performanceService,
      developerService: developerService,
      routeService: routeService,
    );
  }
}
