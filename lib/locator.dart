import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:auth_repo/auth_repo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:documents_repo/documents_repo.dart';
import 'package:driver/constants/url.dart';
import 'package:driver/services/services.dart';
import 'package:driver/services/offline/offline_earnings_rewards_service.dart';
import 'package:driver/services/analytics/analytics_service.dart';
import 'package:driver/services/trip_history/trip_history_service.dart';
import 'package:driver_status/driver_status.dart';
import 'package:finance_repo/finance_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:history_repo/history_repo.dart';
import 'package:localstorage/localstorage.dart';
import 'package:notifications_repo/notifications_repo.dart';
import 'package:profile_repo/profile_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_repo/shared_repo.dart';
import 'package:trip_repo/trip_repo.dart';
import 'package:vehicle_repo/vehicle_repo.dart';

/// Service Locator instance for dependency injection
final sl = GetIt.instance;

/// Environment configuration
enum Environment { development, staging, production }

class AppConfig {
  static Environment get environment {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    return Environment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => Environment.development,
    );
  }

  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://localhost:3002';
      case Environment.staging:
        return 'https://staging-api.vividlogix.com';
      case Environment.production:
        return AppUrl.baseUrl;
    }
  }

  static bool get isDebugMode {
    return environment != Environment.production;
  }
}

/// Modern dependency injection setup with proper configuration
Future<void> initializeDependencies() async {
  // Initialize core dependencies
  final preferences = await SharedPreferences.getInstance();
  final connectivity = Connectivity();
  
  // Register core services
  sl
    ..registerLazySingleton<SharedPreferences>(() => preferences)
    ..registerLazySingleton<Connectivity>(() => connectivity)
    ..registerLazySingleton<Localstorage>(() => Localstorage(preferences));
  
  // Register enhanced API client with modern caching
  sl.registerLazySingleton<ApiClient>(() {
    final dio = Dio();
    
    // Configure modern cache interceptor for offline support
    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      maxStale: const Duration(days: 7),
      priority: CachePriority.normal,
    );
    
    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    
    return ApiClient(
      baseUrl: AppConfig.baseUrl,
      connectivity: sl<Connectivity>(),
      dio: dio,
    );
  });
  
  // Register services
  sl
    ..registerLazySingleton<SocketService>(SocketService.new)
    ..registerLazySingleton<NotificationService>(NotificationService.new)
    ..registerLazySingleton<DeveloperModeService>(DeveloperModeService.new)
    ..registerLazySingleton<OfflineService>(OfflineService.new)
    ..registerLazySingleton<DocumentUploadService>(() => DocumentUploadService(
      documentsRepo: sl<DocumentsRepo>(),
    ))
    ..registerLazySingleton<DocumentExpiryTracker>(DocumentExpiryTracker.new)
    ..registerLazySingleton<DocumentQualityValidator>(DocumentQualityValidator.new)
    ..registerLazySingleton<ChunkedUploadService>(ChunkedUploadService.new)
    ..registerLazySingleton<DocumentBackupService>(() => DocumentBackupService(
      documentsRepo: sl<DocumentsRepo>(),
    ))
    ..registerLazySingleton<DocumentVerificationMonitor>(() => DocumentVerificationMonitor(
      documentsRepo: sl<DocumentsRepo>(),
    ))
    ..registerLazySingleton<EarningsService>(() => EarningsService(
      financeRepo: sl<FinanceRepo>(),
      tripRepo: sl<TripRepo>(),
    ))
    ..registerLazySingleton<UnifiedEarningsRewardsService>(() => UnifiedEarningsRewardsService(
      financeRepo: sl<FinanceRepo>(),
      tripRepo: sl<TripRepo>(),
    ))
    ..registerLazySingleton<OfflineEarningsRewardsService>(() => OfflineEarningsRewardsService())
    ..registerLazySingleton<AnalyticsService>(() => AnalyticsService())
    ..registerLazySingleton<TripHistoryService>(() => TripHistoryService(
      tripRepo: sl<TripRepo>(),
      financeRepo: sl<FinanceRepo>(),
    ));
  
  // Register repositories with proper dependency injection
  sl
    ..registerLazySingleton<AuthRepo>(() => AuthRepo(
      apiClient: sl<ApiClient>(),
      localStorage: sl<Localstorage>(),
    ))
    ..registerLazySingleton<DocumentsRepo>(() => DocumentsRepo(
      apiClient: sl<ApiClient>(),
      localStorage: sl<Localstorage>(),
    ))
    ..registerLazySingleton<DriverStatusRepo>(() => DriverStatusRepo(
      apiClient: sl<ApiClient>(),
      localStorage: sl<Localstorage>(),
    ))
    ..registerLazySingleton<TripRepo>(() => TripRepo(
      apiClient: sl<ApiClient>(),
      localStorage: sl<Localstorage>(),
    ))
    ..registerLazySingleton<HistoryRepo>(() => HistoryRepo(
      baseUrl: AppConfig.baseUrl,
      apiClient: sl<ApiClient>(),
      localStorage: sl<Localstorage>(),
    ))
    ..registerLazySingleton<ProfileRepo>(() => ProfileRepo(
      apiClient: sl<ApiClient>(),
    ))
    ..registerLazySingleton<VehicleRepo>(() => VehicleRepo(
      apiClient: sl<ApiClient>(),
    ))
    ..registerLazySingleton<FinanceRepo>(() => FinanceRepo(
      apiClient: sl<ApiClient>(),
      localStorage: sl<Localstorage>(),
    ))
    ..registerLazySingleton<NotificationsRepo>(() => NotificationsRepo(
      apiClient: sl<ApiClient>(),
      localStorage: sl<Localstorage>(),
    ))
    ..registerLazySingleton<SharedRepo>(() => SharedRepo(
      apiClient: sl<ApiClient>(),
      localStorage: sl<Localstorage>(),
    ))
    ..registerLazySingleton<RewardsRepo>(() => RewardsRepo(
      apiClient: sl<ApiClient>(),
      localStorage: sl<Localstorage>(),
    ));
  
  // Initialize notification service
  await sl<NotificationService>().initialize();
  
  // Initialize offline service
  await sl<OfflineService>().initialize(
    localStorage: sl<Localstorage>(),
    connectivity: sl<Connectivity>(),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
