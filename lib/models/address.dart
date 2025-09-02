import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address {
  Address({
    required this.polylines,
    this.latLng,
    this.street,
    this.city,
    this.state,
    this.country,
    this.postcode,
  });
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postcode;
  final LatLng? latLng;
  List<PointLatLng> polylines = [];

  Address copyWith({
    String? street,
    String? city,
    String? state,
    String? country,
    String? postcode,
    LatLng? latLng,
    List<PointLatLng>? polylines,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postcode: postcode ?? this.postcode,
      latLng: latLng ?? this.latLng,
      polylines: polylines ?? this.polylines,
    );
  }
}
