import 'package:notification_repo/notification_repo.dart';

abstract class InboxState {}

class InboxInitial extends InboxState {}

class InboxLoading extends InboxState {}

class NotificationsLoaded extends InboxState {
  final List<Notification> notifications;

  NotificationsLoaded(this.notifications);
}

class InboxError extends InboxState {
  final String message;

  InboxError(this.message);
}

class SupportLoaded extends InboxState {}
