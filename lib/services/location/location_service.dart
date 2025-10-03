import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver/services/core/service_interface.dart';

/// {@template location_service_interface}
/// Interface for location tracking and GPS operations.
/// {@endtemplate}
abstract class LocationServiceInterface extends ServiceInterface {
  /// {@macro location_service_interface}
  const LocationServiceInterface();

  /// Get current location
  Future<ServiceResult<LatLng>> getCurrentLocation();

  /// Start location tracking
  Future<ServiceResult<void>> startTracking();

  /// Stop location tracking
  Future<ServiceResult<void>> stopTracking();

  /// Check location permissions
  Future<ServiceResult<LocationPermission>> checkPermissions();

  /// Request location permissions
  Future<ServiceResult<LocationPermission>> requestPermissions();

  /// Stream of location updates
  Stream<LatLng> get locationStream;

  /// Stream of permission updates
  Stream<LocationPermission> get permissionStream;

  /// Current location
  LatLng? get currentLocation;

  /// Whether tracking is active
  bool get isTracking;
}

/// {@template map_service_interface}
/// Interface for map-related operations.
/// {@endtemplate}
abstract class MapServiceInterface extends ServiceInterface {
  /// {@macro map_service_interface}
  const MapServiceInterface();

  /// Generate API URL for place autocomplete
  String generateApiUrl(String userInput);

  /// Generate API URL for specific region
  String generateRegionalApiUrl(String userInput, String region);

  /// Send request to Google Places API
  Future<ServiceResult<PlacesResponse?>> sendRequestToAPI(String apiUrl);

  /// Get directions between two points
  Future<ServiceResult<List<LatLng>>> getDirections(
    LatLng origin,
    LatLng destination,
  );

  /// Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2);

  /// Get address from coordinates
  Future<ServiceResult<String>> getAddressFromCoordinates(LatLng coordinates);

  /// Get coordinates from address
  Future<ServiceResult<LatLng>> getCoordinatesFromAddress(String address);
}

/// {@template geocoding_service_interface}
/// Interface for geocoding operations.
/// {@endtemplate}
abstract class GeocodingServiceInterface extends ServiceInterface {
  /// {@macro geocoding_service_interface}
  const GeocodingServiceInterface();

  /// Convert coordinates to address
  Future<ServiceResult<List<Placemark>>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  );

  /// Convert address to coordinates
  Future<ServiceResult<List<Location>>> locationFromAddress(String address);

  /// Get place details from place ID
  Future<ServiceResult<PlaceDetails>> getPlaceDetails(String placeId);

  /// Search for places by query
  Future<ServiceResult<List<Place>>> searchPlaces(String query);
}

/// {@template location_service_module}
/// Main location service module that coordinates all location operations.
/// {@endtemplate}
class LocationServiceModule {
  /// {@macro location_service_module}
  const LocationServiceModule({
    required this.locationService,
    required this.mapService,
    required this.geocodingService,
  });

  final LocationServiceInterface locationService;
  final MapServiceInterface mapService;
  final GeocodingServiceInterface geocodingService;

  /// Initialize all location services
  Future<void> initialize() async {
    await locationService.initialize();
    await mapService.initialize();
    await geocodingService.initialize();
  }

  /// Dispose all location services
  Future<void> dispose() async {
    await locationService.dispose();
    await mapService.dispose();
    await geocodingService.dispose();
  }

  /// Get service health status
  Map<String, bool> get healthStatus => {
    'location': locationService.isInitialized,
    'map': mapService.isInitialized,
    'geocoding': geocodingService.isInitialized,
  };

  /// Get comprehensive location info
  Future<ServiceResult<LocationInfo>> getLocationInfo() async {
    try {
      final locationResult = await locationService.getCurrentLocation();
      if (locationResult.isFailure) {
        return ServiceResult.failure(locationResult.error!);
      }

      final coordinates = locationResult.data!;
      final addressResult = await mapService.getAddressFromCoordinates(coordinates);
      
      return ServiceResult.success(LocationInfo(
        coordinates: coordinates,
        address: addressResult.data,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      return ServiceResult.failure(LocationServiceError(
        message: 'Failed to get location info: $e',
      ));
    }
  }
}

/// {@template location_info}
/// Comprehensive location information.
/// {@endtemplate}
class LocationInfo {
  /// {@macro location_info}
  const LocationInfo({
    required this.coordinates,
    this.address,
    required this.timestamp,
  });

  final LatLng coordinates;
  final String? address;
  final DateTime timestamp;
}

/// {@template location_service_error}
/// Error specific to location services.
/// {@endtemplate}
class LocationServiceError extends ServiceError {
  /// {@macro location_service_error}
  const LocationServiceError({
    required super.message,
    super.code,
    super.details,
  });
}

// Re-export types from other files for convenience
export 'location_service.dart';
export 'google_map_services.dart';
