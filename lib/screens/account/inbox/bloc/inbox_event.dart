abstract class InboxEvent {}

class LoadNotifications extends InboxEvent {}

class MarkNotificationAsRead extends InboxEvent {
  final String notificationId;

  MarkNotificationAsRead(this.notificationId);
}

class ClearAllNotifications extends InboxEvent {}

class DeleteNotification extends InboxEvent {
  final String notificationId;

  DeleteNotification(this.notificationId);
}

class LoadSupport extends InboxEvent {}
