import 'package:equatable/equatable.dart';

/// Trip location model for pickup and drop-off points
class TripLocation extends Equatable {
  const TripLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.landmark,
    this.instructions,
  });

  final double latitude;
  final double longitude;
  final String address;
  final String? landmark;
  final String? instructions;

  factory TripLocation.fromJson(Map<String, dynamic> json) {
    return TripLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      landmark: json['landmark'] as String?,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'landmark': landmark,
      'instructions': instructions,
    };
  }

  TripLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? landmark,
    String? instructions,
  }) {
    return TripLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        address,
        landmark,
        instructions,
      ];
}
