import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:notification_repo/src/models/notification.dart';


class NotificationRepository {
  final Localstorage _storage;
  static const String _fcmTokenKey = 'fcm_token';
  static const String _notificationsKey = 'notifications';

  NotificationRepository(this._storage);

  Future<void> saveFcmToken(String token) async {
    _storage.saveString(_fcmTokenKey, token);
  }

  Future<String?> getFcmToken() async {
    return _storage.getString(_fcmTokenKey);
  }

  Future<void> saveNotification(Notification notification) async {
    final notifications = await getNotifications();
    notifications.insert(0, notification); // Insert at the beginning
    _storage.saveString(_notificationsKey, jsonEncode(notifications.map((n) => n.toJson()).toList()));
  }

  Future<List<Notification>> getNotifications() async {
    final data = _storage.getString(_notificationsKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Notification.fromJson(json)).toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _storage.saveString(_notificationsKey, jsonEncode(notifications.map((n) => n.toJson()).toList()));
    }
  }

  Future<void> clearNotifications() async {
    _storage.saveString(_notificationsKey, jsonEncode([]));
  }
}