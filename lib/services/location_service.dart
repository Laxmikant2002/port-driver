import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service for managing location tracking and GPS functionality
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final StreamController<LatLng> _locationController = StreamController<LatLng>.broadcast();
  final StreamController<LocationPermission> _permissionController = StreamController<LocationPermission>.broadcast();
  
  Stream<LatLng> get locationStream => _locationController.stream;
  Stream<LocationPermission> get permissionStream => _permissionController.stream;
  
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionSubscription;
  bool _isTracking = false;
  
  LatLng? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;

  /// Initialize location service and request permissions
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return false;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          _permissionController.add(permission);
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        _permissionController.add(permission);
        return false;
      }

      _permissionController.add(permission);
      
      // Get initial location
      await _getCurrentLocation();
      return true;
    } catch (e) {
      debugPrint('Error initializing location service: $e');
      return false;
    }
  }

  /// Get current location once
  Future<LatLng?> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      );
      
      _currentLocation = LatLng(position.latitude, position.longitude);
      _locationController.add(_currentLocation!);
      return _currentLocation;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Start continuous location tracking
  Future<bool> startTracking() async {
    if (_isTracking) return true;
    
    try {
      // Check permissions again
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse && 
          permission != LocationPermission.always) {
        debugPrint('Location permission not granted for tracking');
        return false;
      }

      _isTracking = true;
      
      // Start listening to position updates
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Update every 5 meters for better tracking
        ),
      ).listen(
        (Position position) {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationController.add(_currentLocation!);
          debugPrint('Location updated: ${position.latitude}, ${position.longitude}');
        },
        onError: (error) {
          debugPrint('Location tracking error: $error');
          _isTracking = false;
        },
      );

      debugPrint('Location tracking started');
      return true;
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      _isTracking = false;
      return false;
    }
  }

  /// Stop location tracking
  Future<void> stopTracking() async {
    if (!_isTracking) return;
    
    try {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      _isTracking = false;
      debugPrint('Location tracking stopped');
    } catch (e) {
      debugPrint('Error stopping location tracking: $e');
    }
  }

  /// Calculate distance between two points in meters
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Check if location is within Maharashtra state boundaries
  bool isWithinMaharashtra(LatLng location) {
    // Maharashtra approximate boundaries
    const double minLat = 15.6; // Southern boundary
    const double maxLat = 22.0; // Northern boundary
    const double minLng = 72.6; // Western boundary
    const double maxLng = 80.9; // Eastern boundary
    
    return location.latitude >= minLat &&
           location.latitude <= maxLat &&
           location.longitude >= minLng &&
           location.longitude <= maxLng;
  }

  /// Get formatted address from coordinates
  Future<String> getAddressFromCoordinates(LatLng location) async {
    try {
      final placemarks = await Geolocator.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';
      }
      return 'Unknown location';
    } catch (e) {
      debugPrint('Error getting address: $e');
      return 'Unknown location';
    }
  }

  /// Check if driver is near pickup/drop location (within 100 meters)
  bool isNearLocation(LatLng driverLocation, LatLng targetLocation, {double thresholdMeters = 100}) {
    final distance = calculateDistance(driverLocation, targetLocation);
    return distance <= thresholdMeters;
  }

  /// Dispose resources
  void dispose() {
    _positionSubscription?.cancel();
    _locationController.close();
    _permissionController.close();
  }
}