import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:driver/widgets/colors.dart';
import 'package:driver/locator.dart';
import 'package:notifications_repo/notifications_repo.dart' as notifications_repo;

import 'bloc/notification_bloc.dart';

/// Modern Notification Settings Screen
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc(notificationsRepo: sl<notifications_repo.NotificationsRepo>())
        ..add(const NotificationsLoaded()),
      child: const NotificationSettingsView(),
    );
  }
}

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsView> createState() => _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(),
              _buildTabBar(),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralSettings(),
              _buildNotificationTypes(),
              _buildAdvancedSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Notification Settings',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _showResetDialog(context);
          },
          child: Text(
            'Reset',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.cyan,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Customize Notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Manage your notification preferences',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.background,
        child: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Types'),
            Tab(text: 'Advanced'),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSettingsCard(
                title: 'General Preferences',
                icon: Icons.settings_rounded,
                children: [
                  _buildSwitchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Receive notifications on your device',
                    value: (state.notificationSettings['pushEnabled'] as bool?) ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['pushEnabled'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.volume_up_outlined,
                    title: 'Sound',
                    subtitle: 'Play sound for notifications',
                    value: (state.notificationSettings['soundEnabled'] as bool?) ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['soundEnabled'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.vibration,
                    title: 'Vibration',
                    subtitle: 'Vibrate for notifications',
                    value: (state.notificationSettings['vibrationEnabled'] as bool?) ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['vibrationEnabled'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.screen_lock_portrait,
                    title: 'Show on Lock Screen',
                    subtitle: 'Display notifications on lock screen',
                    value: (state.notificationSettings['showOnLockScreen'] as bool?) ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['showOnLockScreen'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(
                title: 'Quiet Hours',
                icon: Icons.bedtime_rounded,
                children: [
                  _buildSwitchTile(
                    icon: Icons.schedule,
                    title: 'Enable Quiet Hours',
                    subtitle: 'Silence notifications during specified hours',
                    value: (state.notificationSettings['quietHoursEnabled'] as bool?) ?? false,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['quietHoursEnabled'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  if (state.notificationSettings['quietHoursEnabled'] == true) ...[
                    _buildDivider(),
                    _buildTimeTile(
                      icon: Icons.bedtime,
                      title: 'Start Time',
                      subtitle: 'When to start silencing notifications',
                      time: (state.notificationSettings['quietHoursStart'] as String?) ?? '22:00',
                      onTap: () => _selectTime(context, 'quietHoursStart'),
                    ),
                    _buildDivider(),
                    _buildTimeTile(
                      icon: Icons.wb_sunny,
                      title: 'End Time',
                      subtitle: 'When to resume notifications',
                      time: (state.notificationSettings['quietHoursEnd'] as String?) ?? '07:00',
                      onTap: () => _selectTime(context, 'quietHoursEnd'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationTypes() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSettingsCard(
                title: 'Notification Types',
                icon: Icons.category_rounded,
                children: [
                  _buildSwitchTile(
                    icon: Icons.directions_car,
                    title: 'Ride Notifications',
                    subtitle: 'New ride requests and updates',
                    value: (state.notificationSettings['rideNotifications'] as bool?) ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['rideNotifications'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.payment,
                    title: 'Payment Notifications',
                    subtitle: 'Payment confirmations and updates',
                    value: (state.notificationSettings['paymentNotifications'] as bool?) ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['paymentNotifications'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.settings,
                    title: 'System Notifications',
                    subtitle: 'App updates and maintenance',
                    value: (state.notificationSettings['systemNotifications'] as bool?) ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['systemNotifications'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.local_offer,
                    title: 'Promotions',
                    subtitle: 'Special offers and discounts',
                    value: (state.notificationSettings['promotionNotifications'] as bool?) ?? false,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['promotionNotifications'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.warning,
                    title: 'Emergency Alerts',
                    subtitle: 'Critical safety and emergency notifications',
                    value: (state.notificationSettings['emergencyNotifications'] as bool?) ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['emergencyNotifications'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedSettings() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSettingsCard(
                title: 'Advanced Settings',
                icon: Icons.tune_rounded,
                children: [
                  _buildSwitchTile(
                    icon: Icons.email_outlined,
                    title: 'Email Notifications',
                    subtitle: 'Receive notifications via email',
                    value: (state.notificationSettings['emailEnabled'] as bool?) ?? false,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['emailEnabled'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.sms_outlined,
                    title: 'SMS Notifications',
                    subtitle: 'Receive notifications via SMS',
                    value: (state.notificationSettings['smsEnabled'] as bool?) ?? false,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['smsEnabled'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.auto_delete,
                    title: 'Auto Delete Old',
                    subtitle: 'Automatically delete notifications older than 30 days',
                    value: (state.notificationSettings['autoDeleteEnabled'] as bool?) ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['autoDeleteEnabled'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSliderTile(
                    icon: Icons.schedule,
                    title: 'Notification Frequency',
                    subtitle: 'How often to receive notifications',
                    value: ((state.notificationSettings['frequency'] as num?) ?? 1.0).toDouble(),
                    min: 0.1,
                    max: 5.0,
                    divisions: 49,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['frequency'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(
                title: 'Data & Privacy',
                icon: Icons.privacy_tip_rounded,
                children: [
                  _buildSwitchTile(
                    icon: Icons.analytics_outlined,
                    title: 'Analytics',
                    subtitle: 'Help improve notifications with usage data',
                    value: (state.notificationSettings['analyticsEnabled'] as bool?) ?? true,
                    onChanged: (value) {
                      final newSettings = Map<String, dynamic>.from(state.notificationSettings);
                      newSettings['analyticsEnabled'] = value;
                      context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.storage,
                    title: 'Storage Usage',
                    subtitle: 'Manage notification storage',
                    trailing: Text(
                      '${state.allNotifications.length} notifications',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => _showStorageDialog(context, state),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.cyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.cyan,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.cyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.cyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.cyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)}x',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: AppColors.border,
    );
  }

  void _selectTime(BuildContext context, String setting) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        final state = context.read<NotificationBloc>().state;
        final newSettings = Map<String, dynamic>.from(state.notificationSettings);
        newSettings[setting] = timeString;
        context.read<NotificationBloc>().add(NotificationSettingsUpdated(newSettings));
      }
    });
  }

  void _showStorageDialog(BuildContext context, NotificationState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Notifications: ${state.allNotifications.length}'),
            Text('Unread: ${state.unreadCount}'),
            Text('Read: ${state.allNotifications.length - state.unreadCount}'),
            const SizedBox(height: 16),
            const Text('Storage Options:'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<NotificationBloc>().add(const AllNotificationsDeleted());
              },
              child: const Text('Clear All Notifications'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all notification settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset to default settings
              final defaultSettings = {
                'pushEnabled': true,
                'soundEnabled': true,
                'vibrationEnabled': true,
                'showOnLockScreen': true,
                'quietHoursEnabled': false,
                'rideNotifications': true,
                'paymentNotifications': true,
                'systemNotifications': true,
                'promotionNotifications': false,
                'emergencyNotifications': true,
                'emailEnabled': false,
                'smsEnabled': false,
                'autoDeleteEnabled': true,
                'frequency': 1.0,
                'analyticsEnabled': true,
              };
              context.read<NotificationBloc>().add(NotificationSettingsUpdated(defaultSettings));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
