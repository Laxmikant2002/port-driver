import 'package:api_client/api_client.dart';
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
    required this.apiClient,
  });

  final ApiClient apiClient;

  /// Check driver status for route decision making
  Future<DriverStatusResponse> checkDriverStatus(String phoneNumber) async {
    try {
      final response = await apiClient.get(
        '${ProfilePaths.checkDriverStatus}/$phoneNumber',
      );

      if (response is DataSuccess) {
        return DriverStatusResponse.fromJson(response.data);
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
      final response = await apiClient.get(
        '${ProfilePaths.getProfile}/$driverId',
      );

      if (response is DataSuccess) {
        return ProfileResponse.fromJson(response.data);
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
      final response = await apiClient.put(
        '${ProfilePaths.updateProfile}/$driverId',
        data: profileData.toJson(),
      );

      if (response is DataSuccess) {
        return ProfileResponse.fromJson(response.data);
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
      final response = await apiClient.post(
        ProfilePaths.createProfile,
        data: {
          'phoneNumber': phoneNumber,
          ...profileData.toJson(),
        },
      );

      if (response is DataSuccess) {
        return ProfileResponse.fromJson(response.data);
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
      final response = await apiClient.post(
        '${ProfilePaths.uploadProfileImage}/$driverId',
        data: {'imagePath': imagePath},
      );

      if (response is DataSuccess) {
        return ProfileResponse.fromJson(response.data);
      } else {
        return ProfileResponse(
          success: false,
          message: 'Failed to upload profile image',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Delete profile image
  Future<ProfileResponse> deleteProfileImage(String driverId) async {
    try {
      final response = await apiClient.delete(
        '${ProfilePaths.deleteProfileImage}/$driverId',
      );

      if (response is DataSuccess) {
        return ProfileResponse.fromJson(response.data);
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

  /// Get assigned vehicle for driver
  Future<Map<String, dynamic>?> getAssignedVehicle(String driverId) async {
    try {
      final response = await apiClient.get(
        '${ProfilePaths.getAssignedVehicle}/$driverId',
      );

      if (response is DataSuccess) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get available vehicles for driver assignment (Admin endpoint)
  Future<List<VehicleInfo>> getAvailableVehicles() async {
    try {
      final response = await apiClient.get(
        ProfilePaths.getAvailableVehicles,
      );

      if (response is DataSuccess) {
        final vehicles = (response.data['vehicles'] as List<dynamic>)
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

  /// Assign vehicle to driver (Admin endpoint)
  Future<ProfileResponse> assignVehicle(String driverId, String vehicleId) async {
    try {
      final response = await apiClient.post(
        '${ProfilePaths.assignVehicle}/$driverId',
        data: {'vehicleId': vehicleId},
      );

      if (response is DataSuccess) {
        return ProfileResponse.fromJson(response.data);
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
      final response = await apiClient.post(
        '${ProfilePaths.setWorkLocation}/$driverId',
        data: location.toJson(),
      );

      if (response is DataSuccess) {
        return ProfileResponse.fromJson(response.data);
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

  /// Update work location for driver
  Future<ProfileResponse> updateWorkLocation(String driverId, WorkLocation location) async {
    try {
      final response = await apiClient.put(
        '${ProfilePaths.updateWorkLocation}/$driverId',
        data: location.toJson(),
      );

      if (response is DataSuccess) {
        return ProfileResponse.fromJson(response.data);
      } else {
        return ProfileResponse(
          success: false,
          message: 'Failed to update work location',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get work location for driver
  Future<WorkLocation?> getWorkLocation(String driverId) async {
    try {
      final response = await apiClient.get(
        '${ProfilePaths.getWorkLocation}/$driverId',
      );

      if (response is DataSuccess) {
        return WorkLocation.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Update profile preferences
  Future<ProfileResponse> updatePreferences(String driverId, Map<String, dynamic> preferences) async {
    try {
      final response = await apiClient.put(
        '${ProfilePaths.updatePreferences}/$driverId',
        data: preferences,
      );

      if (response is DataSuccess) {
        return ProfileResponse.fromJson(response.data);
      } else {
        return ProfileResponse(
          success: false,
          message: 'Failed to update preferences',
        );
      }
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get profile preferences
  Future<Map<String, dynamic>?> getPreferences(String driverId) async {
    try {
      final response = await apiClient.get(
        '${ProfilePaths.getPreferences}/$driverId',
      );

      if (response is DataSuccess) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get profile statistics
  Future<Map<String, dynamic>?> getProfileStats(String driverId) async {
    try {
      final response = await apiClient.get(
        '${ProfilePaths.getProfileStats}/$driverId',
      );

      if (response is DataSuccess) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get profile activity
  Future<List<Map<String, dynamic>>> getProfileActivity(String driverId) async {
    try {
      final response = await apiClient.get(
        '${ProfilePaths.getProfileActivity}/$driverId',
      );

      if (response is DataSuccess) {
        return List<Map<String, dynamic>>.from(response.data['activities'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}