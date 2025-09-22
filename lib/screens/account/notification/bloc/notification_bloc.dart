import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:notifications_repo/notifications_repo.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({required this.notificationsRepo}) : super(const NotificationState()) {
    on<NotificationsLoaded>(_onNotificationsLoaded);
    on<NotificationSelected>(_onNotificationSelected);
    on<NotificationMarkedAsRead>(_onNotificationMarkedAsRead);
    on<AllNotificationsMarkedAsRead>(_onAllNotificationsMarkedAsRead);
    on<NotificationDeleted>(_onNotificationDeleted);
    on<AllNotificationsDeleted>(_onAllNotificationsDeleted);
    on<NotificationsFiltered>(_onNotificationsFiltered);
    on<NotificationsRefreshed>(_onNotificationsRefreshed);
    on<NotificationSettingsUpdated>(_onNotificationSettingsUpdated);
  }

  final NotificationsRepo notificationsRepo;

  Future<void> _onNotificationsLoaded(
    NotificationsLoaded event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await notificationsRepo.getNotifications(
        limit: event.limit,
        offset: event.offset,
        type: event.type,
        unreadOnly: event.unreadOnly,
      );
      
      if (response.success && response.notifications != null) {
        // Cache notifications for offline access
        await notificationsRepo.cacheNotifications(response.notifications!);
        
        // Get cached notifications as fallback
        final cachedNotifications = await notificationsRepo.getCachedNotifications();
        
        // Get unread count
        final unreadCount = response.unreadCount ?? response.notifications!.where((n) => !n.isRead).length;
        
        emit(state.copyWith(
          allNotifications: response.notifications!,
          unreadCount: unreadCount,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        // Fallback to cached notifications
        final cachedNotifications = await notificationsRepo.getCachedNotifications();
        final unreadCount = cachedNotifications.where((n) => !n.isRead).length;
        
        emit(state.copyWith(
          allNotifications: cachedNotifications,
          unreadCount: unreadCount,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      }
    } catch (error) {
      // Fallback to cached notifications
      final cachedNotifications = await notificationsRepo.getCachedNotifications();
      final unreadCount = cachedNotifications.where((n) => !n.isRead).length;
      
      emit(state.copyWith(
        allNotifications: cachedNotifications,
        unreadCount: unreadCount,
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${error.toString()}',
      ));
    }
  }

  void _onNotificationSelected(
    NotificationSelected event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(
      selectedNotification: event.notification,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onNotificationMarkedAsRead(
    NotificationMarkedAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await notificationsRepo.markAsRead(event.notificationId);
      
      if (response.success) {
        // Update local state
        final updatedNotifications = state.allNotifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        
        final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;
        
        emit(state.copyWith(
          allNotifications: updatedNotifications,
          unreadCount: newUnreadCount,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to mark notification as read',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Mark as read error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onAllNotificationsMarkedAsRead(
    AllNotificationsMarkedAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await notificationsRepo.markAllAsRead();
      
      if (response.success) {
        // Update local state
        final updatedNotifications = state.allNotifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
        
        emit(state.copyWith(
          allNotifications: updatedNotifications,
          unreadCount: 0,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to mark all notifications as read',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Mark all as read error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onNotificationDeleted(
    NotificationDeleted event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await notificationsRepo.deleteNotification(event.notificationId);
      
      if (response.success) {
        // Update local state
        final updatedNotifications = state.allNotifications
            .where((notification) => notification.id != event.notificationId)
            .toList();
        
        final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;
        
        emit(state.copyWith(
          allNotifications: updatedNotifications,
          unreadCount: newUnreadCount,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to delete notification',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Delete error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onAllNotificationsDeleted(
    AllNotificationsDeleted event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await notificationsRepo.deleteAllNotifications();
      
      if (response.success) {
        emit(state.copyWith(
          allNotifications: [],
          unreadCount: 0,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to delete all notifications',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Delete all error: ${error.toString()}',
      ));
    }
  }

  void _onNotificationsFiltered(
    NotificationsFiltered event,
    Emitter<NotificationState> emit,
  ) {
    List<Notification> filteredNotifications = state.allNotifications;
    
    // Apply filters
    if (event.type != null) {
      filteredNotifications = filteredNotifications.where((n) => n.type == event.type).toList();
    }
    
    if (event.priority != null) {
      filteredNotifications = filteredNotifications.where((n) => n.priority == event.priority).toList();
    }
    
    if (event.unreadOnly != null && event.unreadOnly!) {
      filteredNotifications = filteredNotifications.where((n) => !n.isRead).toList();
    }

    emit(state.copyWith(
      filteredNotifications: filteredNotifications,
      status: FormzSubmissionStatus.success,
      clearError: true,
    ));
  }

  Future<void> _onNotificationsRefreshed(
    NotificationsRefreshed event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Refresh notifications to get latest data
      add(const NotificationsLoaded());
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Refresh error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onNotificationSettingsUpdated(
    NotificationSettingsUpdated event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final success = await notificationsRepo.saveNotificationSettings(event.settings);
      
      if (success) {
        emit(state.copyWith(
          notificationSettings: event.settings,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Failed to update notification settings',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Settings update error: ${error.toString()}',
      ));
    }
  }
}
