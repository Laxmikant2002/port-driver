import 'notification.dart';

/// Response model for notification API calls
class NotificationResponse {
  const NotificationResponse({
    required this.success,
    this.notifications,
    this.unreadCount,
    this.message,
  });

  final bool success;
  final List<Notification>? notifications;
  final int? unreadCount;
  final String? message;
}
