import 'package:flutter/material.dart';
import 'package:notifications_repo/notifications_repo.dart' as notification_repo;
import 'package:localstorage/localstorage.dart';
import 'package:driver/services/notification_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationPreferencesService _prefsService;
  bool _isLoading = true;

  // General notifications
  bool pushEnabled = true;
  bool emailEnabled = true;
  bool smsEnabled = false;

  // Ride notifications
  bool rideRequests = true;
  bool rideUpdates = true;
  bool rideReminders = true;
  bool rideHistory = true;

  // Payment notifications
  bool paymentUpdates = true;
  bool walletUpdates = true;
  bool withdrawalUpdates = true;
  bool earningsUpdates = true;

  // Document notifications
  bool documentExpiry = true;
  bool documentStatus = true;
  bool documentRequired = true;

  // Promotional notifications
  bool promotions = false;
  bool referralBonus = true;
  bool specialOffers = false;

  // System notifications
  bool systemUpdates = true;
  bool safetyAlerts = true;
  bool maintenance = true;
  bool offlineReminders = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final localStorage = Localstorage('driver_app');
    _prefsService = NotificationPreferencesService(localStorage);

    setState(() {
      // General notifications
      pushEnabled = _prefsService.isPushEnabled;
      emailEnabled = _prefsService.isEmailEnabled;
      smsEnabled = _prefsService.isSmsEnabled;

      // Ride notifications
      rideRequests = _prefsService.isRideRequestsEnabled;
      rideUpdates = _prefsService.isRideUpdatesEnabled;
      rideReminders = _prefsService.isRideRemindersEnabled;
      rideHistory = _prefsService.isRideHistoryEnabled;

      // Payment notifications
      paymentUpdates = _prefsService.isPaymentUpdatesEnabled;
      walletUpdates = _prefsService.isWalletUpdatesEnabled;
      withdrawalUpdates = _prefsService.isWithdrawalUpdatesEnabled;
      earningsUpdates = _prefsService.isEarningsUpdatesEnabled;

      // Document notifications
      documentExpiry = _prefsService.isDocumentExpiryEnabled;
      documentStatus = _prefsService.isDocumentStatusEnabled;
      documentRequired = _prefsService.isDocumentRequiredEnabled;

      // Promotional notifications
      promotions = _prefsService.isPromotionsEnabled;
      referralBonus = _prefsService.isReferralBonusEnabled;
      specialOffers = _prefsService.isSpecialOffersEnabled;

      // System notifications
      systemUpdates = _prefsService.isSystemUpdatesEnabled;
      safetyAlerts = _prefsService.isSafetyAlertsEnabled;
      maintenance = _prefsService.isMaintenanceEnabled;
      offlineReminders = _prefsService.isOfflineRemindersEnabled;

      _isLoading = false;
    });
  }

  Future<void> _resetToDefaults() async {
    await _prefsService.resetToDefaults();
    await _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetToDefaults,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle('General Notifications'),
          _buildNotificationSection([
            _buildNotificationSwitch(
              'Push Notifications',
              'Receive push notifications on your device',
              pushEnabled,
              (value) async {
                setState(() => pushEnabled = value);
                await _prefsService.setPushEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Email Notifications',
              'Receive notifications via email',
              emailEnabled,
              (value) async {
                setState(() => emailEnabled = value);
                await _prefsService.setEmailEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'SMS Notifications',
              'Receive notifications via SMS',
              smsEnabled,
              (value) async {
                setState(() => smsEnabled = value);
                await _prefsService.setSmsEnabled(value);
              },
            ),
          ]),
          const SizedBox(height: 32),
          _buildSectionTitle('Ride Notifications'),
          _buildNotificationSection([
            _buildNotificationSwitch(
              'Ride Requests',
              'Get notified about new ride requests',
              rideRequests,
              (value) async {
                setState(() => rideRequests = value);
                await _prefsService.setRideRequestsEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Ride Updates',
              'Get notified about ride status changes',
              rideUpdates,
              (value) async {
                setState(() => rideUpdates = value);
                await _prefsService.setRideUpdatesEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Ride Reminders',
              'Get reminders for scheduled rides',
              rideReminders,
              (value) async {
                setState(() => rideReminders = value);
                await _prefsService.setRideRemindersEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Ride History',
              'Get notifications about completed rides',
              rideHistory,
              (value) async {
                setState(() => rideHistory = value);
                await _prefsService.setRideHistoryEnabled(value);
              },
            ),
          ]),
          const SizedBox(height: 32),
          _buildSectionTitle('Payment Notifications'),
          _buildNotificationSection([
            _buildNotificationSwitch(
              'Payment Updates',
              'Get notified about payments and transactions',
              paymentUpdates,
              (value) async {
                setState(() => paymentUpdates = value);
                await _prefsService.setPaymentUpdatesEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Wallet Updates',
              'Get notified about wallet balance changes',
              walletUpdates,
              (value) async {
                setState(() => walletUpdates = value);
                await _prefsService.setWalletUpdatesEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Withdrawal Updates',
              'Get notified about withdrawal status',
              withdrawalUpdates,
              (value) async {
                setState(() => withdrawalUpdates = value);
                await _prefsService.setWithdrawalUpdatesEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Earnings Updates',
              'Get notified about your earnings',
              earningsUpdates,
              (value) async {
                setState(() => earningsUpdates = value);
                await _prefsService.setEarningsUpdatesEnabled(value);
              },
            ),
          ]),
          const SizedBox(height: 32),
          _buildSectionTitle('Document Notifications'),
          _buildNotificationSection([
            _buildNotificationSwitch(
              'Document Expiry',
              'Get notified before documents expire',
              documentExpiry,
              (value) async {
                setState(() => documentExpiry = value);
                await _prefsService.setDocumentExpiryEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Document Status',
              'Get notified about document approval status',
              documentStatus,
              (value) async {
                setState(() => documentStatus = value);
                await _prefsService.setDocumentStatusEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Document Required',
              'Get notified when new documents are required',
              documentRequired,
              (value) async {
                setState(() => documentRequired = value);
                await _prefsService.setDocumentRequiredEnabled(value);
              },
            ),
          ]),
          const SizedBox(height: 32),
          _buildSectionTitle('Promotional Notifications'),
          _buildNotificationSection([
            _buildNotificationSwitch(
              'Promotions',
              'Receive promotional offers and discounts',
              promotions,
              (value) async {
                setState(() => promotions = value);
                await _prefsService.setPromotionsEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Referral Bonus',
              'Get notified about referral earnings',
              referralBonus,
              (value) async {
                setState(() => referralBonus = value);
                await _prefsService.setReferralBonusEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Special Offers',
              'Receive special offers and deals',
              specialOffers,
              (value) async {
                setState(() => specialOffers = value);
                await _prefsService.setSpecialOffersEnabled(value);
              },
            ),
          ]),
          const SizedBox(height: 32),
          _buildSectionTitle('System Notifications'),
          _buildNotificationSection([
            _buildNotificationSwitch(
              'System Updates',
              'Get notified about app updates and maintenance',
              systemUpdates,
              (value) async {
                setState(() => systemUpdates = value);
                await _prefsService.setSystemUpdatesEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Safety Alerts',
              'Get important safety notifications',
              safetyAlerts,
              (value) async {
                setState(() => safetyAlerts = value);
                await _prefsService.setSafetyAlertsEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Maintenance',
              'Get notified about system maintenance',
              maintenance,
              (value) async {
                setState(() => maintenance = value);
                await _prefsService.setMaintenanceEnabled(value);
              },
            ),
            _buildNotificationSwitch(
              'Offline Reminders',
              'Get reminders when you\'ve been offline',
              offlineReminders,
              (value) async {
                setState(() => offlineReminders = value);
                await _prefsService.setOfflineRemindersEnabled(value);
              },
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotificationSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Divider(color: Colors.grey.shade200),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.black,
    );
  }
}