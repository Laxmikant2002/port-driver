/// Enum representing different priority levels for notifications
enum NotificationPriority {
  low,
  normal,
  high,
  urgent;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => NotificationPriority.normal,
    );
  }
}

extension NotificationPriorityExtension on NotificationPriority {
  String get value {
    return name;
  }

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => NotificationPriority.normal,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }
}
