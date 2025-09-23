import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notifications_repo/notifications_repo.dart' as notification_repo;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../widgets/colors.dart';
import '../bloc/notification_bloc.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final prefs = snapshot.data!;
        final notificationsRepo = notification_repo.NotificationsRepo(prefs: prefs);
        
        return BlocProvider(
          create: (_) => NotificationBloc(notificationsRepo: notificationsRepo)..add(const NotificationsLoaded()),
          child: const NotificationView(),
        );
      },
    );
  }
}

class NotificationView extends StatelessWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              const _HeaderSection(),
              const SizedBox(height: 24),
              const Expanded(child: _NotificationListSection()),
            ],
          ),
        ),
      ),
    );
  }

}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.cyan.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Notification Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.notifications_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Header Text
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Stay updated with your latest notifications',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Mark All Read Button
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state.hasUnreadNotifications) {
                return ElevatedButton.icon(
                  onPressed: () {
                    context.read<NotificationBloc>().add(const AllNotificationsMarkedAsRead());
                  },
                  icon: const Icon(Icons.mark_email_read, size: 18),
                  label: const Text('Mark All Read'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan.withOpacity(0.1),
                    foregroundColor: AppColors.cyan,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}

class _NotificationListSection extends StatelessWidget {
  const _NotificationListSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.isSuccess) {
          if (state.allNotifications.isEmpty) {
            return _buildEmptyState();
          }
          return _buildNotificationList(context, state);
        } else if (state.isFailure) {
          return _buildErrorState(context, state);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 64,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!\nNew notifications will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, NotificationState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Notifications',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? 'Something went wrong',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(const NotificationsRefreshed());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, NotificationState state) {
    final notificationsByDate = state.notificationsByDate;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationBloc>().add(const NotificationsRefreshed());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notificationsByDate.length,
        itemBuilder: (context, index) {
          final dateEntry = notificationsByDate.entries.elementAt(index);
          final date = dateEntry.key;
          final notifications = dateEntry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(date),
              const SizedBox(height: 12),
              ...notifications.map<Widget>((notification) => _buildNotificationCard(context, notification)),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    final dateTime = DateTime.parse(date);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateText;
    if (notificationDate == today) {
      dateText = 'Today';
    } else if (notificationDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        dateText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, notification_repo.Notification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: notification.priority == notification_repo.NotificationPriority.urgent
            ? Border.all(color: AppColors.error, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Handle notification tap
          if (!notification.isRead) {
            context.read<NotificationBloc>().add(NotificationMarkedAsRead(notification.id));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(notification),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityBadge(notification.priority),
                        const SizedBox(width: 8),
                        _buildTypeBadge(notification.type),
                        const Spacer(),
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'delete':
                      context.read<NotificationBloc>().add(NotificationDeleted(notification.id));
                      break;
                    case 'mark_read':
                      if (!notification.isRead) {
                        context.read<NotificationBloc>().add(NotificationMarkedAsRead(notification.id));
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read),
                          SizedBox(width: 8),
                          Text('Mark as Read'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(notification_repo.Notification notification) {
    IconData iconData = Icons.notifications_none;
    Color iconColor = AppColors.textSecondary;
    
    switch (notification.type) {
      case notification_repo.NotificationType.ride:
        iconData = Icons.directions_car;
        iconColor = AppColors.primary;
        break;
      case notification_repo.NotificationType.payment:
        iconData = Icons.payment;
        iconColor = AppColors.success;
        break;
      case notification_repo.NotificationType.system:
        iconData = Icons.settings;
        iconColor = AppColors.textSecondary;
        break;
      case notification_repo.NotificationType.promotion:
        iconData = Icons.local_offer;
        iconColor = AppColors.warning;
        break;
      case notification_repo.NotificationType.emergency:
        iconData = Icons.warning;
        iconColor = AppColors.error;
        break;
      case notification_repo.NotificationType.maintenance:
        iconData = Icons.build;
        iconColor = AppColors.textSecondary;
        break;
      case notification_repo.NotificationType.support:
        iconData = Icons.support_agent;
        iconColor = AppColors.cyan;
        break;
      // New notification types
      case notification_repo.NotificationType.newRideRequest:
        iconData = Icons.directions_car;
        iconColor = AppColors.primary;
        break;
      case notification_repo.NotificationType.bookingConfirmed:
        iconData = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      case notification_repo.NotificationType.bookingCancelled:
        iconData = Icons.cancel;
        iconColor = AppColors.error;
        break;
      case notification_repo.NotificationType.pickupReminder:
        iconData = Icons.access_time;
        iconColor = AppColors.warning;
        break;
      case notification_repo.NotificationType.documentApproved:
        iconData = Icons.verified;
        iconColor = AppColors.success;
        break;
      case notification_repo.NotificationType.documentRejected:
        iconData = Icons.error;
        iconColor = AppColors.error;
        break;
      case notification_repo.NotificationType.vehicleAssignmentChanged:
        iconData = Icons.directions_car;
        iconColor = AppColors.primary;
        break;
      case notification_repo.NotificationType.paymentReceived:
        iconData = Icons.account_balance_wallet;
        iconColor = AppColors.success;
        break;
      case notification_repo.NotificationType.weeklyPayoutCredited:
        iconData = Icons.account_balance_wallet;
        iconColor = AppColors.success;
        break;
      case notification_repo.NotificationType.appUpdate:
        iconData = Icons.system_update;
        iconColor = AppColors.textSecondary;
        break;
      case notification_repo.NotificationType.policyUpdate:
        iconData = Icons.policy;
        iconColor = AppColors.textSecondary;
        break;
      case notification_repo.NotificationType.workAreaUpdate:
        iconData = Icons.location_on;
        iconColor = AppColors.primary;
        break;
      case notification_repo.NotificationType.penaltyWarning:
        iconData = Icons.warning;
        iconColor = AppColors.warning;
        break;
      case notification_repo.NotificationType.suspensionWarning:
        iconData = Icons.block;
        iconColor = AppColors.error;
        break;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildPriorityBadge(notification_repo.NotificationPriority priority) {
    Color color;
    switch (priority) {
      case notification_repo.NotificationPriority.low:
        color = AppColors.textTertiary;
        break;
      case notification_repo.NotificationPriority.normal:
        color = AppColors.textSecondary;
        break;
      case notification_repo.NotificationPriority.high:
        color = AppColors.warning;
        break;
      case notification_repo.NotificationPriority.urgent:
        color = AppColors.error;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(notification_repo.NotificationType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.cyan,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}