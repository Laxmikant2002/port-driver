import 'package:api_client/src/paths/base_paths.dart';

class ProfilePaths extends BasePaths {
  // Profile Management
  static final String createProfile = "${BasePaths.baseUrl}/driver/profile";
  static final String getProfile = "${BasePaths.baseUrl}/driver/profile";
  static final String updateProfile = "${BasePaths.baseUrl}/driver/profile";
  static final String deleteProfile = "${BasePaths.baseUrl}/driver/profile";
  
  // Profile Status & Verification
  static final String checkDriverStatus = "${BasePaths.baseUrl}/driver/status";
  static final String verifyProfile = "${BasePaths.baseUrl}/driver/profile/verify";
  
  // Profile Images
  static final String uploadProfileImage = "${BasePaths.baseUrl}/driver/profile/image";
  static final String deleteProfileImage = "${BasePaths.baseUrl}/driver/profile/image";
  
  // Vehicle Management
  static final String getAvailableVehicles = "${BasePaths.baseUrl}/driver/vehicles/available";
  static final String assignVehicle = "${BasePaths.baseUrl}/driver/vehicle/assign";
  static final String getAssignedVehicle = "${BasePaths.baseUrl}/driver/assigned-vehicle";
  static final String updateVehicle = "${BasePaths.baseUrl}/driver/vehicle";
  static final String removeVehicle = "${BasePaths.baseUrl}/driver/vehicle";
  
  // Work Location
  static final String setWorkLocation = "${BasePaths.baseUrl}/driver/location";
  static final String getWorkLocation = "${BasePaths.baseUrl}/driver/location";
  static final String updateWorkLocation = "${BasePaths.baseUrl}/driver/location";
  
  // Profile Preferences
  static final String updatePreferences = "${BasePaths.baseUrl}/driver/preferences";
  static final String getPreferences = "${BasePaths.baseUrl}/driver/preferences";
  
  // Profile Statistics
  static final String getProfileStats = "${BasePaths.baseUrl}/driver/profile/stats";
  static final String getProfileActivity = "${BasePaths.baseUrl}/driver/profile/activity";
}
