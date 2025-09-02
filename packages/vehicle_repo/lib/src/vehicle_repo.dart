import 'dart:io';
import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'package:vehicle_repo/src/models/vehicle_model.dart';

class VehicleRepository {
  final ApiClient _apiClient;
  final Localstorage _localStorage; // Updated class name

  VehicleRepository(this._apiClient, this._localStorage);

  Future<DataState<Vehicle>> getVehicle() async {
    return await _apiClient.getReq('/vehicle');
  }

  Future<DataState<Vehicle>> addVehicle(Map<String, dynamic> data) async {
    return await _apiClient.postReq('/vehicle', bodyJson: data); // Replace 'data' with 'bodyJson'
  }

  Future<DataState<Vehicle>> updateVehicle(String id, Map<String, dynamic> data) async {
    return await _apiClient.putReq('/vehicle/$id', bodyJson: data);
  }

  Future<DataState<String>> uploadDocument(String type, File file) async {
    return await _apiClient.uploadFile('/vehicle/documents', file: file, type: type); // Use uploadFile method
  }

  Future<void> fetchVehicleDetails(String vehicleId) async {
    // Implement logic to fetch vehicle details
  }

  Future<void> updateVehicleStatus(String vehicleId, String status) async {
    // Implement logic to update vehicle status
  }
}