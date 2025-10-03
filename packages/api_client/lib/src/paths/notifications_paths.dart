import 'base_paths.dart';

class NotificationsPaths extends BasePaths {
  // Notification Management
  static final String getNotifications = "${BasePaths.baseUrl}/driver/notifications";
  static final String getUnreadCount = "${BasePaths.baseUrl}/driver/notifications/unread-count";
  static final String markAsRead = "${BasePaths.baseUrl}/driver/notifications/read";
  static final String markAllAsRead = "${BasePaths.baseUrl}/driver/notifications/mark-all-read";
  static final String deleteNotification = "${BasePaths.baseUrl}/driver/notifications";
  static final String deleteAllNotifications = "${BasePaths.baseUrl}/driver/notifications/delete-all";
  
  // Notification Settings
  static final String getNotificationSettings = "${BasePaths.baseUrl}/driver/notifications/settings";
  static final String updateNotificationSettings = "${BasePaths.baseUrl}/driver/notifications/settings";
  static final String updatePushToken = "${BasePaths.baseUrl}/driver/notifications/push-token";
  
  // Notification Types
  static final String getNotificationTypes = "${BasePaths.baseUrl}/driver/notifications/types";
  static final String getNotificationHistory = "${BasePaths.baseUrl}/driver/notifications/history";
  
  // Real-time Notifications (WebSocket endpoints)
  static final String notificationWebSocket = "${BasePaths.baseUrl.replaceFirst('http', 'ws')}/driver/notifications/ws";
  
  // Notification Preferences
  static final String getNotificationPreferences = "${BasePaths.baseUrl}/driver/notifications/preferences";
  static final String updateNotificationPreferences = "${BasePaths.baseUrl}/driver/notifications/preferences";
  
  // Emergency Notifications
  static final String sendEmergencyNotification = "${BasePaths.baseUrl}/driver/notifications/emergency";
  static final String getEmergencyNotifications = "${BasePaths.baseUrl}/driver/notifications/emergency";
}
