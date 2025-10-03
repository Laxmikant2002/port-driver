import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';

/// Comprehensive performance monitoring service
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, List<Duration>> _operationDurations = {};
  final Map<String, int> _operationCounts = {};
  final Map<String, int> _operationErrors = {};
  
  final StreamController<PerformanceMetric> _metricController = StreamController<PerformanceMetric>.broadcast();
  Stream<PerformanceMetric> get metricStream => _metricController.stream;

  /// Start timing an operation
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
  }

  /// End timing an operation and record metrics
  void endOperation(String operationName, {bool success = true}) {
    final startTime = _operationStartTimes.remove(operationName);
    if (startTime == null) {
      log('Warning: No start time found for operation: $operationName');
      return;
    }

    final duration = DateTime.now().difference(startTime);
    
    // Record duration
    _operationDurations.putIfAbsent(operationName, () => []).add(duration);
    
    // Record count
    _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;
    
    // Record errors
    if (!success) {
      _operationErrors[operationName] = (_operationErrors[operationName] ?? 0) + 1;
    }

    // Emit metric
    final metric = PerformanceMetric(
      operationName: operationName,
      duration: duration,
      success: success,
      timestamp: DateTime.now(),
    );
    _metricController.add(metric);

    // Log slow operations
    if (duration.inMilliseconds > 1000) {
      log('Slow operation detected: $operationName took ${duration.inMilliseconds}ms');
    }
  }

  /// Get performance statistics for an operation
  PerformanceStats? getOperationStats(String operationName) {
    final durations = _operationDurations[operationName];
    if (durations == null || durations.isEmpty) return null;

    durations.sort();
    
    final count = durations.length;
    final totalDuration = durations.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );
    
    final averageDuration = Duration(
      milliseconds: totalDuration.inMilliseconds ~/ count,
    );
    
    final medianDuration = durations[count ~/ 2];
    final minDuration = durations.first;
    final maxDuration = durations.last;
    
    final errorCount = _operationErrors[operationName] ?? 0;
    final successRate = ((count - errorCount) / count) * 100;

    return PerformanceStats(
      operationName: operationName,
      count: count,
      averageDuration: averageDuration,
      medianDuration: medianDuration,
      minDuration: minDuration,
      maxDuration: maxDuration,
      totalDuration: totalDuration,
      errorCount: errorCount,
      successRate: successRate,
    );
  }

  /// Get all performance statistics
  Map<String, PerformanceStats> getAllStats() {
    final stats = <String, PerformanceStats>{};
    
    for (final operationName in _operationDurations.keys) {
      final stat = getOperationStats(operationName);
      if (stat != null) {
        stats[operationName] = stat;
      }
    }
    
    return stats;
  }

  /// Clear all performance data
  void clearData() {
    _operationStartTimes.clear();
    _operationDurations.clear();
    _operationCounts.clear();
    _operationErrors.clear();
  }

  /// Get performance summary
  PerformanceSummary getSummary() {
    final allStats = getAllStats();
    
    if (allStats.isEmpty) {
      return PerformanceSummary(
        totalOperations: 0,
        averageOperationTime: Duration.zero,
        slowestOperation: null,
        fastestOperation: null,
        totalErrors: 0,
        overallSuccessRate: 100.0,
      );
    }

    final totalOperations = allStats.values.fold<int>(0, (sum, stat) => sum + stat.count);
    final totalDuration = allStats.values.fold<Duration>(
      Duration.zero,
      (sum, stat) => sum + stat.totalDuration,
    );
    final averageOperationTime = Duration(
      milliseconds: totalDuration.inMilliseconds ~/ totalOperations,
    );
    
    final slowestOperation = allStats.values.reduce((a, b) => 
      a.maxDuration > b.maxDuration ? a : b
    );
    
    final fastestOperation = allStats.values.reduce((a, b) => 
      a.minDuration < b.minDuration ? a : b
    );
    
    final totalErrors = allStats.values.fold<int>(0, (sum, stat) => sum + stat.errorCount);
    final overallSuccessRate = ((totalOperations - totalErrors) / totalOperations) * 100;

    return PerformanceSummary(
      totalOperations: totalOperations,
      averageOperationTime: averageOperationTime,
      slowestOperation: slowestOperation,
      fastestOperation: fastestOperation,
      totalErrors: totalErrors,
      overallSuccessRate: overallSuccessRate,
    );
  }

  /// Dispose resources
  void dispose() {
    _metricController.close();
  }
}

/// Performance metric for a single operation
class PerformanceMetric {
  final String operationName;
  final Duration duration;
  final bool success;
  final DateTime timestamp;

  const PerformanceMetric({
    required this.operationName,
    required this.duration,
    required this.success,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'PerformanceMetric($operationName: ${duration.inMilliseconds}ms, success: $success)';
  }
}

/// Performance statistics for an operation
class PerformanceStats {
  final String operationName;
  final int count;
  final Duration averageDuration;
  final Duration medianDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final Duration totalDuration;
  final int errorCount;
  final double successRate;

  const PerformanceStats({
    required this.operationName,
    required this.count,
    required this.averageDuration,
    required this.medianDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.totalDuration,
    required this.errorCount,
    required this.successRate,
  });

  @override
  String toString() {
    return 'PerformanceStats($operationName: count=$count, avg=${averageDuration.inMilliseconds}ms, successRate=${successRate.toStringAsFixed(1)}%)';
  }
}

/// Overall performance summary
class PerformanceSummary {
  final int totalOperations;
  final Duration averageOperationTime;
  final PerformanceStats? slowestOperation;
  final PerformanceStats? fastestOperation;
  final int totalErrors;
  final double overallSuccessRate;

  const PerformanceSummary({
    required this.totalOperations,
    required this.averageOperationTime,
    required this.slowestOperation,
    required this.fastestOperation,
    required this.totalErrors,
    required this.overallSuccessRate,
  });

  @override
  String toString() {
    return 'PerformanceSummary(totalOps=$totalOperations, avgTime=${averageOperationTime.inMilliseconds}ms, successRate=${overallSuccessRate.toStringAsFixed(1)}%)';
  }
}

/// Extension for easy performance monitoring
extension PerformanceMonitoring<T> on Future<T> {
  /// Monitor the performance of a Future operation
  Future<T> monitorPerformance(String operationName) async {
    PerformanceMonitor().startOperation(operationName);
    
    try {
      final result = await this;
      PerformanceMonitor().endOperation(operationName, success: true);
      return result;
    } catch (e) {
      PerformanceMonitor().endOperation(operationName, success: false);
      rethrow;
    }
  }
}

/// Mixin for automatic performance monitoring
mixin PerformanceMonitoringMixin {
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  /// Monitor a synchronous operation
  T monitorOperation<T>(String operationName, T Function() operation) {
    _performanceMonitor.startOperation(operationName);
    
    try {
      final result = operation();
      _performanceMonitor.endOperation(operationName, success: true);
      return result;
    } catch (e) {
      _performanceMonitor.endOperation(operationName, success: false);
      rethrow;
    }
  }

  /// Monitor an asynchronous operation
  Future<T> monitorAsyncOperation<T>(String operationName, Future<T> Function() operation) async {
    _performanceMonitor.startOperation(operationName);
    
    try {
      final result = await operation();
      _performanceMonitor.endOperation(operationName, success: true);
      return result;
    } catch (e) {
      _performanceMonitor.endOperation(operationName, success: false);
      rethrow;
    }
  }
}
