import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:driver/constants/google_map_key.dart';
import 'package:driver/models/address.dart';
import 'package:driver/models/place_id_response.dart';
import 'package:driver/models/prediction_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GoogleMapServices {
  // Maharashtra center coordinates for better autocomplete results
  static const double _maharashtraCenterLat = 19.7515;
  static const double _maharashtraCenterLng = 75.7139;
  static const double _maharashtraRadius = 500000; // 500km radius

  String generateApiUrl(String userInput) {
    return 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$userInput&key=${GoogleMapKey.googleMapApiKey}&components=country:IN&location=$_maharashtraCenterLat,$_maharashtraCenterLng&radius=$_maharashtraRadius&strictbounds=true';
  }

  /// Generate API URL specifically for Maharashtra cities
  String generateMaharashtraApiUrl(String userInput) {
    return 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$userInput&key=${GoogleMapKey.googleMapApiKey}&components=country:IN|administrative_area_level_1:Maharashtra&location=$_maharashtraCenterLat,$_maharashtraCenterLng&radius=$_maharashtraRadius';
  }

  Future<PlacesResponse?> sendRequestToAPI(String apiUrl) async {
    final response = await http.get(Uri.parse(apiUrl));

    try {
      if (response.statusCode == 200) {
        final data = response.body;
        // var dataDecoded = jsonDecode(data);
        final placesRes = placesResponseFromJson(data);

        return placesRes;
      } else {
        return null;
      }
    } catch (e) {
      print('\n\nError Occurred::\n$e\n\n');
      return null;
    }
  }

  Future<bool> requestAndCheckPermission() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final request = await Geolocator.requestPermission();
      if (request == LocationPermission.always ||
          request == LocationPermission.whileInUse) {
        return true;
      } else {
        return false;
      }
    } else if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<Address> getAddressFromCoodinate(
    LatLng position, {
    List<PointLatLng>? polylines,
  }) async {
    final placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    final placemark = placemarks.first;
    final address = Address(
      street: placemark.street,
      city: placemark.locality,
      state: placemark.administrativeArea,
      country: placemark.country,
      latLng: position,
      polylines: polylines ?? [],
    );
    return address;
  }

  Future<Address?> getCurrentPosition() async {
    final check = await requestAndCheckPermission();

    if (check) {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      final address = await getAddressFromCoodinate(
        LatLng(position.latitude, position.longitude),
      );

      return address;
    } else {
      return null;
    }
  }

  String generateCode(String prefix) {
    final random = Random();
    final id = random.nextInt(92143543) + 09451234356;
    return '$prefix-${id.toString().substring(0, 8)}';
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<LatLng?> getDetailsfromPlaceId(
    String placeId,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${GoogleMapKey.googleMapApiKey}&fields=geometry';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      try {
        final response = placeIdResponseFromJson(res.body);
        return LatLng(
          response.result.geometry.location.lat,
          response.result.geometry.location.lng,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<List<LatLng>> getPolylineCoordinates(LatLng? src, LatLng? dst) async {
    final polylineCoordinates = <LatLng>[];
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: GoogleMapKey.googleMapApiKey,
      request: PolylineRequest(
        origin: PointLatLng(src!.latitude, src.longitude,),
        destination: PointLatLng(dst!.latitude, dst.longitude),
        mode: TravelMode.driving,
        avoidFerries: true,
      ),
    );

    if (result.status != 'OK') {
      print('Error occurred: ${result.errorMessage}');
      // Add additional debugging information here if needed
    }

    if (result.points.isNotEmpty) {
      for (final point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      print('Distance: ${result.distanceTexts} ${result.distanceValues}');
      print('Duration: ${result.durationTexts} ${result.durationValues}');
    } else {
      print(
        'Error occured at getPolylineCoordinates(): ${result.errorMessage}',
      );
    }
    return polylineCoordinates;
  }

  Map<PolylineId, Polyline> addPolyLine(List<LatLng> polylineCoordinates) {
    final polylines = <PolylineId, Polyline>{};
    const id = PolylineId('poly');
    final polyline = Polyline(
        polylineId: id, points: polylineCoordinates,);
    polylines[id] = polyline;
    return polylines;
  }

  /// Create route with multiple polylines (for multi-stop deliveries)
  Map<PolylineId, Polyline> createMultiStopRoute(List<List<LatLng>> routeSegments) {
    final polylines = <PolylineId, Polyline>{};
    
    for (int i = 0; i < routeSegments.length; i++) {
      final id = PolylineId('route_$i');
      final polyline = Polyline(
        polylineId: id,
        points: routeSegments[i],
        color: _getRouteColor(i),
        width: 4,
        patterns: i == 0 ? [] : [PatternItem.dash(10), PatternItem.gap(5)], // Dashed for subsequent routes
      );
      polylines[id] = polyline;
    }
    
    return polylines;
  }

  /// Get different colors for different route segments
  Color _getRouteColor(int segmentIndex) {
    const colors = [
      Color(0xFF4285F4), // Blue for first route
      Color(0xFF34A853), // Green for second route
      Color(0xFFFBBC04), // Yellow for third route
      Color(0xFFEA4335), // Red for fourth route
    ];
    return colors[segmentIndex % colors.length];
  }

  /// Create custom markers for different locations
  Map<MarkerId, Marker> createLocationMarkers({
    required LatLng driverLocation,
    LatLng? pickupLocation,
    LatLng? dropoffLocation,
    List<LatLng>? additionalStops,
  }) {
    final markers = <MarkerId, Marker>{};
    
    // Driver marker
    markers[const MarkerId('driver')] = Marker(
      markerId: const MarkerId('driver'),
      position: driverLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'Your Location'),
    );
    
    // Pickup marker
    if (pickupLocation != null) {
      markers[const MarkerId('pickup')] = Marker(
        markerId: const MarkerId('pickup'),
        position: pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      );
    }
    
    // Dropoff marker
    if (dropoffLocation != null) {
      markers[const MarkerId('dropoff')] = Marker(
        markerId: const MarkerId('dropoff'),
        position: dropoffLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Dropoff Location'),
      );
    }
    
    // Additional stops markers
    if (additionalStops != null) {
      for (int i = 0; i < additionalStops.length; i++) {
        markers[MarkerId('stop_$i')] = Marker(
          markerId: MarkerId('stop_$i'),
          position: additionalStops[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
        );
      }
    }
    
    return markers;
  }

  /// Calculate route distance and duration
  Future<RouteInfo?> getRouteInfo(LatLng origin, LatLng destination) async {
    try {
      final polylinePoints = PolylinePoints();
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: GoogleMapKey.googleMapApiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
          avoidFerries: true,
        ),
      );

      if (result.status == 'OK' && result.points.isNotEmpty) {
        return RouteInfo(
          distance: result.distanceValues.first,
          duration: result.durationValues.first,
          polylinePoints: result.points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
        );
      }
      return null;
    } catch (e) {
      print('Error getting route info: $e');
      return null;
    }
  }

  /// Check if location is within Maharashtra boundaries
  bool isWithinMaharashtra(LatLng location) {
    // Maharashtra approximate boundaries
    const double minLat = 15.6;
    const double maxLat = 22.0;
    const double minLng = 72.6;
    const double maxLng = 80.9;
    
    return location.latitude >= minLat &&
           location.latitude <= maxLat &&
           location.longitude >= minLng &&
           location.longitude <= maxLng;
  }

  /// Get camera position to fit all markers
  CameraPosition getCameraPositionForMarkers(List<LatLng> locations) {
    if (locations.isEmpty) {
      return const CameraPosition(
        target: LatLng(_maharashtraCenterLat, _maharashtraCenterLng),
        zoom: 10,
      );
    }
    
    if (locations.length == 1) {
      return CameraPosition(
        target: locations.first,
        zoom: 15,
      );
    }
    
    // Calculate bounds
    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;
    
    for (final location in locations) {
      minLat = minLat < location.latitude ? minLat : location.latitude;
      maxLat = maxLat > location.latitude ? maxLat : location.latitude;
      minLng = minLng < location.longitude ? minLng : location.longitude;
      maxLng = maxLng > location.longitude ? maxLng : location.longitude;
    }
    
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    
    // Calculate zoom level based on bounds
    double zoom = 10;
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    
    if (maxDiff < 0.01) zoom = 15;
    else if (maxDiff < 0.05) zoom = 12;
    else if (maxDiff < 0.1) zoom = 10;
    else zoom = 8;
    
    return CameraPosition(
      target: LatLng(centerLat, centerLng),
      zoom: zoom,
    );
  }
}

/// Route information model
class RouteInfo {
  final double distance; // in meters
  final int duration; // in seconds
  final List<LatLng> polylinePoints;

  RouteInfo({
    required this.distance,
    required this.duration,
    required this.polylinePoints,
  });

  String get distanceText {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  String get durationText {
    if (duration < 60) {
      return '${duration}s';
    } else if (duration < 3600) {
      return '${(duration / 60).toStringAsFixed(0)} min';
    } else {
      final hours = (duration / 3600).floor();
      final minutes = ((duration % 3600) / 60).floor();
      return '${hours}h ${minutes}m';
    }
  }
}
