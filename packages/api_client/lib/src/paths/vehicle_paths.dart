import 'base_paths.dart';

class VehiclePaths extends BasePaths {
  // Vehicle Assignment (Driver endpoints)
  static final String getAssignedVehicle = "${BasePaths.baseUrl}/driver/assigned-vehicle";
  static final String getVehicleDetails = "${BasePaths.baseUrl}/driver/vehicle";
  
  // Vehicle Management (Admin endpoints - for reference)
  static final String assignVehicle = "${BasePaths.baseUrl}/admin/assign-vehicle";
  static final String getAvailableVehicles = "${BasePaths.baseUrl}/admin/vehicles/available";
  static final String updateVehicle = "${BasePaths.baseUrl}/admin/vehicle";
  static final String removeVehicle = "${BasePaths.baseUrl}/admin/vehicle";
  
  // Vehicle Status
  static final String getVehicleStatus = "${BasePaths.baseUrl}/driver/vehicle/status";
  static final String updateVehicleStatus = "${BasePaths.baseUrl}/driver/vehicle/status";
}
