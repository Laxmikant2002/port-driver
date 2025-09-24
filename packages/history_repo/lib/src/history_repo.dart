import 'dart:convert';
import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'models/ride.dart';
import 'models/ride_response.dart';

/// History repository for managing driver ride history
class HistoryRepo {
  const HistoryRepo({
    required this.baseUrl,
    required this.apiClient,
    required this.localStorage,
  });

  final String baseUrl;
  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Get ride history for a specific driver
  Future<RideResponse> getRideHistory({
    required String driverId,
    int? limit,
    int? offset,
    RideStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'driverId': driverId,
      };
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (status != null) queryParams['status'] = status.value;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await apiClient.get<Map<String, dynamic>>(
        '/driver/trips/history',
        queryParameters: queryParams,
      );

      if (response is DataSuccess) {
        return RideResponse.fromJson(response.data!);
      } else {
        return RideResponse(
          success: false,
          message: 'Failed to fetch ride history',
        );
      }
    } catch (e) {
      return RideResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get ride statistics for a specific driver
  Future<RideResponse> getRideStatistics({
    required String driverId,
    DateTime? startDate,
    DateTime? endDate,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'driverId': driverId,
      };
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (period != null) queryParams['period'] = period;

      final response = await apiClient.get<Map<String, dynamic>>(
        '/driver/trips/statistics',
        queryParameters: queryParams,
      );

      if (response is DataSuccess) {
        return RideResponse.fromJson(response.data!);
      } else {
        return RideResponse(
          success: false,
          message: 'Failed to fetch ride statistics',
        );
      }
    } catch (e) {
      return RideResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get a specific ride by ID for a driver
  Future<RideResponse> getRide({
    required String driverId,
    required String rideId,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/driver/trips/$rideId',
        queryParameters: {'driverId': driverId},
      );

      if (response is DataSuccess) {
        return RideResponse.fromJson(response.data!);
      } else {
        return RideResponse(
          success: false,
          message: 'Failed to fetch ride details',
        );
      }
    } catch (e) {
      return RideResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get recent rides for a specific driver
  Future<RideResponse> getRecentRides({
    required String driverId,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/driver/trips/recent',
        queryParameters: {
          'driverId': driverId,
          'limit': limit,
        },
      );

      if (response is DataSuccess) {
        return RideResponse.fromJson(response.data!);
      } else {
        return RideResponse(
          success: false,
          message: 'Failed to fetch recent rides',
        );
      }
    } catch (e) {
      return RideResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get cached ride history
  Future<List<Ride>> getCachedRideHistory() async {
    try {
      final cached = await localStorage.getItem('cached_ride_history');
      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        return jsonList.map((json) => Ride.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Cache ride history
  Future<void> cacheRideHistory(List<Ride> rides) async {
    try {
      final jsonList = rides.map((r) => r.toJson()).toList();
      await localStorage.setItem('cached_ride_history', jsonEncode(jsonList));
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get cached ride statistics
  Future<RideStatistics?> getCachedRideStatistics() async {
    try {
      final cached = await localStorage.getItem('cached_ride_statistics');
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return RideStatistics.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache ride statistics
  Future<void> cacheRideStatistics(RideStatistics statistics) async {
    try {
      await localStorage.setItem('cached_ride_statistics', jsonEncode(statistics.toJson()));
    } catch (e) {
      // Handle error silently
    }
  }

}