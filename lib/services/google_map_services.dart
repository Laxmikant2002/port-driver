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
  String generateApiUrl(String userInput) {
    return 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$userInput&key=${GoogleMapKey.googleMapApiKey}&components=country:IN&location=11.7401,92.6586&radius=450000&&strictbounds=true';
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
}
