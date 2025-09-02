library location_repo;

// Export your location repository implementation here

class Location {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? bearing;
  final double? speed;
  final double? heading;
  final String? address;
  final DateTime timestamp;

  Location({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.bearing,
    this.speed,
    this.heading,
    this.address,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class LocationRepo {
  // Add your location repository methods and properties here
}
