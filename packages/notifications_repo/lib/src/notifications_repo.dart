import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/notification.dart';
import 'models/notification_type.dart';
import 'models/notification_priority.dart';
import 'models/notification_response.dart';

/// Repository for managing notifications
class NotificationsRepo {
  NotificationsRepo({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;
  static const String _notificationsKey = 'cached_notifications';
  static const String _settingsKey = 'notification_settings';

  /// Get notifications with optional filtering
  Future<NotificationResponse> getNotifications({
    int? limit,
    int? offset,
    NotificationType? type,
    bool? unreadOnly,
  }) async {
    try {
      // In a real implementation, this would make an API call
      // For now, we'll return cached notifications
      final cachedNotifications = await getCachedNotifications();
      
      List<Notification> filtered = List.from(cachedNotifications);
      
      // Apply filters
      if (type != null) {
        filtered = filtered.where((n) => n.type == type).toList();
      }
      
      if (unreadOnly == true) {
        filtered = filtered.where((n) => !n.isRead).toList();
      }
      
      // Apply pagination
      if (offset != null && offset > 0) {
        filtered = filtered.skip(offset).toList();
      }
      
      if (limit != null && limit > 0) {
        filtered = filtered.take(limit).toList();
      }
      
      final unreadCount = cachedNotifications.where((n) => !n.isRead).length;
      
      return NotificationResponse(
        success: true,
        notifications: filtered,
        unreadCount: unreadCount,
      );
    } catch (e) {
      return NotificationResponse(
        success: false,
        message: 'Failed to load notifications: $e',
      );
    }
  }

  /// Mark a notification as read
  Future<NotificationResponse> markAsRead(String notificationId) async {
    try {
      final notifications = await getCachedNotifications();
      final updatedNotifications = notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
      
      await cacheNotifications(updatedNotifications);
      
      return const NotificationResponse(success: true);
    } catch (e) {
      return NotificationResponse(
        success: false,
        message: 'Failed to mark notification as read: $e',
      );
    }
  }

  /// Mark all notifications as read
  Future<NotificationResponse> markAllAsRead() async {
    try {
      final notifications = await getCachedNotifications();
      final updatedNotifications = notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();
      
      await cacheNotifications(updatedNotifications);
      
      return const NotificationResponse(success: true);
    } catch (e) {
      return NotificationResponse(
        success: false,
        message: 'Failed to mark all notifications as read: $e',
      );
    }
  }

  /// Delete a notification
  Future<NotificationResponse> deleteNotification(String notificationId) async {
    try {
      final notifications = await getCachedNotifications();
      final updatedNotifications = notifications
          .where((notification) => notification.id != notificationId)
          .toList();
      
      await cacheNotifications(updatedNotifications);
      
      return const NotificationResponse(success: true);
    } catch (e) {
      return NotificationResponse(
        success: false,
        message: 'Failed to delete notification: $e',
      );
    }
  }

  /// Delete all notifications
  Future<NotificationResponse> deleteAllNotifications() async {
    try {
      await _prefs.remove(_notificationsKey);
      
      return const NotificationResponse(success: true);
    } catch (e) {
      return NotificationResponse(
        success: false,
        message: 'Failed to delete all notifications: $e',
      );
    }
  }

  /// Cache notifications locally
  Future<void> cacheNotifications(List<Notification> notifications) async {
    try {
      final jsonList = notifications.map((n) => _notificationToJson(n)).toList();
      await _prefs.setString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      // Handle error silently for caching
    }
  }

  /// Get cached notifications
  Future<List<Notification>> getCachedNotifications() async {
    try {
      final jsonString = _prefs.getString(_notificationsKey);
      if (jsonString == null) {
        return _getSampleNotifications();
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => _notificationFromJson(json)).toList();
    } catch (e) {
      return _getSampleNotifications();
    }
  }

  /// Save notification settings
  Future<bool> saveNotificationSettings(Map<String, dynamic> settings) async {
    try {
      await _prefs.setString(_settingsKey, jsonEncode(settings));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final jsonString = _prefs.getString(_settingsKey);
      if (jsonString == null) {
        return _getDefaultSettings();
      }
      
      final Map<String, dynamic> settings = jsonDecode(jsonString);
      return settings;
    } catch (e) {
      return _getDefaultSettings();
    }
  }

  /// Convert Notification to JSON
  Map<String, dynamic> _notificationToJson(Notification notification) {
    return {
      'id': notification.id,
      'title': notification.title,
      'body': notification.body,
      'type': notification.type.name,
      'priority': notification.priority.name,
      'createdAt': notification.createdAt.toIso8601String(),
      'isRead': notification.isRead,
      'data': notification.data,
    };
  }

  /// Convert JSON to Notification
  Notification _notificationFromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Get default notification settings
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'pushEnabled': true,
      'emailEnabled': true,
      'smsEnabled': false,
      'rideRequests': true,
      'rideUpdates': true,
      'paymentUpdates': true,
      'systemUpdates': true,
    };
  }

  /// Get sample notifications for demo purposes
  List<Notification> _getSampleNotifications() {
    final now = DateTime.now();
    return [
      Notification(
        id: '1',
        title: 'New Ride Request',
        body: 'You have a new ride request from John Doe',
        type: NotificationType.ride,
        priority: NotificationPriority.high,
        createdAt: now.subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      Notification(
        id: '2',
        title: 'Payment Received',
        body: 'Payment of \$25.50 has been credited to your account',
        type: NotificationType.payment,
        priority: NotificationPriority.normal,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      Notification(
        id: '3',
        title: 'System Maintenance',
        body: 'Scheduled maintenance will occur tonight from 2-4 AM',
        type: NotificationType.maintenance,
        priority: NotificationPriority.low,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
      ),
    ];
  }
}
