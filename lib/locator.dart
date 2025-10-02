import 'package:api_client/api_client.dart';
import 'package:auth_repo/auth_repo.dart';
import 'package:trip_repo/trip_repo.dart';
import 'package:documents_repo/documents_repo.dart';
import 'package:driver_status/driver_status.dart';
import 'package:history_repo/history_repo.dart';
import 'package:profile_repo/profile_repo.dart';
import 'package:vehicle_repo/vehicle_repo.dart';
import 'package:finance_repo/finance_repo.dart';
import 'package:notifications_repo/notifications_repo.dart';
import 'package:shared_repo/shared_repo.dart';
import 'package:driver/services/socket_service.dart';
import 'package:driver/services/notification_service.dart';
import 'package:driver/services/developer_mode_service.dart';
import 'package:driver/services/offline_service.dart';
import 'package:driver/constants/url.dart';
import 'package:get_it/get_it.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  sl.registerLazySingleton<SharedPreferences>(() => preferences);
  sl.registerLazySingleton<Connectivity>(() => connectivity);
  
  // Register enhanced local storage with caching
  sl.registerLazySingleton<Localstorage>(() => Localstorage(preferences));
  
  // Register enhanced API client with basic caching
  sl.registerLazySingleton<ApiClient>(() {
    final dio = Dio();
    
    // Configure basic cache interceptor for offline support
    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403, 500],
      maxStale: const Duration(days: 7),
      priority: CachePriority.normal,
      keyBuilder: (request) => '${request.method}_${request.path}_${request.queryParameters}',
    );
    
    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    
    return ApiClient(
      baseUrl: AppConfig.baseUrl,
      connectivity: sl<Connectivity>(),
      dio: dio,
    );
  });
  
  // Register socket service
  sl.registerLazySingleton<SocketService>(() => SocketService());
  
  // Register notification service
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  
  // Register developer mode service
  sl.registerLazySingleton<DeveloperModeService>(() => DeveloperModeService());
  
  // Register offline service
  sl.registerLazySingleton<OfflineService>(() => OfflineService());
  
  // Register repositories with proper dependency injection
  sl.registerLazySingleton<AuthRepo>(() => AuthRepo(
    apiClient: sl<ApiClient>(),
    localStorage: sl<Localstorage>(),
  ));
  
  sl.registerLazySingleton<DocumentsRepo>(() => DocumentsRepo(
    apiClient: sl<ApiClient>(),
    localStorage: sl<Localstorage>(),
  ));
  
  sl.registerLazySingleton<DriverStatusRepo>(() => DriverStatusRepo(
    apiClient: sl<ApiClient>(),
    localStorage: sl<Localstorage>(),
  ));
  
  sl.registerLazySingleton<TripRepo>(() => TripRepo(
    apiClient: sl<ApiClient>(),
    localStorage: sl<Localstorage>(),
  ));
  
  sl.registerLazySingleton<HistoryRepo>(() => HistoryRepo(
    apiClient: sl<ApiClient>(),
    localStorage: sl<Localstorage>(),
  ));
  
  sl.registerLazySingleton<ProfileRepo>(() => ProfileRepo(
    apiClient: sl<ApiClient>(),
  ));
  
  sl.registerLazySingleton<VehicleRepo>(() => VehicleRepo(
    apiClient: sl<ApiClient>(),
  ));
  
  sl.registerLazySingleton<FinanceRepo>(() => FinanceRepo(
    apiClient: sl<ApiClient>(),
    localStorage: sl<Localstorage>(),
  ));
  
  sl.registerLazySingleton<NotificationsRepo>(() => NotificationsRepo(
    apiClient: sl<ApiClient>(),
    localStorage: sl<Localstorage>(),
  ));
  
  sl.registerLazySingleton<SharedRepo>(() => SharedRepo(
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