import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_repo/notification_repo.dart';
import 'inbox_event.dart';
import 'inbox_state.dart';

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final NotificationRepository _notificationRepository;

  InboxBloc(this._notificationRepository) : super(InboxInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<ClearAllNotifications>(_onClearAllNotifications);
    on<DeleteNotification>(_onDeleteNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<InboxState> emit,
  ) async {
    emit(InboxLoading());
    try {
      final notifications = await _notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(InboxError('Failed to load notifications'));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<InboxState> emit,
  ) async {
    try {
      await _notificationRepository.markNotificationAsRead(event.notificationId);
      final notifications = await _notificationRepository.getNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(InboxError('Failed to mark notification as read'));
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<InboxState> emit,
  ) async {
    try {
      await _notificationRepository.clearNotifications();
      emit(NotificationsLoaded([]));
    } catch (e) {
      emit(InboxError('Failed to clear notifications'));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<InboxState> emit,
  ) async {
    try {
      final notifications = await _notificationRepository.getNotifications();
      notifications.removeWhere((n) => n.id == event.notificationId);
      await _notificationRepository.clearNotifications();
      for (var notification in notifications) {
        await _notificationRepository.saveNotification(notification);
      }
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(InboxError('Failed to delete notification'));
    }
  }
}
