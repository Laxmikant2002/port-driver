import 'package:vehicle_repo/vehicle_repo.dart'; // Import for VehicleRepository // Ensure this import points to the correct file
import 'package:driver/services/socket_service.dart';
import 'package:driver/services/notification_service.dart';

class VehicleService {
  final VehicleRepository _repository;
  final SocketService _socketService;
  final NotificationService _notificationService;

  VehicleService(
    this._repository,
    this._socketService,
    this._notificationService,
  );

  Future<void> initializeVehicleUpdates(String vehicleId) async {
    _socketService.listenToVehicleVerification(vehicleId);
  }
}