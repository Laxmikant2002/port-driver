import 'package:driver/services/google_map_services.dart'; // Ensure this import is correct
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_repo/location_repo.dart';

class LocationService {
  final Geolocator _geolocator;
  final GoogleMapServices _googleMapService;

  LocationService(this._googleMapService) : _geolocator = Geolocator();

  Future<bool> requestPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final request = await Geolocator.requestPermission();
      return request == LocationPermission.always ||
          request == LocationPermission.whileInUse;
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Stream<Location> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10, // meters
      ),
    ).map((position) => Location(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          speed: position.speed,
          heading: position.heading,
          timestamp: DateTime.now(),
        ));
  }

  Future<Location> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
    final address = await _googleMapService.getAddressFromCoodinate(
      LatLng(position.latitude, position.longitude),
    );
    return Location(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
      timestamp: DateTime.now(),
      address: address.toString(),
    );
  }
}
