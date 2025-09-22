import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notifications_repo/notifications_repo.dart';
import 'package:driver/services/notification_service.dart';

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
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<Notification>? _notificationSubscription;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _notificationSubscription = _notificationService.notificationStream.listen(_handleNotification);
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _handleNotification(Notification notification) {
    if (notification.type.shouldShowPopup && mounted) {
      _showNotificationPopup(notification);
    }
  }

  void _showNotificationPopup(Notification notification) {
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

  void _handleNotificationTap(Notification notification) {
    _dismissNotification();
    
    // Navigate to appropriate screen based on notification type
    _navigateToNotificationScreen(notification);
  }

  void _navigateToNotificationScreen(Notification notification) {
    final context = this.context;
    
    switch (notification.type) {
      case NotificationType.newRideRequest:
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingCancelled:
        // Navigate to rides screen
        Navigator.pushNamed(context, '/rides');
        break;
      case NotificationType.documentApproved:
      case NotificationType.documentRejected:
        // Navigate to documents screen
        Navigator.pushNamed(context, '/document-screen');
        break;
      case NotificationType.paymentReceived:
      case NotificationType.weeklyPayoutCredited:
        // Navigate to wallet screen
        Navigator.pushNamed(context, '/payment-overview');
        break;
      case NotificationType.vehicleAssignmentChanged:
        // Navigate to profile screen
        Navigator.pushNamed(context, '/profile');
        break;
      default:
        // Navigate to notifications screen
        Navigator.pushNamed(context, '/inbox');
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
  final Notification notification;
  final VoidCallback onDismiss;
  final Function(Notification) onTap;

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
      case NotificationType.newRideRequest:
        return Colors.blue;
      case NotificationType.bookingConfirmed:
        return Colors.green;
      case NotificationType.bookingCancelled:
        return Colors.red;
      case NotificationType.paymentReceived:
      case NotificationType.weeklyPayoutCredited:
        return Colors.green;
      case NotificationType.documentApproved:
        return Colors.green;
      case NotificationType.documentRejected:
        return Colors.red;
      case NotificationType.penaltyWarning:
      case NotificationType.suspensionWarning:
        return Colors.orange;
      case NotificationType.emergency:
        return Colors.red;
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
      case NotificationType.newRideRequest:
        return Icons.directions_car;
      case NotificationType.bookingConfirmed:
        return Icons.check_circle;
      case NotificationType.bookingCancelled:
        return Icons.cancel;
      case NotificationType.pickupReminder:
        return Icons.access_time;
      case NotificationType.documentApproved:
        return Icons.verified;
      case NotificationType.documentRejected:
        return Icons.error;
      case NotificationType.vehicleAssignmentChanged:
        return Icons.directions_car;
      case NotificationType.paymentReceived:
      case NotificationType.weeklyPayoutCredited:
        return Icons.account_balance_wallet;
      case NotificationType.appUpdate:
        return Icons.system_update;
      case NotificationType.policyUpdate:
        return Icons.policy;
      case NotificationType.workAreaUpdate:
        return Icons.location_on;
      case NotificationType.penaltyWarning:
        return Icons.warning;
      case NotificationType.suspensionWarning:
        return Icons.block;
      case NotificationType.emergency:
        return Icons.emergency;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.ride:
        return Icons.directions_car;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.maintenance:
        return Icons.build;
      case NotificationType.support:
        return Icons.support_agent;
    }
  }
}
