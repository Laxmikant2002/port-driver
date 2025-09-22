part of 'notification_bloc.dart';

/// Base class for all Notification events
sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when notifications are loaded
final class NotificationsLoaded extends NotificationEvent {
  const NotificationsLoaded({
    this.limit,
    this.offset,
    this.type,
    this.unreadOnly,
  });

  final int? limit;
  final int? offset;
  final NotificationType? type;
  final bool? unreadOnly;

  @override
  List<Object> get props => [limit ?? 0, offset ?? 0, type ?? NotificationType.system, unreadOnly ?? false];

  @override
  String toString() => 'NotificationsLoaded(limit: $limit, offset: $offset, type: $type, unreadOnly: $unreadOnly)';
}

/// Event triggered when a notification is selected for viewing
final class NotificationSelected extends NotificationEvent {
  const NotificationSelected(this.notification);

  final Notification notification;

  @override
  List<Object> get props => [notification];

  @override
  String toString() => 'NotificationSelected(notification: $notification)';
}

/// Event triggered when a notification is marked as read
final class NotificationMarkedAsRead extends NotificationEvent {
  const NotificationMarkedAsRead(this.notificationId);

  final String notificationId;

  @override
  List<Object> get props => [notificationId];

  @override
  String toString() => 'NotificationMarkedAsRead(notificationId: $notificationId)';
}

/// Event triggered when all notifications are marked as read
final class AllNotificationsMarkedAsRead extends NotificationEvent {
  const AllNotificationsMarkedAsRead();

  @override
  String toString() => 'AllNotificationsMarkedAsRead()';
}

/// Event triggered when a notification is deleted
final class NotificationDeleted extends NotificationEvent {
  const NotificationDeleted(this.notificationId);

  final String notificationId;

  @override
  List<Object> get props => [notificationId];

  @override
  String toString() => 'NotificationDeleted(notificationId: $notificationId)';
}

/// Event triggered when all notifications are deleted
final class AllNotificationsDeleted extends NotificationEvent {
  const AllNotificationsDeleted();

  @override
  String toString() => 'AllNotificationsDeleted()';
}

/// Event triggered when notifications are filtered
final class NotificationsFiltered extends NotificationEvent {
  const NotificationsFiltered({
    this.type,
    this.priority,
    this.unreadOnly,
  });

  final NotificationType? type;
  final NotificationPriority? priority;
  final bool? unreadOnly;

  @override
  List<Object> get props => [
        type ?? NotificationType.system,
        priority ?? NotificationPriority.normal,
        unreadOnly ?? false,
      ];

  @override
  String toString() => 'NotificationsFiltered(type: $type, priority: $priority, unreadOnly: $unreadOnly)';
}

/// Event triggered when notifications are refreshed
final class NotificationsRefreshed extends NotificationEvent {
  const NotificationsRefreshed();

  @override
  String toString() => 'NotificationsRefreshed()';
}

/// Event triggered when notification settings are updated
final class NotificationSettingsUpdated extends NotificationEvent {
  const NotificationSettingsUpdated(this.settings);

  final Map<String, dynamic> settings;

  @override
  List<Object> get props => [settings];

  @override
  String toString() => 'NotificationSettingsUpdated(settings: $settings)';
}
