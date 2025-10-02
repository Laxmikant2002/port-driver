import 'package:api_client/src/paths/base_paths.dart';

class DriverStatusPaths extends BasePaths {
  // Driver Status Management
  static final String updateDriverStatus = "${BasePaths.baseUrl}/driver/status";
  static final String getDriverStatus = "${BasePaths.baseUrl}/driver/status";
  static final String updateLocation = "${BasePaths.baseUrl}/driver/location";
  
  // Verification Status
  static final String checkVerificationStatus = "${BasePaths.baseUrl}/driver/verification-status";
  static final String getVerificationStatus = "${BasePaths.baseUrl}/driver/verification-status";
  
  // Driver Availability
  static final String goOnline = "${BasePaths.baseUrl}/driver/status/online";
  static final String goOffline = "${BasePaths.baseUrl}/driver/status/offline";
  static final String setBusy = "${BasePaths.baseUrl}/driver/status/busy";
}
