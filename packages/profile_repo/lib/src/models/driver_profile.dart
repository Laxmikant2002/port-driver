import 'package:equatable/equatable.dart';

/// Driver profile model containing all driver information
class DriverProfile extends Equatable {
  const DriverProfile({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    this.profilePicture,
    this.dateOfBirth,
    this.gender,
    this.preferredLocation,
    this.serviceArea,
    this.languagesSpoken = const [],
    this.isVerified = false,
    this.isActive = false,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.vehicleInfo,
    this.workLocation,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String phoneNumber;
  final String fullName;
  final String? profilePicture;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? preferredLocation;
  final String? serviceArea;
  final List<String> languagesSpoken;
  final bool isVerified;
  final bool isActive;
  final double rating;
  final int totalTrips;
  final VehicleInfo? vehicleInfo;
  final WorkLocation? workLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      fullName: json['fullName'] as String,
      profilePicture: json['profilePicture'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String) 
          : null,
      gender: json['gender'] as String?,
      preferredLocation: json['preferredLocation'] as String?,
      serviceArea: json['serviceArea'] as String?,
      languagesSpoken: (json['languagesSpoken'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: json['totalTrips'] as int? ?? 0,
      vehicleInfo: json['vehicleInfo'] != null 
          ? VehicleInfo.fromJson(json['vehicleInfo'] as Map<String, dynamic>) 
          : null,
      workLocation: json['workLocation'] != null 
          ? WorkLocation.fromJson(json['workLocation'] as Map<String, dynamic>) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'preferredLocation': preferredLocation,
      'serviceArea': serviceArea,
      'languagesSpoken': languagesSpoken,
      'isVerified': isVerified,
      'isActive': isActive,
      'rating': rating,
      'totalTrips': totalTrips,
      'vehicleInfo': vehicleInfo?.toJson(),
      'workLocation': workLocation?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  DriverProfile copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    String? profilePicture,
    DateTime? dateOfBirth,
    String? gender,
    String? preferredLocation,
    String? serviceArea,
    List<String>? languagesSpoken,
    bool? isVerified,
    bool? isActive,
    double? rating,
    int? totalTrips,
    VehicleInfo? vehicleInfo,
    WorkLocation? workLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverProfile(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      serviceArea: serviceArea ?? this.serviceArea,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      workLocation: workLocation ?? this.workLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        fullName,
        profilePicture,
        dateOfBirth,
        gender,
        preferredLocation,
        serviceArea,
        languagesSpoken,
        isVerified,
        isActive,
        rating,
        totalTrips,
        vehicleInfo,
        workLocation,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'DriverProfile('
        'id: $id, '
        'phoneNumber: $phoneNumber, '
        'fullName: $fullName, '
        'profilePicture: $profilePicture, '
        'dateOfBirth: $dateOfBirth, '
        'gender: $gender, '
        'preferredLocation: $preferredLocation, '
        'serviceArea: $serviceArea, '
        'languagesSpoken: $languagesSpoken, '
        'isVerified: $isVerified, '
        'isActive: $isActive, '
        'rating: $rating, '
        'totalTrips: $totalTrips, '
        'vehicleInfo: $vehicleInfo, '
        'workLocation: $workLocation, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}

/// Vehicle information model
class VehicleInfo extends Equatable {
  const VehicleInfo({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    this.brand,
    this.model,
    this.year,
    this.color,
    this.isAvailable = true,
    this.driverId,
  });

  final String id;
  final String vehicleNumber;
  final String vehicleType;
  final String? brand;
  final String? model;
  final int? year;
  final String? color;
  final bool isAvailable;
  final String? driverId;

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      id: json['id'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      vehicleType: json['vehicleType'] as String,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      color: json['color'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      driverId: json['driverId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'isAvailable': isAvailable,
      'driverId': driverId,
    };
  }

  VehicleInfo copyWith({
    String? id,
    String? vehicleNumber,
    String? vehicleType,
    String? brand,
    String? model,
    int? year,
    String? color,
    bool? isAvailable,
    String? driverId,
  }) {
    return VehicleInfo(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      isAvailable: isAvailable ?? this.isAvailable,
      driverId: driverId ?? this.driverId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vehicleNumber,
        vehicleType,
        brand,
        model,
        year,
        color,
        isAvailable,
        driverId,
      ];

  @override
  String toString() {
    return 'VehicleInfo('
        'id: $id, '
        'vehicleNumber: $vehicleNumber, '
        'vehicleType: $vehicleType, '
        'brand: $brand, '
        'model: $model, '
        'year: $year, '
        'color: $color, '
        'isAvailable: $isAvailable, '
        'driverId: $driverId'
        ')';
  }
}

/// Work location model for driver's preferred work area
class WorkLocation extends Equatable {
  const WorkLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.radius = 10.0, // Default radius in kilometers
  });

  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double radius;

  factory WorkLocation.fromJson(Map<String, dynamic> json) {
    return WorkLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      radius: (json['radius'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'radius': radius,
    };
  }

  WorkLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? radius,
  }) {
    return WorkLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      radius: radius ?? this.radius,
    );
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        address,
        city,
        state,
        country,
        postalCode,
        radius,
      ];

  @override
  String toString() {
    return 'WorkLocation('
        'latitude: $latitude, '
        'longitude: $longitude, '
        'address: $address, '
        'city: $city, '
        'state: $state, '
        'country: $country, '
        'postalCode: $postalCode, '
        'radius: $radius'
        ')';
  }
}
