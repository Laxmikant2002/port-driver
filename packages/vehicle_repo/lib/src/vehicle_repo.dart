import 'package:api_client/api_client.dart';
import 'package:equatable/equatable.dart';

/// Vehicle assignment model
class VehicleAssignment extends Equatable {
  const VehicleAssignment({
    required this.assignmentId,
    required this.driverId,
    required this.vehicleId,
    required this.numberPlate,
    required this.vehicleType,
    required this.assignmentDate,
    required this.status,
    this.insuranceStatus,
    this.rcStatus,
    this.vehiclePhoto,
    this.assignedBy,
    this.createdAt,
    this.updatedAt,
  });

  final String assignmentId;
  final String driverId;
  final String vehicleId;
  final String numberPlate;
  final String vehicleType;
  final String assignmentDate;
  final String status;
  final String? insuranceStatus;
  final String? rcStatus;
  final String? vehiclePhoto;
  final String? assignedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory VehicleAssignment.fromJson(Map<String, dynamic> json) {
    return VehicleAssignment(
      assignmentId: json['assignmentId'] as String,
      driverId: json['driverId'] as String,
      vehicleId: json['vehicleId'] as String,
      numberPlate: json['numberPlate'] as String,
      vehicleType: json['vehicleType'] as String,
      assignmentDate: json['assignmentDate'] as String,
      status: json['status'] as String,
      insuranceStatus: json['insuranceStatus'] as String?,
      rcStatus: json['rcStatus'] as String?,
      vehiclePhoto: json['vehiclePhoto'] as String?,
      assignedBy: json['assignedBy'] as String?,
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
      'assignmentId': assignmentId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'numberPlate': numberPlate,
      'vehicleType': vehicleType,
      'assignmentDate': assignmentDate,
      'status': status,
      'insuranceStatus': insuranceStatus,
      'rcStatus': rcStatus,
      'vehiclePhoto': vehiclePhoto,
      'assignedBy': assignedBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        assignmentId,
        driverId,
        vehicleId,
        numberPlate,
        vehicleType,
        assignmentDate,
        status,
        insuranceStatus,
        rcStatus,
        vehiclePhoto,
        assignedBy,
        createdAt,
        updatedAt,
      ];
}

/// Vehicle assignment response model
class VehicleAssignmentResponse extends Equatable {
  const VehicleAssignmentResponse({
    required this.success,
    this.message,
    this.assignment,
  });

  final bool success;
  final String? message;
  final VehicleAssignment? assignment;

  factory VehicleAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return VehicleAssignmentResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      assignment: json['assignment'] != null 
          ? VehicleAssignment.fromJson(json['assignment'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, message, assignment];
}

/// Vehicle repository for managing vehicle assignments
class VehicleRepo {
  const VehicleRepo({
    required this.apiClient,
  });

  final ApiClient apiClient;

  /// Get assigned vehicle for current driver
  Future<VehicleAssignmentResponse> getAssignedVehicle() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(VehiclePaths.getAssignedVehicle);

      if (response is DataSuccess) {
        return VehicleAssignmentResponse.fromJson(response.data!);
      } else {
        return VehicleAssignmentResponse(
          success: false,
          message: 'Failed to fetch assigned vehicle',
        );
      }
    } catch (e) {
      return VehicleAssignmentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get vehicle details by ID
  Future<VehicleAssignmentResponse> getVehicleDetails(String vehicleId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('${VehiclePaths.getVehicleDetails}/$vehicleId');

      if (response is DataSuccess) {
        return VehicleAssignmentResponse.fromJson(response.data!);
      } else {
        return VehicleAssignmentResponse(
          success: false,
          message: 'Failed to fetch vehicle details',
        );
      }
    } catch (e) {
      return VehicleAssignmentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get vehicle status
  Future<Map<String, dynamic>?> getVehicleStatus(String vehicleId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('${VehiclePaths.getVehicleStatus}/$vehicleId');

      if (response is DataSuccess) {
        return response.data!;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update vehicle status
  Future<VehicleAssignmentResponse> updateVehicleStatus(String vehicleId, Map<String, dynamic> statusData) async {
    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        '${VehiclePaths.updateVehicleStatus}/$vehicleId',
        data: statusData,
      );

      if (response is DataSuccess) {
        return VehicleAssignmentResponse.fromJson(response.data!);
      } else {
        return VehicleAssignmentResponse(
          success: false,
          message: 'Failed to update vehicle status',
        );
      }
    } catch (e) {
      return VehicleAssignmentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
