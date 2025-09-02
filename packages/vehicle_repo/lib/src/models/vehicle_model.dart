class Vehicle {
  final String id;
  final String driverId;
  final String make;
  final String model;
  final String year;
  final String color;
  final String licensePlate;
  final String? registrationImage;
  final String? insuranceImage;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.driverId,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    this.registrationImage,
    this.insuranceImage,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      driverId: json['driverId'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      licensePlate: json['licensePlate'],
      registrationImage: json['registrationImage'],
      insuranceImage: json['insuranceImage'],
      isVerified: json['isVerified'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}