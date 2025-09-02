import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_repo/location_repo.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../models/address.dart';

class NavigationService {
  final GoogleMapController _controller;

  NavigationService(this._controller);

  Future<void> startNavigation(Address destination) async {
    if (destination.latLng != null) {
      await _controller.animateCamera(
        CameraUpdate.newLatLngZoom(destination.latLng!, 15),
      );
    } else {
      // Handle the case where latLng is null, e.g., show an error or use a default location
      throw Exception('Destination LatLng is null');
    }
  }

  Future<void> updateRoute(Address currentLocation, Address destination) async {
    // Implement route updates
  }

  Future<void> addWaypoint(Address waypoint) async {
    // Implement waypoint addition
  }

  Future<void> clearRoute() async {
    // Implement route clearing
  }
}