class DriverProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final String? licenseNumber;
  final String? licenseImage;
  final String? vehicleId;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  DriverProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    this.licenseNumber,
    this.licenseImage,
    this.vehicleId,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profileImage'],
      licenseNumber: json['licenseNumber'],
      licenseImage: json['licenseImage'],
      vehicleId: json['vehicleId'],
      isVerified: json['isVerified'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}