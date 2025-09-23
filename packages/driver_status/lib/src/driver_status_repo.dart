import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'package:equatable/equatable.dart';

/// Driver status enum
enum DriverStatus {
  offline('offline', 'Offline'),
  online('online', 'Online'),
  busy('busy', 'Busy'),
  suspended('suspended', 'Suspended');

  const DriverStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static DriverStatus fromString(String value) {
    return DriverStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DriverStatus.offline,
    );
  }
}

/// Work area model
class WorkArea extends Equatable {
  const WorkArea({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius, // in kilometers
    this.isActive = true,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;

  factory WorkArea.fromJson(Map<String, dynamic> json) {
    return WorkArea(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [id, name, latitude, longitude, radius, isActive];
}

/// Driver status response model
class DriverStatusResponse extends Equatable {
  const DriverStatusResponse({
    required this.success,
    this.message,
    this.status,
    this.workArea,
    this.lastActiveAt,
    this.earningsToday,
    this.tripsToday,
  });

  final bool success;
  final String? message;
  final DriverStatus? status;
  final WorkArea? workArea;
  final DateTime? lastActiveAt;
  final double? earningsToday;
  final int? tripsToday;

  factory DriverStatusResponse.fromJson(Map<String, dynamic> json) {
    return DriverStatusResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      status: json['status'] != null 
          ? DriverStatus.fromString(json['status'] as String)
          : null,
      workArea: json['workArea'] != null
          ? WorkArea.fromJson(json['workArea'] as Map<String, dynamic>)
          : null,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      earningsToday: json['earningsToday'] != null 
          ? (json['earningsToday'] as num).toDouble()
          : null,
      tripsToday: json['tripsToday'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status?.value,
      'workArea': workArea?.toJson(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'earningsToday': earningsToday,
      'tripsToday': tripsToday,
    };
  }

  @override
  List<Object?> get props => [
        success,
        message,
        status,
        workArea,
        lastActiveAt,
        earningsToday,
        tripsToday,
      ];
}

/// Driver status repository for managing driver status and work area
class DriverStatusRepo {
  const DriverStatusRepo({
    required this.apiClient,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Get current driver status
  Future<DriverStatusResponse> getDriverStatus() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/driver/status');

      if (response is DataSuccess) {
        final data = response.data!;
        return DriverStatusResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return DriverStatusResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch driver status',
        );
      }

      return DriverStatusResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return DriverStatusResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update driver status (online/offline/busy)
  Future<DriverStatusResponse> updateDriverStatus(DriverStatus status) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        '/driver/status',
        data: {'status': status.value},
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return DriverStatusResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return DriverStatusResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to update driver status',
        );
      }

      return DriverStatusResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return DriverStatusResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Set work area for driver
  Future<DriverStatusResponse> setWorkArea(WorkArea workArea) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/driver/work-area',
        data: workArea.toJson(),
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return DriverStatusResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return DriverStatusResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to set work area',
        );
      }

      return DriverStatusResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return DriverStatusResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get available work areas
  Future<List<WorkArea>> getAvailableWorkAreas() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/driver/work-areas');

      if (response is DataSuccess) {
        final data = response.data!;
        final workAreas = (data['workAreas'] as List<dynamic>)
            .map((e) => WorkArea.fromJson(e as Map<String, dynamic>))
            .toList();
        return workAreas;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Update driver location in real-time
  Future<DriverStatusResponse> updateLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/driver/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return DriverStatusResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return DriverStatusResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to update location',
        );
      }

      return DriverStatusResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return DriverStatusResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get driver dashboard data
  Future<DriverStatusResponse> getDashboardData() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/driver/dashboard');

      if (response is DataSuccess) {
        final data = response.data!;
        return DriverStatusResponse.fromJson(data);
      }

      if (response is DataFailed) {
        return DriverStatusResponse(
          success: false,
          message: response.error?.getErrorMessage() ?? 'Failed to fetch dashboard data',
        );
      }

      return DriverStatusResponse(
        success: false,
        message: 'Unexpected error occurred',
      );
    } catch (e) {
      return DriverStatusResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
