import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notifications_repo/notifications_repo.dart';
import 'package:driver/screens/account/notification/bloc/notification_bloc.dart';
import 'package:driver/widgets/colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late Map<NotificationType, bool> _notificationSettings;
  late Map<NotificationType, bool> _soundSettings;
  late Map<NotificationType, bool> _vibrationSettings;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    _notificationSettings = {
      // Booking Related
      NotificationType.newRideRequest: true,
      NotificationType.bookingConfirmed: true,
      NotificationType.bookingCancelled: true,
      NotificationType.pickupReminder: true,
      
      // Document & Profile
      NotificationType.documentApproved: true,
      NotificationType.documentRejected: true,
      NotificationType.vehicleAssignmentChanged: true,
      
      // Finance
      NotificationType.paymentReceived: true,
      NotificationType.weeklyPayoutCredited: true,
      
      // System / General
      NotificationType.system: true,
      NotificationType.appUpdate: true,
      NotificationType.policyUpdate: true,
      NotificationType.workAreaUpdate: true,
      NotificationType.penaltyWarning: true,
      NotificationType.suspensionWarning: true,
    };

    _soundSettings = {
      NotificationType.newRideRequest: true,
      NotificationType.bookingConfirmed: true,
      NotificationType.bookingCancelled: true,
      NotificationType.pickupReminder: true,
      NotificationType.paymentReceived: true,
      NotificationType.weeklyPayoutCredited: true,
      NotificationType.penaltyWarning: true,
      NotificationType.suspensionWarning: true,
    };

    _vibrationSettings = {
      NotificationType.newRideRequest: true,
      NotificationType.bookingConfirmed: true,
      NotificationType.bookingCancelled: true,
      NotificationType.pickupReminder: true,
      NotificationType.penaltyWarning: true,
      NotificationType.suspensionWarning: true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Booking Notifications'),
            _buildNotificationGroup([
              NotificationType.newRideRequest,
              NotificationType.bookingConfirmed,
              NotificationType.bookingCancelled,
              NotificationType.pickupReminder,
            ]),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Document & Profile'),
            _buildNotificationGroup([
              NotificationType.documentApproved,
              NotificationType.documentRejected,
              NotificationType.vehicleAssignmentChanged,
            ]),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Finance'),
            _buildNotificationGroup([
              NotificationType.paymentReceived,
              NotificationType.weeklyPayoutCredited,
            ]),
            
            const SizedBox(height: 24),
            _buildSectionHeader('System & General'),
            _buildNotificationGroup([
              NotificationType.system,
              NotificationType.appUpdate,
              NotificationType.policyUpdate,
              NotificationType.workAreaUpdate,
              NotificationType.penaltyWarning,
              NotificationType.suspensionWarning,
            ]),
            
            const SizedBox(height: 32),
            _buildGlobalSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildNotificationGroup(List<NotificationType> types) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: types.map((type) => _buildNotificationItem(type)).toList(),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationType type) {
    final isEnabled = _notificationSettings[type] ?? false;
    final hasSound = _soundSettings[type] ?? false;
    final hasVibration = _vibrationSettings[type] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getNotificationIcon(type),
                color: isEnabled ? AppColors.cyan : AppColors.textTertiary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isEnabled ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getNotificationDescription(type),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationSettings[type] = value;
                  });
                },
                activeColor: AppColors.cyan,
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 36),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.volume_up,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sound',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: hasSound,
                        onChanged: (value) {
                          setState(() {
                            _soundSettings[type] = value;
                          });
                        },
                        activeColor: AppColors.cyan,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.vibration,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vibration',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: hasVibration,
                        onChanged: (value) {
                          setState(() {
                            _vibrationSettings[type] = value;
                          });
                        },
                        activeColor: AppColors.cyan,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGlobalSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Global Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.notifications_off,
                color: AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Disable All Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: false, // This would be managed by state
                onChanged: (value) {
                  // Handle disable all notifications
                },
                activeColor: AppColors.cyan,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                color: AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Quiet Hours',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: false, // This would be managed by state
                onChanged: (value) {
                  // Handle quiet hours
                },
                activeColor: AppColors.cyan,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
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
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationDescription(NotificationType type) {
    switch (type) {
      case NotificationType.newRideRequest:
        return 'Get notified when a new ride request is nearby';
      case NotificationType.bookingConfirmed:
        return 'Receive confirmation when your booking is assigned';
      case NotificationType.bookingCancelled:
        return 'Get notified if a booking is cancelled';
      case NotificationType.pickupReminder:
        return 'Reminder 5 minutes before pickup time';
      case NotificationType.documentApproved:
        return 'Notification when your documents are approved';
      case NotificationType.documentRejected:
        return 'Alert when documents are rejected';
      case NotificationType.vehicleAssignmentChanged:
        return 'Notification when vehicle assignment changes';
      case NotificationType.paymentReceived:
        return 'Alert when you receive a payment';
      case NotificationType.weeklyPayoutCredited:
        return 'Notification when weekly payout is credited';
      case NotificationType.appUpdate:
        return 'Get notified about app updates';
      case NotificationType.policyUpdate:
        return 'Notifications about policy changes';
      case NotificationType.workAreaUpdate:
        return 'Updates about your work area';
      case NotificationType.penaltyWarning:
        return 'Warnings about penalties';
      case NotificationType.suspensionWarning:
        return 'Warnings about account suspension';
      default:
        return 'System notifications';
    }
  }
}
