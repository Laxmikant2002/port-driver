import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver/services/core/service_interface.dart';
import 'package:equatable/equatable.dart';

// Re-export types from other files for convenience
export 'google_map_services.dart';

/// Places API response model
class PlacesResponse extends Equatable {
  const PlacesResponse({
    required this.results,
    required this.status,
    this.nextPageToken,
  });

  final List<Place> results;
  final String status;
  final String? nextPageToken;

  factory PlacesResponse.fromJson(Map<String, dynamic> json) {
    return PlacesResponse(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      status: json['status'] as String? ?? '',
      nextPageToken: json['next_page_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'status': status,
      'next_page_token': nextPageToken,
    };
  }

  @override
  List<Object?> get props => [results, status, nextPageToken];
}

/// Place details model
class PlaceDetails extends Equatable {
  const PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.geometry,
    this.types,
    this.rating,
    this.priceLevel,
    this.photos,
  });

  final String placeId;
  final String name;
  final String formattedAddress;
  final PlaceGeometry geometry;
  final List<String>? types;
  final double? rating;
  final int? priceLevel;
  final List<PlacePhoto>? photos;

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      placeId: json['place_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      formattedAddress: json['formatted_address'] as String? ?? '',
      geometry: PlaceGeometry.fromJson(json['geometry'] as Map<String, dynamic>),
      types: (json['types'] as List<dynamic>?)?.cast<String>(),
      rating: (json['rating'] as num?)?.toDouble(),
      priceLevel: json['price_level'] as int?,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => PlacePhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'formatted_address': formattedAddress,
      'geometry': geometry.toJson(),
      'types': types,
      'rating': rating,
      'price_level': priceLevel,
      'photos': photos?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        placeId,
        name,
        formattedAddress,
        geometry,
        types,
        rating,
        priceLevel,
        photos,
      ];
}

/// Place model
class Place extends Equatable {
  const Place({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.geometry,
    this.types,
    this.rating,
    this.priceLevel,
    this.photos,
  });

  final String placeId;
  final String name;
  final String formattedAddress;
  final PlaceGeometry geometry;
  final List<String>? types;
  final double? rating;
  final int? priceLevel;
  final List<PlacePhoto>? photos;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['place_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      formattedAddress: json['formatted_address'] as String? ?? '',
      geometry: PlaceGeometry.fromJson(json['geometry'] as Map<String, dynamic>),
      types: (json['types'] as List<dynamic>?)?.cast<String>(),
      rating: (json['rating'] as num?)?.toDouble(),
      priceLevel: json['price_level'] as int?,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => PlacePhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'formatted_address': formattedAddress,
      'geometry': geometry.toJson(),
      'types': types,
      'rating': rating,
      'price_level': priceLevel,
      'photos': photos?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        placeId,
        name,
        formattedAddress,
        geometry,
        types,
        rating,
        priceLevel,
        photos,
      ];
}

/// Place geometry model
class PlaceGeometry extends Equatable {
  const PlaceGeometry({
    required this.location,
    this.viewport,
  });

  final PlaceLocation location;
  final PlaceViewport? viewport;

  factory PlaceGeometry.fromJson(Map<String, dynamic> json) {
    return PlaceGeometry(
      location: PlaceLocation.fromJson(json['location'] as Map<String, dynamic>),
      viewport: json['viewport'] != null
          ? PlaceViewport.fromJson(json['viewport'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'viewport': viewport?.toJson(),
    };
  }

  @override
  List<Object?> get props => [location, viewport];
}

/// Place location model
class PlaceLocation extends Equatable {
  const PlaceLocation({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  factory PlaceLocation.fromJson(Map<String, dynamic> json) {
    return PlaceLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  List<Object?> get props => [lat, lng];
}

/// Place viewport model
class PlaceViewport extends Equatable {
  const PlaceViewport({
    required this.northeast,
    required this.southwest,
  });

  final PlaceLocation northeast;
  final PlaceLocation southwest;

  factory PlaceViewport.fromJson(Map<String, dynamic> json) {
    return PlaceViewport(
      northeast: PlaceLocation.fromJson(json['northeast'] as Map<String, dynamic>),
      southwest: PlaceLocation.fromJson(json['southwest'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'northeast': northeast.toJson(),
      'southwest': southwest.toJson(),
    };
  }

  @override
  List<Object?> get props => [northeast, southwest];
}

/// Place photo model
class PlacePhoto extends Equatable {
  const PlacePhoto({
    required this.photoReference,
    required this.height,
    required this.width,
  });

  final String photoReference;
  final int height;
  final int width;

  factory PlacePhoto.fromJson(Map<String, dynamic> json) {
    return PlacePhoto(
      photoReference: json['photo_reference'] as String? ?? '',
      height: json['height'] as int? ?? 0,
      width: json['width'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo_reference': photoReference,
      'height': height,
      'width': width,
    };
  }

  @override
  List<Object?> get props => [photoReference, height, width];
}

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

/// {@template location_service}
/// Concrete implementation of LocationServiceInterface.
/// {@endtemplate}
class LocationService implements LocationServiceInterface {
  /// {@macro location_service}
  LocationService();

  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  String get serviceName => 'LocationService';

  @override
  Future<void> initialize() async {
    // Initialize location services
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    // Dispose location services
    _isInitialized = false;
  }

  @override
  Future<ServiceResult<LatLng>> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      return ServiceResult.success(LatLng(position.latitude, position.longitude));
    } catch (e) {
      return ServiceResult.failure(LocationServiceError(message: e.toString()));
    }
  }

  @override
  Future<ServiceResult<void>> startTracking() async {
    try {
      // Start location tracking
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure(LocationServiceError(message: e.toString()));
    }
  }

  @override
  Future<ServiceResult<void>> stopTracking() async {
    try {
      // Stop location tracking
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.failure(LocationServiceError(message: e.toString()));
    }
  }

  @override
  Future<ServiceResult<LocationPermission>> checkPermissions() async {
    try {
      final permission = await Geolocator.checkPermission();
      return ServiceResult.success(permission);
    } catch (e) {
      return ServiceResult.failure(LocationServiceError(message: e.toString()));
    }
  }

  @override
  Future<ServiceResult<LocationPermission>> requestPermissions() async {
    try {
      final permission = await Geolocator.requestPermission();
      return ServiceResult.success(permission);
    } catch (e) {
      return ServiceResult.failure(LocationServiceError(message: e.toString()));
    }
  }

  @override
  Stream<LatLng> get locationStream => Stream.empty();

  @override
  Stream<LocationPermission> get permissionStream => Stream.empty();

  @override
  LatLng? get currentLocation => null;

  @override
  bool get isTracking => false;
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
