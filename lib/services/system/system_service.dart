import 'package:flutter/foundation.dart';
import 'package:driver/services/core/service_interface.dart';

// Re-export types from other files for convenience
export 'performance_monitor.dart';
export 'developer_mode_service.dart';
export 'route_flow_service.dart';

/// {@template performance_service_interface}
/// Interface for performance monitoring operations.
/// {@endtemplate}
abstract class PerformanceServiceInterface extends ServiceInterface {
  /// {@macro performance_service_interface}
  const PerformanceServiceInterface();

  /// Start monitoring performance
  Future<ServiceResult<void>> startMonitoring();

  /// Stop monitoring performance
  Future<ServiceResult<void>> stopMonitoring();

  /// Record performance metric
  Future<ServiceResult<void>> recordMetric({
    required String name,
    required double value,
    Map<String, dynamic>? metadata,
  });

  /// Get performance metrics
  Future<ServiceResult<Map<String, PerformanceMetric>>> getMetrics();

  /// Get performance summary
  Future<ServiceResult<PerformanceSummary>> getSummary();

  /// Clear performance data
  Future<ServiceResult<void>> clearData();

  /// Check if monitoring is active
  bool get isMonitoring;
}

/// {@template developer_service_interface}
/// Interface for developer mode operations.
/// {@endtemplate}
abstract class DeveloperServiceInterface extends ServiceInterface {
  /// {@macro developer_service_interface}
  const DeveloperServiceInterface();

  /// Enable developer mode
  Future<ServiceResult<void>> enableDeveloperMode();

  /// Disable developer mode
  Future<ServiceResult<void>> disableDeveloperMode();

  /// Check if developer mode is enabled
  bool get isDeveloperModeEnabled;

  /// Get developer tools
  List<DeveloperTool> get availableTools;

  /// Execute developer tool
  Future<ServiceResult<dynamic>> executeTool(String toolName, Map<String, dynamic> params);

  /// Get debug information
  Future<ServiceResult<Map<String, dynamic>>> getDebugInfo();

  /// Clear debug data
  Future<ServiceResult<void>> clearDebugData();
}

/// {@template route_service_interface}
/// Interface for route and navigation operations.
/// {@endtemplate}
abstract class RouteServiceInterface extends ServiceInterface {
  /// {@macro route_service_interface}
  const RouteServiceInterface();

  /// Get route flow status
  Future<ServiceResult<RouteFlowStatus>> getRouteFlowStatus();

  /// Navigate to route
  Future<ServiceResult<void>> navigateToRoute(String routeName, {Map<String, dynamic>? arguments});

  /// Get available routes
  List<String> getAvailableRoutes();

  /// Check route access
  Future<ServiceResult<bool>> checkRouteAccess(String routeName);

  /// Get route parameters
  Map<String, dynamic>? getRouteParameters(String routeName);

  /// Clear route history
  Future<ServiceResult<void>> clearRouteHistory();
}

/// {@template system_service_module}
/// Main system service module that coordinates all system operations.
/// {@endtemplate}
class SystemServiceModule {
  /// {@macro system_service_module}
  const SystemServiceModule({
    required this.performanceService,
    required this.developerService,
    required this.routeService,
  });

  final PerformanceServiceInterface performanceService;
  final DeveloperServiceInterface developerService;
  final RouteServiceInterface routeService;

  /// Initialize all system services
  Future<void> initialize() async {
    await performanceService.initialize();
    await developerService.initialize();
    await routeService.initialize();
  }

  /// Dispose all system services
  Future<void> dispose() async {
    await performanceService.dispose();
    await developerService.dispose();
    await routeService.dispose();
  }

  /// Get service health status
  Map<String, bool> get healthStatus => {
    'performance': performanceService.isInitialized,
    'developer': developerService.isInitialized,
    'route': routeService.isInitialized,
  };

  /// Get system diagnostics
  Future<ServiceResult<SystemDiagnostics>> getDiagnostics() async {
    try {
      final performanceSummary = await performanceService.getSummary();
      final debugInfo = await developerService.getDebugInfo();
      final routeStatus = await routeService.getRouteFlowStatus();

      return ServiceResult.success(SystemDiagnostics(
        performance: performanceSummary.data,
        debug: debugInfo.data,
        routeStatus: routeStatus.data,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      return ServiceResult.failure(SystemServiceError(
        message: 'Failed to get system diagnostics: $e',
      ));
    }
  }
}

/// {@template performance_metric}
/// Performance metric data.
/// {@endtemplate}
class PerformanceMetric {
  /// {@macro performance_metric}
  const PerformanceMetric({
    required this.name,
    required this.value,
    required this.timestamp,
    this.metadata,
  });

  final String name;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
}

/// {@template performance_summary}
/// Performance summary data.
/// {@endtemplate}
class PerformanceSummary {
  /// {@macro performance_summary}
  const PerformanceSummary({
    required this.averageResponseTime,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.errorRate,
    required this.timestamp,
  });

  final double averageResponseTime;
  final double memoryUsage;
  final double cpuUsage;
  final double errorRate;
  final DateTime timestamp;
}

/// {@template developer_tool}
/// Developer tool information.
/// {@endtemplate}
class DeveloperTool {
  /// {@macro developer_tool}
  const DeveloperTool({
    required this.name,
    required this.description,
    required this.parameters,
  });

  final String name;
  final String description;
  final List<String> parameters;
}

/// {@template route_flow_status}
/// Route flow status information.
/// {@endtemplate}
class RouteFlowStatus {
  /// {@macro route_flow_status}
  const RouteFlowStatus({
    required this.currentRoute,
    required this.isAuthenticated,
    required this.canNavigate,
    this.previousRoute,
  });

  final String? currentRoute;
  final bool isAuthenticated;
  final bool canNavigate;
  final String? previousRoute;
}

/// {@template system_diagnostics}
/// System diagnostics information.
/// {@endtemplate}
class SystemDiagnostics {
  /// {@macro system_diagnostics}
  const SystemDiagnostics({
    required this.performance,
    required this.debug,
    required this.routeStatus,
    required this.timestamp,
  });

  final PerformanceSummary? performance;
  final Map<String, dynamic>? debug;
  final RouteFlowStatus? routeStatus;
  final DateTime timestamp;
}

/// {@template system_service_error}
/// Error specific to system services.
/// {@endtemplate}
class SystemServiceError extends ServiceError {
  /// {@macro system_service_error}
  const SystemServiceError({
    required super.message,
    super.code,
    super.details,
  });
}

// Note: Re-exports moved to top of file to avoid directive placement errors
