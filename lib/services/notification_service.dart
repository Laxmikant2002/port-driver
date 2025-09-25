import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications_repo/notifications_repo.dart' as notification_repo;
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// Comprehensive notification service for driver app
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  late final Localstorage _localStorage;
  
  final StreamController<notification_repo.Notification> _notificationController = StreamController<notification_repo.Notification>.broadcast();
  final StreamController<int> _unreadCountController = StreamController<int>.broadcast();
  
  Stream<notification_repo.Notification> get notificationStream => _notificationController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  /// Initialize the notification service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _localStorage = Localstorage(prefs);
    await _initializeFirebaseMessaging();
    await _initializeLocalNotifications();
    await _loadUnreadCount();
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission for notifications');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('User denied permission for notifications');
    }

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');
    
    // Save token to server (implement this based on your backend)
    await _saveFCMTokenToServer(token);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Handle notification tap when app is terminated
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );
  }

  /// Handle foreground FCM messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    
    final notification = _parseRemoteMessage(message);
    if (notification != null) {
      _notificationController.add(notification);
      _incrementUnreadCount();
      
      // Show in-app popup for important notifications
      if (notification.type.shouldShowPopup) {
        _showInAppNotification(notification);
      }
    }
  }

  /// Handle background FCM messages
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Received background message: ${message.messageId}');
    
    final notification = _parseRemoteMessage(message);
    if (notification != null) {
      _notificationController.add(notification);
      _incrementUnreadCount();
    }
  }

  /// Parse RemoteMessage to Notification model
  notification_repo.Notification? _parseRemoteMessage(RemoteMessage message) {
    try {
      final data = message.data;
      final notification = message.notification;
      
      if (notification == null) return null;

      return notification_repo.Notification(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        type: _parseNotificationType((data['type'] ?? 'system').toString()),
        priority: _parseNotificationPriority((data['priority'] ?? 'normal').toString()),
        createdAt: DateTime.now(),
        isRead: false,
        data: data is Map<String, dynamic> ? data : <String, dynamic>{},
      );
    } catch (e) {
      debugPrint('Error parsing notification: $e');
      return null;
    }
  }

  /// Parse notification type from string
  notification_repo.NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'new_ride_request':
        return notification_repo.NotificationType.newRideRequest;
      case 'booking_confirmed':
        return notification_repo.NotificationType.bookingConfirmed;
      case 'booking_cancelled':
        return notification_repo.NotificationType.bookingCancelled;
      case 'pickup_reminder':
        return notification_repo.NotificationType.pickupReminder;
      case 'document_approved':
        return notification_repo.NotificationType.documentApproved;
      case 'document_rejected':
        return notification_repo.NotificationType.documentRejected;
      case 'vehicle_assignment_changed':
        return notification_repo.NotificationType.vehicleAssignmentChanged;
      case 'payment_received':
        return notification_repo.NotificationType.paymentReceived;
      case 'weekly_payout_credited':
        return notification_repo.NotificationType.weeklyPayoutCredited;
      case 'app_update':
        return notification_repo.NotificationType.appUpdate;
      case 'policy_update':
        return notification_repo.NotificationType.policyUpdate;
      case 'work_area_update':
        return notification_repo.NotificationType.workAreaUpdate;
      case 'penalty_warning':
        return notification_repo.NotificationType.penaltyWarning;
      case 'suspension_warning':
        return notification_repo.NotificationType.suspensionWarning;
      case 'emergency':
        return notification_repo.NotificationType.emergency;
      default:
        return notification_repo.NotificationType.system;
    }
  }

  /// Parse notification priority from string
  notification_repo.NotificationPriority _parseNotificationPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return notification_repo.NotificationPriority.high;
      case 'normal':
        return notification_repo.NotificationPriority.normal;
      case 'low':
        return notification_repo.NotificationPriority.low;
      case 'urgent':
        return notification_repo.NotificationPriority.urgent;
      default:
        return notification_repo.NotificationPriority.normal;
    }
  }

  /// Show in-app notification popup
  void _showInAppNotification(notification_repo.Notification notification) {
    // This would typically be handled by the UI layer
    // For now, we'll just log it
    debugPrint('Showing in-app notification: ${notification.title}');
  }

  /// Handle local notification tap
  void _onLocalNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final notification = notification_repo.Notification(
          id: data['id'] != null ? data['id'].toString() : DateTime.now().millisecondsSinceEpoch.toString(),
          title: (data['title'] ?? 'Notification').toString(),
          body: (data['body'] ?? '').toString(),
          type: _parseNotificationType((data['type'] ?? 'system').toString()),
          priority: _parseNotificationPriority((data['priority'] ?? 'normal').toString()),
          createdAt: DateTime.tryParse((data['createdAt'] ?? '').toString()) ?? DateTime.now(),
          isRead: data['isRead'] is bool ? data['isRead'] as bool : false,
          data: data is Map<String, dynamic> ? data as Map<String, dynamic> : <String, dynamic>{},
        );
        _notificationController.add(notification);
      } catch (e) {
        debugPrint('Error parsing local notification payload: $e');
      }
    }
  }

  /// Schedule a local notification (e.g., pickup reminder)
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'driver_notifications',
      'Driver Notifications',
      channelDescription: 'Notifications for driver app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Schedule pickup reminder notification
  Future<void> schedulePickupReminder({
    required String bookingId,
    required DateTime pickupTime,
    required String customerName,
    required String pickupAddress,
  }) async {
    final reminderTime = pickupTime.subtract(const Duration(minutes: 5));
    
    if (reminderTime.isAfter(DateTime.now())) {
      final payload = jsonEncode({
        'type': 'pickup_reminder',
        'bookingId': bookingId,
        'pickupTime': pickupTime.toIso8601String(),
        'customerName': customerName,
        'pickupAddress': pickupAddress,
      });

      await scheduleLocalNotification(
        id: bookingId.hashCode,
        title: 'Pickup Reminder',
        body: 'Pickup for $customerName in 5 minutes at $pickupAddress',
        scheduledDate: reminderTime,
        payload: payload,
      );
    }
  }

  /// Save FCM token to server
  Future<void> _saveFCMTokenToServer(String? token) async {
    if (token == null) return;
    
    try {
      // TODO: Implement API call to save token to your backend
      _localStorage.saveString('fcm_token', token);
      debugPrint('FCM token saved locally: $token');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Load unread count from storage
  Future<void> _loadUnreadCount() async {
    try {
      final count = _localStorage.getString('unread_count');
      _unreadCount = count != null ? int.tryParse(count) ?? 0 : 0;
      _unreadCountController.add(_unreadCount);
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  /// Increment unread count
  void _incrementUnreadCount() {
    _unreadCount++;
    _unreadCountController.add(_unreadCount);
    _localStorage.saveString('unread_count', _unreadCount.toString());
  }

  /// Decrement unread count
  void _decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      _unreadCountController.add(_unreadCount);
      _localStorage.saveString('unread_count', _unreadCount.toString());
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    _decrementUnreadCount();
    // TODO: Implement API call to mark notification as read on server
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    _unreadCount = 0;
    _unreadCountController.add(_unreadCount);
    _localStorage.saveString('unread_count', _unreadCount.toString());
    // TODO: Implement API call to mark all notifications as read on server
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Dispose resources
  void dispose() {
    _notificationController.close();
    _unreadCountController.close();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background message processing here
}
