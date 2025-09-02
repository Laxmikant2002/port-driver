import 'package:google_maps_flutter/google_maps_flutter.dart';

enum InfoWindowType { position, destination }

class CityCabInfoWindow {
  const CityCabInfoWindow({
    required this.type,
    this.name,
    this.time,
    this.position,
  });
  final String? name;
  final Duration? time;
  final LatLng? position;
  final InfoWindowType type;
}
