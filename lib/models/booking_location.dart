import 'dart:math' show sin, cos, sqrt, atan2;

import 'package:equatable/equatable.dart';

/// Represents a geographic location with coordinates and address information.
/// 
/// This model ensures type safety for latitude/longitude values and provides
/// consistent location handling throughout the booking flow.
class BookingLocation extends Equatable {
  /// The latitude coordinate (required, must be valid)
  final double latitude;
  
  /// The longitude coordinate (required, must be valid)
  final double longitude;
  
  /// Human-readable address string
  final String address;
  
  /// Optional additional location details
  final String? landmark;
  
  /// Optional location notes (e.g., "Near the red building")
  final String? notes;

  const BookingLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.landmark,
    this.notes,
  }) : assert(latitude >= -90 && latitude <= 90, 'Invalid latitude'),
       assert(longitude >= -180 && longitude <= 180, 'Invalid longitude');

  /// Creates a BookingLocation from a JSON map
  factory BookingLocation.fromJson(Map<String, dynamic> json) {
    return BookingLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      landmark: json['landmark'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// Converts the BookingLocation to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      if (landmark != null) 'landmark': landmark,
      if (notes != null) 'notes': notes,
    };
  }

  /// Creates a copy with updated values
  BookingLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? landmark,
    String? notes,
  }) {
    return BookingLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      notes: notes ?? this.notes,
    );
  }

  /// Calculates distance to another location in kilometers
  double distanceTo(BookingLocation other) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double lat1Rad = latitude * (3.14159265359 / 180);
    final double lat2Rad = other.latitude * (3.14159265359 / 180);
    final double deltaLatRad = (other.latitude - latitude) * (3.14159265359 / 180);
    final double deltaLngRad = (other.longitude - longitude) * (3.14159265359 / 180);

    final double a = (sin(deltaLatRad / 2) * sin(deltaLatRad / 2)) +
        (cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Returns a formatted string representation
  String get displayAddress {
    final parts = <String>[address];
    if (landmark != null && landmark!.isNotEmpty) {
      parts.add('($landmark)');
    }
    return parts.join(' ');
  }

  @override
  List<Object?> get props => [latitude, longitude, address, landmark, notes];

  @override
  String toString() => 'BookingLocation(lat: $latitude, lng: $longitude, address: $address)';
}