import 'package:notification_repo/notification_repo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_preferences_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final NotificationRepository _notificationRepository;
  late NotificationPreferencesService _prefsService;
  bool _isInitialized = false;

  NotificationService(this._notificationRepository)
      : _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _notificationRepository.saveFcmToken(token);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final localStorage = Localstorage(await SharedPreferences.getInstance());
    _prefsService = NotificationPreferencesService(localStorage);
    
    _isInitialized = true;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = Notification.fromJson(message.data);
    await _notificationRepository.saveNotification(notification);
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    final notification = Notification.fromJson(message.data);
    await _notificationRepository.saveNotification(notification);
  }

  void _handleNotificationTap(RemoteMessage message) async {
    final notification = Notification.fromJson(message.data);
    if (notification.deepLink != null) {
      _handleDeepLink(notification);
    }
  }

  void _handleDeepLink(Notification notification) {
    // Handle different types of deep links
    switch (notification.type) {
      case NotificationType.newRideRequest:
        // Navigate to ride request screen
        break;
      case NotificationType.rideAccepted:
      case NotificationType.rideStarted:
      case NotificationType.rideCompleted:
        // Navigate to ride details screen
        break;
      case NotificationType.paymentReceived:
      case NotificationType.walletUpdated:
        // Navigate to wallet screen
        break;
      case NotificationType.documentExpired:
      case NotificationType.documentApproved:
      case NotificationType.documentRejected:
        // Navigate to documents screen
        break;
      case NotificationType.dailyEarnings:
      case NotificationType.weeklyEarnings:
        // Navigate to earnings screen
        break;
      case NotificationType.promotion:
      case NotificationType.specialOffer:
        // Navigate to promotions screen
        break;
      default:
        // Handle other types or default behavior
        break;
    }
  }

  bool _shouldShowNotification(Notification notification) {
    // Always show critical notifications
    if (notification.type == NotificationType.safetyAlert) {
      return true;
    }

    // Check general notification settings
    if (!_prefsService.isPushEnabled) {
      return false;
    }

    // Check type-specific settings
    switch (notification.type) {
      case NotificationType.newRideRequest:
        return _prefsService.isRideRequestsEnabled;
      case NotificationType.rideAccepted:
      case NotificationType.rideStarted:
      case NotificationType.rideCompleted:
      case NotificationType.rideCancelled:
      case NotificationType.rideScheduled:
        return _prefsService.isRideUpdatesEnabled;
      case NotificationType.paymentReceived:
      case NotificationType.paymentFailed:
        return _prefsService.isPaymentUpdatesEnabled;
      case NotificationType.walletUpdated:
        return _prefsService.isWalletUpdatesEnabled;
      case NotificationType.withdrawalSuccess:
      case NotificationType.withdrawalFailed:
        return _prefsService.isWithdrawalUpdatesEnabled;
      case NotificationType.dailyEarnings:
      case NotificationType.weeklyEarnings:
      case NotificationType.bonusEarned:
      case NotificationType.incentiveEarned:
        return _prefsService.isEarningsUpdatesEnabled;
      case NotificationType.documentExpired:
        return _prefsService.isDocumentExpiryEnabled;
      case NotificationType.documentApproved:
      case NotificationType.documentRejected:
        return _prefsService.isDocumentStatusEnabled;
      case NotificationType.documentRequired:
        return _prefsService.isDocumentRequiredEnabled;
      case NotificationType.promotion:
        return _prefsService.isPromotionsEnabled;
      case NotificationType.referralBonus:
        return _prefsService.isReferralBonusEnabled;
      case NotificationType.specialOffer:
        return _prefsService.isSpecialOffersEnabled;
      case NotificationType.systemUpdate:
        return _prefsService.isSystemUpdatesEnabled;
      case NotificationType.maintenance:
        return _prefsService.isMaintenanceEnabled;
      case NotificationType.offlineWarning:
      case NotificationType.onlineReminder:
        return _prefsService.isOfflineRemindersEnabled;
      default:
        return true;
    }
  }
}
