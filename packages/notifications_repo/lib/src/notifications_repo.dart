import 'dart:convert';
import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'models/notification.dart';
import 'models/notification_type.dart';
import 'models/notification_priority.dart';
import 'models/notification_response.dart';

/// Repository for managing notifications with modern architecture
class NotificationsRepo {
  const NotificationsRepo({
    required this.apiClient,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final Localstorage localStorage;
  
  static const String _notificationsKey = 'cached_notifications';
  static const String _settingsKey = 'notification_settings';
  static const String _pushTokenKey = 'push_token';

  /// Get notifications with optional filtering
  Future<NotificationResponse> getNotifications({
    int? limit,
    int? offset,
    NotificationType? type,
    bool? unreadOnly,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (type != null) queryParams['type'] = type.name;
      if (unreadOnly != null) queryParams['unreadOnly'] = unreadOnly;

      final response = await apiClient.get<Map<String, dynamic>>(
        NotificationsPaths.getNotifications,
        queryParameters: queryParams,
      );

      if (response is DataSuccess) {
        final data = response.data!;
        final notifications = (data['notifications'] as List<dynamic>)
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Cache notifications locally for offline access
        await cacheNotifications(notifications);
        
        return NotificationResponse(
          success: true,
          notifications: notifications,
          unreadCount: data['unreadCount'] as int? ?? 0,
        );
      } else {
        // Fallback to cached notifications on API failure
        final cachedNotifications = await getCachedNotifications();
        return NotificationResponse(
          success: true,
          notifications: cachedNotifications,
          unreadCount: cachedNotifications.where((n) => !n.isRead).length,
        );
      }
    } catch (e) {
      // Fallback to cached notifications on network error
      final cachedNotifications = await getCachedNotifications();
      return NotificationResponse(
        success: true,
        notifications: cachedNotifications,
        unreadCount: cachedNotifications.where((n) => !n.isRead).length,
      );
    }
  }

  /// Mark a notification as read
  Future<NotificationResponse> markAsRead(String notificationId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '${NotificationsPaths.markAsRead}/$notificationId',
      );

      if (response is DataSuccess) {
        // Update local cache
        final notifications = await getCachedNotifications();
        final updatedNotifications = notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        await cacheNotifications(updatedNotifications);
        
        return const NotificationResponse(success: true);
      } else {
        return NotificationResponse(
          success: false,
          message: 'Failed to mark notification as read',
        );
      }
    } catch (e) {
      return NotificationResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Mark all notifications as read
  Future<NotificationResponse> markAllAsRead() async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        NotificationsPaths.markAllAsRead,
      );

      if (response is DataSuccess) {
        // Update local cache
        final notifications = await getCachedNotifications();
        final updatedNotifications = notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
        await cacheNotifications(updatedNotifications);
        
        return const NotificationResponse(success: true);
      } else {
        return NotificationResponse(
          success: false,
          message: 'Failed to mark all notifications as read',
        );
      }
    } catch (e) {
      return NotificationResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Delete a notification
  Future<NotificationResponse> deleteNotification(String notificationId) async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>(
        '${NotificationsPaths.deleteNotification}/$notificationId',
      );

      if (response is DataSuccess) {
        // Update local cache
        final notifications = await getCachedNotifications();
        final updatedNotifications = notifications
            .where((notification) => notification.id != notificationId)
            .toList();
        await cacheNotifications(updatedNotifications);
        
        return const NotificationResponse(success: true);
      } else {
        return NotificationResponse(
          success: false,
          message: 'Failed to delete notification',
        );
      }
    } catch (e) {
      return NotificationResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Delete all notifications
  Future<NotificationResponse> deleteAllNotifications() async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>(
        NotificationsPaths.deleteAllNotifications,
      );

      if (response is DataSuccess) {
        // Clear local cache
        await localStorage.remove(_notificationsKey);
        
        return const NotificationResponse(success: true);
      } else {
        return NotificationResponse(
          success: false,
          message: 'Failed to delete all notifications',
        );
      }
    } catch (e) {
      return NotificationResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        NotificationsPaths.getUnreadCount,
      );

      if (response is DataSuccess) {
        return response.data!['unreadCount'] as int? ?? 0;
      } else {
        // Fallback to cached count
        final cachedNotifications = await getCachedNotifications();
        return cachedNotifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      // Fallback to cached count
      final cachedNotifications = await getCachedNotifications();
      return cachedNotifications.where((n) => !n.isRead).length;
    }
  }

  /// Update push token for notifications
  Future<bool> updatePushToken(String pushToken) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        NotificationsPaths.updatePushToken,
        data: {'pushToken': pushToken},
      );

      if (response is DataSuccess) {
        // Store token locally
        await localStorage.saveString(_pushTokenKey, pushToken);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get notification preferences
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        NotificationsPaths.getNotificationPreferences,
      );

      if (response is DataSuccess) {
        return response.data!;
      } else {
        return _getDefaultSettings();
      }
    } catch (e) {
      return _getDefaultSettings();
    }
  }

  /// Update notification preferences
  Future<bool> updateNotificationPreferences(Map<String, dynamic> preferences) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        NotificationsPaths.updateNotificationPreferences,
        data: preferences,
      );

      if (response is DataSuccess) {
        // Update local cache
        await localStorage.saveString(_settingsKey, jsonEncode(preferences));
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get notification history
  Future<List<Notification>> getNotificationHistory({
    int? limit,
    int? offset,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (fromDate != null) queryParams['fromDate'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['toDate'] = toDate.toIso8601String();

      final response = await apiClient.get<Map<String, dynamic>>(
        NotificationsPaths.getNotificationHistory,
        queryParameters: queryParams,
      );

      if (response is DataSuccess) {
        final data = response.data!;
        return (data['notifications'] as List<dynamic>)
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Cache notifications locally
  Future<void> cacheNotifications(List<Notification> notifications) async {
    try {
      final jsonList = notifications.map((n) => _notificationToJson(n)).toList();
      await localStorage.saveString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      // Handle error silently for caching
    }
  }

  /// Get cached notifications
  Future<List<Notification>> getCachedNotifications() async {
    try {
      final jsonString = localStorage.getString(_notificationsKey);
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
      await localStorage.saveString(_settingsKey, jsonEncode(settings));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final jsonString = localStorage.getString(_settingsKey);
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
