import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications_repo/notifications_repo.dart' as notification_repo;
import 'package:localstorage/localstorage.dart';
import 'package:driver/services/core/service_interface.dart';

/// {@template notification_service_interface}
/// Interface for notification operations.
/// {@endtemplate}
abstract class NotificationServiceInterface extends ServiceInterface {
  /// {@macro notification_service_interface}
  const NotificationServiceInterface();

  /// Initialize notification service
  Future<ServiceResult<void>> initialize();

  /// Send local notification
  Future<ServiceResult<void>> sendLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  /// Schedule notification
  Future<ServiceResult<void>> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  });

  /// Cancel notification
  Future<ServiceResult<void>> cancelNotification(int id);

  /// Cancel all notifications
  Future<ServiceResult<void>> cancelAllNotifications();

  /// Get notification stream
  Stream<notification_repo.Notification> get notificationStream;

  /// Get unread count stream
  Stream<int> get unreadCountStream;

  /// Current unread count
  int get unreadCount;
}

/// {@template notification_preferences_service_interface}
/// Interface for notification preferences operations.
/// {@endtemplate}
abstract class NotificationPreferencesServiceInterface extends ServiceInterface {
  /// {@macro notification_preferences_service_interface}
  const NotificationPreferencesServiceInterface();

  /// Get notification preference
  bool getPreference(String key, {bool defaultValue = true});

  /// Set notification preference
  Future<ServiceResult<void>> setPreference(String key, bool value);

  /// Get all preferences
  Map<String, bool> getAllPreferences();

  /// Reset all preferences to default
  Future<ServiceResult<void>> resetToDefaults();

  /// Check if push notifications are enabled
  bool get isPushEnabled;

  /// Check if email notifications are enabled
  bool get isEmailEnabled;

  /// Check if SMS notifications are enabled
  bool get isSmsEnabled;
}

/// {@template push_notification_service_interface}
/// Interface for push notification operations.
/// {@endtemplate}
abstract class PushNotificationServiceInterface extends ServiceInterface {
  /// {@macro push_notification_service_interface}
  const PushNotificationServiceInterface();

  /// Request notification permissions
  Future<ServiceResult<NotificationSettings>> requestPermissions();

  /// Get FCM token
  Future<ServiceResult<String>> getFCMToken();

  /// Subscribe to topic
  Future<ServiceResult<void>> subscribeToTopic(String topic);

  /// Unsubscribe from topic
  Future<ServiceResult<void>> unsubscribeFromTopic(String topic);

  /// Handle background message
  Future<void> handleBackgroundMessage(RemoteMessage message);

  /// Handle foreground message
  Future<void> handleForegroundMessage(RemoteMessage message);
}

/// {@template notification_service_module}
/// Main notification service module that coordinates all notification operations.
/// {@endtemplate}
class NotificationServiceModule {
  /// {@macro notification_service_module}
  const NotificationServiceModule({
    required this.notificationService,
    required this.preferencesService,
    required this.pushService,
  });

  final NotificationServiceInterface notificationService;
  final NotificationPreferencesServiceInterface preferencesService;
  final PushNotificationServiceInterface pushService;

  /// Initialize all notification services
  Future<void> initialize() async {
    await notificationService.initialize();
    await preferencesService.initialize();
    await pushService.initialize();
  }

  /// Dispose all notification services
  Future<void> dispose() async {
    await notificationService.dispose();
    await preferencesService.dispose();
    await pushService.dispose();
  }

  /// Get service health status
  Map<String, bool> get healthStatus => {
    'notification': notificationService.isInitialized,
    'preferences': preferencesService.isInitialized,
    'push': pushService.isInitialized,
  };

  /// Send smart notification based on preferences
  Future<ServiceResult<void>> sendSmartNotification({
    required int id,
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
  }) async {
    try {
      // Check if this type of notification is enabled
      final isEnabled = preferencesService.getPreference(
        _getPreferenceKey(type),
        defaultValue: true,
      );

      if (!isEnabled) {
        return ServiceResult.success(null);
      }

      // Send notification
      return await notificationService.sendLocalNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      return ServiceResult.failure(NotificationServiceError(
        message: 'Failed to send smart notification: $e',
      ));
    }
  }

  /// Get preference key for notification type
  String _getPreferenceKey(NotificationType type) {
    switch (type) {
      case NotificationType.rideRequest:
        return 'ride_requests';
      case NotificationType.rideUpdate:
        return 'ride_updates';
      case NotificationType.payment:
        return 'payment_updates';
      case NotificationType.document:
        return 'document_status';
      case NotificationType.promotion:
        return 'promotions';
      case NotificationType.system:
        return 'system_updates';
    }
  }
}

/// {@template notification_type}
/// Types of notifications.
/// {@endtemplate}
enum NotificationType {
  rideRequest('ride_request'),
  rideUpdate('ride_update'),
  payment('payment'),
  document('document'),
  promotion('promotion'),
  system('system');

  const NotificationType(this.value);
  final String value;
}

/// {@template notification_service_error}
/// Error specific to notification services.
/// {@endtemplate}
class NotificationServiceError extends ServiceError {
  /// {@macro notification_service_error}
  const NotificationServiceError({
    required super.message,
    super.code,
    super.details,
  });
}

// Re-export types from other files for convenience
export 'notification_service.dart';
export 'notification_preferences_service.dart';
