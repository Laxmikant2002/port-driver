import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:profile_repo/src/models/driver_profile.dart';

/// Profile update data model for driver profile updates
class ProfileUpdateData {
  final String fullName;
  final String? profilePicture;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? preferredLocation;
  final String? serviceArea;
  final List<String> languagesSpoken;

  const ProfileUpdateData({
    required this.fullName,
    this.profilePicture,
    this.dateOfBirth,
    this.gender,
    this.preferredLocation,
    this.serviceArea,
    this.languagesSpoken = const [],
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'profilePicture': profilePicture,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'preferredLocation': preferredLocation,
        'serviceArea': serviceArea,
        'languagesSpoken': languagesSpoken,
      };

  factory ProfileUpdateData.fromJson(Map<String, dynamic> json) => ProfileUpdateData(
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
      );
}

/// API response model
class ProfileResponse {
  final bool success;
  final String? message;
  final DriverProfile? data;

  const ProfileResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) => ProfileResponse(
        success: json['success'] as bool,
        message: json['message'] as String?,
        data: json['data'] != null ? DriverProfile.fromJson(json['data'] as Map<String, dynamic>) : null,
      );
}

/// Driver status enum for route decision making
enum DriverStatus {
  newUser,           // Completely new user - needs profile creation
  profileIncomplete, // Profile exists but incomplete - needs profile completion
  documentsPending,  // Profile complete but documents not uploaded/verified
  documentsRejected, // Documents uploaded but rejected - needs resubmission
  verified,          // Fully verified and ready to work
  suspended,         // Account suspended
  inactive,          // Account inactive
}

/// Driver status response model
class DriverStatusResponse {
  final bool success;
  final String? message;
  final DriverStatus status;
  final DriverProfile? profile;
  final List<String> missingRequirements;

  const DriverStatusResponse({
    required this.success,
    this.message,
    required this.status,
    this.profile,
    this.missingRequirements = const [],
  });

  factory DriverStatusResponse.fromJson(Map<String, dynamic> json) {
    return DriverStatusResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      status: _parseDriverStatus(json['status'] as String),
      profile: json['profile'] != null 
          ? DriverProfile.fromJson(json['profile'] as Map<String, dynamic>) 
          : null,
      missingRequirements: (json['missingRequirements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }

  static DriverStatus _parseDriverStatus(String status) {
    switch (status.toLowerCase()) {
      case 'new_user':
        return DriverStatus.newUser;
      case 'profile_incomplete':
        return DriverStatus.profileIncomplete;
      case 'documents_pending':
        return DriverStatus.documentsPending;
      case 'documents_rejected':
        return DriverStatus.documentsRejected;
      case 'verified':
        return DriverStatus.verified;
      case 'suspended':
        return DriverStatus.suspended;
      case 'inactive':
        return DriverStatus.inactive;
      default:
        return DriverStatus.newUser;
    }
  }
}

/// Profile repository for handling profile-related API calls
class ProfileRepo {
  const ProfileRepo({
    required this.baseUrl,
    required this.client,
  });

  final String baseUrl;
  final http.Client client;

  /// Check driver status for route decision making
  Future<DriverStatusResponse> checkDriverStatus(String phoneNumber) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/driver/status/$phoneNumber'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return DriverStatusResponse.fromJson(json);
      } else {
        return DriverStatusResponse(
          success: false,
          message: 'Failed to check driver status',
          status: DriverStatus.newUser,
        );
      }
    } catch (e) {
      return DriverStatusResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        status: DriverStatus.newUser,
      );
    }
  }

  /// Get driver profile data
  Future<ProfileResponse> getDriverProfile(String driverId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/driver/profile/$driverId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileResponse.fromJson(json);
      } else {
        return ProfileResponse(
          success: false,
          message: 'Failed to fetch driver profile data',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update driver profile data
  Future<ProfileResponse> updateDriverProfile(String driverId, ProfileUpdateData profileData) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/driver/profile/$driverId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profileData.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileResponse.fromJson(json);
      } else {
        return ProfileResponse(
          success: false,
          message: 'Failed to update driver profile data',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Create new driver profile during onboarding
  Future<ProfileResponse> createDriverProfile(String phoneNumber, ProfileUpdateData profileData) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/driver/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          ...profileData.toJson(),
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileResponse.fromJson(json);
      } else {
        return ProfileResponse(
          success: false,
          message: 'Failed to create driver profile',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Upload profile image
  Future<ProfileResponse> uploadProfileImage(String driverId, String imagePath) async {
    try {
      // TODO: Implement image upload logic
      // This would typically involve creating a multipart request
      // and uploading the image file to a storage service
      
      // For now, return a mock response
      await Future.delayed(const Duration(seconds: 2));
      
      return ProfileResponse(
        success: true,
        message: 'Profile image uploaded successfully',
      );
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Failed to upload profile image: ${e.toString()}',
      );
    }
  }

  /// Delete profile image
  Future<ProfileResponse> deleteProfileImage(String driverId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/driver/profile/$driverId/image'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileResponse.fromJson(json);
      } else {
        return ProfileResponse(
          success: false,
          message: 'Failed to delete profile image',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get available vehicles for driver assignment
  Future<List<VehicleInfo>> getAvailableVehicles() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/driver/vehicles/available'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final vehicles = (json['vehicles'] as List<dynamic>)
            .map((e) => VehicleInfo.fromJson(e as Map<String, dynamic>))
            .toList();
        return vehicles;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Assign vehicle to driver
  Future<ProfileResponse> assignVehicle(String driverId, String vehicleId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/driver/$driverId/vehicle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'vehicleId': vehicleId}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileResponse.fromJson(json);
      } else {
        return ProfileResponse(
          success: false,
          message: 'Failed to assign vehicle',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Set work location for driver
  Future<ProfileResponse> setWorkLocation(String driverId, WorkLocation location) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/driver/$driverId/location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(location.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileResponse.fromJson(json);
      } else {
        return ProfileResponse(
          success: false,
          message: 'Failed to set work location',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}