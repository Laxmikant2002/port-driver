part of 'notification_bloc.dart';

/// Modern Notification state with comprehensive data management
final class NotificationState extends Equatable {
  const NotificationState({
    this.allNotifications = const [],
    this.filteredNotifications = const [],
    this.selectedNotification,
    this.unreadCount = 0,
    this.notificationSettings = const {},
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final List<Notification> allNotifications;
  final List<Notification> filteredNotifications;
  final Notification? selectedNotification;
  final int unreadCount;
  final Map<String, dynamic> notificationSettings;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if notifications are currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns true if notifications were loaded successfully
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if notification operation failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error message
  bool get hasError => isFailure && errorMessage != null;

  /// Returns the current error message if any
  String? get error => errorMessage;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns the current notifications being displayed (filtered or all)
  List<Notification> get currentNotifications => filteredNotifications.isNotEmpty ? filteredNotifications : allNotifications;

  /// Returns notifications grouped by date
  Map<String, List<Notification>> get notificationsByDate {
    final Map<String, List<Notification>> grouped = {};
    
    for (final notification in allNotifications) {
      final date = notification.createdAt.toLocal().toString().split(' ')[0];
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(notification);
    }
    
    // Sort notifications within each date by creation time (newest first)
    for (final notifications in grouped.values) {
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return grouped;
  }

  /// Returns notifications grouped by type
  Map<NotificationType, List<Notification>> get notificationsByType {
    final Map<NotificationType, List<Notification>> grouped = {};
    
    for (final notification in allNotifications) {
      if (!grouped.containsKey(notification.type)) {
        grouped[notification.type] = [];
      }
      grouped[notification.type]!.add(notification);
    }
    
    return grouped;
  }

  /// Returns notifications grouped by priority
  Map<NotificationPriority, List<Notification>> get notificationsByPriority {
    final Map<NotificationPriority, List<Notification>> grouped = {};
    
    for (final notification in allNotifications) {
      if (!grouped.containsKey(notification.priority)) {
        grouped[notification.priority] = [];
      }
      grouped[notification.priority]!.add(notification);
    }
    
    return grouped;
  }

  /// Returns recent notifications (last 10)
  List<Notification> get recentNotifications {
    final sorted = List<Notification>.from(allNotifications);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(10).toList();
  }

  /// Returns urgent notifications
  List<Notification> get urgentNotifications {
    return allNotifications.where((n) => n.priority == NotificationPriority.urgent).toList();
  }

  /// Returns high priority notifications
  List<Notification> get highPriorityNotifications {
    return allNotifications.where((n) => n.priority == NotificationPriority.high).toList();
  }

  /// Returns system notifications
  List<Notification> get systemNotifications {
    return allNotifications.where((n) => n.type == NotificationType.system).toList();
  }

  /// Returns ride notifications
  List<Notification> get rideNotifications {
    return allNotifications.where((n) => n.type == NotificationType.ride).toList();
  }

  /// Returns payment notifications
  List<Notification> get paymentNotifications {
    return allNotifications.where((n) => n.type == NotificationType.payment).toList();
  }

  /// Returns promotion notifications
  List<Notification> get promotionNotifications {
    return allNotifications.where((n) => n.type == NotificationType.promotion).toList();
  }

  /// Returns emergency notifications
  List<Notification> get emergencyNotifications {
    return allNotifications.where((n) => n.type == NotificationType.emergency).toList();
  }

  /// Returns true if there are unread notifications
  bool get hasUnreadNotifications => unreadCount > 0;

  /// Returns true if there are urgent notifications
  bool get hasUrgentNotifications => urgentNotifications.isNotEmpty;

  /// Returns true if there are emergency notifications
  bool get hasEmergencyNotifications => emergencyNotifications.isNotEmpty;

  /// Returns notification priority distribution
  Map<NotificationPriority, int> get priorityDistribution {
    final distribution = <NotificationPriority, int>{};
    
    for (final priority in NotificationPriority.values) {
      distribution[priority] = allNotifications.where((n) => n.priority == priority).length;
    }
    
    return distribution;
  }

  /// Returns notification type distribution
  Map<NotificationType, int> get typeDistribution {
    final distribution = <NotificationType, int>{};
    
    for (final type in NotificationType.values) {
      distribution[type] = allNotifications.where((n) => n.type == type).length;
    }
    
    return distribution;
  }

  /// Returns notification statistics
  Map<String, int> get statistics {
    return {
      'total': allNotifications.length,
      'unread': unreadCount,
      'read': allNotifications.length - unreadCount,
      'urgent': urgentNotifications.length,
      'high_priority': highPriorityNotifications.length,
      'system': systemNotifications.length,
      'ride': rideNotifications.length,
      'payment': paymentNotifications.length,
      'promotion': promotionNotifications.length,
      'emergency': emergencyNotifications.length,
    };
  }

  /// Returns notifications for a specific date
  List<Notification> getNotificationsForDate(DateTime date) {
    final dateString = date.toLocal().toString().split(' ')[0];
    return notificationsByDate[dateString] ?? [];
  }

  /// Returns notifications for a specific type
  List<Notification> getNotificationsForType(NotificationType type) {
    return notificationsByType[type] ?? [];
  }

  /// Returns notifications for a specific priority
  List<Notification> getNotificationsForPriority(NotificationPriority priority) {
    return notificationsByPriority[priority] ?? [];
  }

  /// Returns unread notifications for a specific type
  List<Notification> getUnreadNotificationsForType(NotificationType type) {
    return getNotificationsForType(type).where((n) => !n.isRead).toList();
  }

  /// Returns unread notifications for a specific priority
  List<Notification> getUnreadNotificationsForPriority(NotificationPriority priority) {
    return getNotificationsForPriority(priority).where((n) => !n.isRead).toList();
  }

  /// Returns the most recent notification
  Notification? get mostRecentNotification {
    if (allNotifications.isEmpty) return null;
    
    final sorted = List<Notification>.from(allNotifications);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.first;
  }

  /// Returns the oldest unread notification
  Notification? get oldestUnreadNotification {
    final unread = allNotifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return null;
    
    unread.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return unread.first;
  }

  /// Returns true if there are notifications older than specified days
  bool hasNotificationsOlderThan(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return allNotifications.any((n) => n.createdAt.isBefore(cutoffDate));
  }

  /// Returns notifications older than specified days
  List<Notification> getNotificationsOlderThan(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return allNotifications.where((n) => n.createdAt.isBefore(cutoffDate)).toList();
  }

  NotificationState copyWith({
    List<Notification>? allNotifications,
    List<Notification>? filteredNotifications,
    Notification? selectedNotification,
    int? unreadCount,
    Map<String, dynamic>? notificationSettings,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      allNotifications: allNotifications ?? this.allNotifications,
      filteredNotifications: filteredNotifications ?? this.filteredNotifications,
      selectedNotification: selectedNotification ?? this.selectedNotification,
      unreadCount: unreadCount ?? this.unreadCount,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        allNotifications,
        filteredNotifications,
        selectedNotification,
        unreadCount,
        notificationSettings,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'NotificationState('
        'allNotifications: ${allNotifications.length}, '
        'filteredNotifications: ${filteredNotifications.length}, '
        'selectedNotification: $selectedNotification, '
        'unreadCount: $unreadCount, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}
