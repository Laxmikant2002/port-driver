import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notifications_repo/notifications_repo.dart' as notification_repo;
// import 'package:driver/services/notification_service.dart'; // Removed - using notifications_repo instead
import 'package:driver/routes/main_routes.dart';
import 'package:driver/routes/account_routes.dart';

/// Widget that handles displaying in-app notifications
class NotificationHandler extends StatefulWidget {
  final Widget child;
  
  const NotificationHandler({
    super.key,
    required this.child,
  });

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  // final NotificationService _notificationService = NotificationService(); // Removed - using notifications_repo instead
  StreamSubscription<notification_repo.Notification>? _notificationSubscription;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // _notificationSubscription = _notificationService.notificationStream.listen(_handleNotification); // Removed - using notifications_repo instead
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _handleNotification(notification_repo.Notification notification) {
    // Check if notification should show popup based on priority
    if (notification.priority == notification_repo.NotificationPriority.high || 
        notification.priority == notification_repo.NotificationPriority.urgent) {
      if (mounted) {
        _showNotificationPopup(notification);
      }
    }
  }

  void _showNotificationPopup(notification_repo.Notification notification) {
    // Remove existing overlay if any
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => _NotificationPopup(
        notification: notification,
        onDismiss: _dismissNotification,
        onTap: _handleNotificationTap,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after 5 seconds
    Timer(const Duration(seconds: 5), () {
      _dismissNotification();
    });
  }

  void _dismissNotification() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleNotificationTap(notification_repo.Notification notification) {
    _dismissNotification();
    
    // Navigate to appropriate screen based on notification type
    _navigateToNotificationScreen(notification);
  }

  void _navigateToNotificationScreen(notification_repo.Notification notification) {
    final context = this.context;
    
    switch (notification.type) {
      case notification_repo.NotificationType.ride:
        // Navigate to rides screen
        Navigator.pushNamed(context, MainRoutes.dashboard);
        break;
      case notification_repo.NotificationType.payment:
        // Navigate to wallet screen
        Navigator.pushNamed(context, AccountRoutes.wallet);
        break;
      case notification_repo.NotificationType.system:
        // Navigate to notification settings screen
        Navigator.pushNamed(context, AccountRoutes.notificationSettings);
        break;
      case notification_repo.NotificationType.emergency:
        // Navigate to emergency screen or show alert
        Navigator.pushNamed(context, AccountRoutes.emergency);
        break;
      case notification_repo.NotificationType.promotion:
      case notification_repo.NotificationType.maintenance:
      case notification_repo.NotificationType.support:
      default:
        // Navigate to notifications screen
        Navigator.pushNamed(context, AccountRoutes.notifications);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// In-app notification popup widget
class _NotificationPopup extends StatefulWidget {
  final notification_repo.Notification notification;
  final VoidCallback onDismiss;
  final Function(notification_repo.Notification) onTap;

  _NotificationPopup({
    super.key,
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<_NotificationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getNotificationColor(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getNotificationBorderColor(),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getNotificationIcon(),
                    color: _getNotificationIconColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.notification.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.notification.body,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onDismiss,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor() {
    switch (widget.notification.type) {
      case notification_repo.NotificationType.ride:
        return Colors.blue;
      case notification_repo.NotificationType.payment:
        return Colors.green;
      case notification_repo.NotificationType.system:
        return Colors.grey;
      case notification_repo.NotificationType.emergency:
        return Colors.red;
      case notification_repo.NotificationType.promotion:
        return Colors.orange;
      case notification_repo.NotificationType.maintenance:
        return Colors.amber;
      case notification_repo.NotificationType.support:
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  Color _getNotificationBorderColor() {
    return _getNotificationColor().withOpacity(0.3);
  }

  Color _getNotificationIconColor() {
    return Colors.white;
  }

  IconData _getNotificationIcon() {
    switch (widget.notification.type) {
      case notification_repo.NotificationType.ride:
        return Icons.directions_car;
      case notification_repo.NotificationType.payment:
        return Icons.payment;
      case notification_repo.NotificationType.system:
        return Icons.settings;
      case notification_repo.NotificationType.emergency:
        return Icons.emergency;
      case notification_repo.NotificationType.promotion:
        return Icons.local_offer;
      case notification_repo.NotificationType.maintenance:
        return Icons.build;
      case notification_repo.NotificationType.support:
        return Icons.support_agent;
      default:
        return Icons.notifications;
    }
  }
}
