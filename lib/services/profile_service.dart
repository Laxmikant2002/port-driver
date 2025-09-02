import 'package:driver/services/socket_service.dart';
import 'package:profile_repo/profile_repo.dart';
import 'package:driver/services/notification_service.dart';

class ProfileService {
  final ProfileRepository _repository;
  final SocketService _socketService;
  final NotificationService _notificationService;

  ProfileService(
    this._repository,
    this._socketService,
    this._notificationService,
  );

  Future<void> initializeProfileUpdates(String driverId) async {
    _socketService.listenToProfileUpdates(driverId);
    _socketService.listenToDocumentVerification(driverId);
  }
}