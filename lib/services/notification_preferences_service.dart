import 'package:localstorage/localstorage.dart';

class NotificationPreferencesService {
  static const String _prefix = 'notification_pref_';
  
  // General notifications
  static const String pushEnabled = '${_prefix}push_enabled';
  static const String emailEnabled = '${_prefix}email_enabled';
  static const String smsEnabled = '${_prefix}sms_enabled';

  // Ride notifications
  static const String rideRequests = '${_prefix}ride_requests';
  static const String rideUpdates = '${_prefix}ride_updates';
  static const String rideReminders = '${_prefix}ride_reminders';
  static const String rideHistory = '${_prefix}ride_history';

  // Payment notifications
  static const String paymentUpdates = '${_prefix}payment_updates';
  static const String walletUpdates = '${_prefix}wallet_updates';
  static const String withdrawalUpdates = '${_prefix}withdrawal_updates';
  static const String earningsUpdates = '${_prefix}earnings_updates';

  // Document notifications
  static const String documentExpiry = '${_prefix}document_expiry';
  static const String documentStatus = '${_prefix}document_status';
  static const String documentRequired = '${_prefix}document_required';

  // Promotional notifications
  static const String promotions = '${_prefix}promotions';
  static const String referralBonus = '${_prefix}referral_bonus';
  static const String specialOffers = '${_prefix}special_offers';

  // System notifications
  static const String systemUpdates = '${_prefix}system_updates';
  static const String safetyAlerts = '${_prefix}safety_alerts';
  static const String maintenance = '${_prefix}maintenance';
  static const String offlineReminders = '${_prefix}offline_reminders';

  final Localstorage _storage;

  NotificationPreferencesService(this._storage);

  // General notifications
  bool get isPushEnabled => _getBool(pushEnabled, true);
  bool get isEmailEnabled => _getBool(emailEnabled, true);
  bool get isSmsEnabled => _getBool(smsEnabled, false);

  // Ride notifications
  bool get isRideRequestsEnabled => _getBool(rideRequests, true);
  bool get isRideUpdatesEnabled => _getBool(rideUpdates, true);
  bool get isRideRemindersEnabled => _getBool(rideReminders, true);
  bool get isRideHistoryEnabled => _getBool(rideHistory, true);

  // Payment notifications
  bool get isPaymentUpdatesEnabled => _getBool(paymentUpdates, true);
  bool get isWalletUpdatesEnabled => _getBool(walletUpdates, true);
  bool get isWithdrawalUpdatesEnabled => _getBool(withdrawalUpdates, true);
  bool get isEarningsUpdatesEnabled => _getBool(earningsUpdates, true);

  // Document notifications
  bool get isDocumentExpiryEnabled => _getBool(documentExpiry, true);
  bool get isDocumentStatusEnabled => _getBool(documentStatus, true);
  bool get isDocumentRequiredEnabled => _getBool(documentRequired, true);

  // Promotional notifications
  bool get isPromotionsEnabled => _getBool(promotions, false);
  bool get isReferralBonusEnabled => _getBool(referralBonus, true);
  bool get isSpecialOffersEnabled => _getBool(specialOffers, false);

  // System notifications
  bool get isSystemUpdatesEnabled => _getBool(systemUpdates, true);
  bool get isSafetyAlertsEnabled => _getBool(safetyAlerts, true);
  bool get isMaintenanceEnabled => _getBool(maintenance, true);
  bool get isOfflineRemindersEnabled => _getBool(offlineReminders, true);

  bool _getBool(String key, bool defaultValue) {
    final value = _storage.getString(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  // Save methods
  Future<void> setPushEnabled(bool value) => _setBool(pushEnabled, value);
  Future<void> setEmailEnabled(bool value) => _setBool(emailEnabled, value);
  Future<void> setSmsEnabled(bool value) => _setBool(smsEnabled, value);

  Future<void> setRideRequestsEnabled(bool value) => _setBool(rideRequests, value);
  Future<void> setRideUpdatesEnabled(bool value) => _setBool(rideUpdates, value);
  Future<void> setRideRemindersEnabled(bool value) => _setBool(rideReminders, value);
  Future<void> setRideHistoryEnabled(bool value) => _setBool(rideHistory, value);

  Future<void> setPaymentUpdatesEnabled(bool value) => _setBool(paymentUpdates, value);
  Future<void> setWalletUpdatesEnabled(bool value) => _setBool(walletUpdates, value);
  Future<void> setWithdrawalUpdatesEnabled(bool value) => _setBool(withdrawalUpdates, value);
  Future<void> setEarningsUpdatesEnabled(bool value) => _setBool(earningsUpdates, value);

  Future<void> setDocumentExpiryEnabled(bool value) => _setBool(documentExpiry, value);
  Future<void> setDocumentStatusEnabled(bool value) => _setBool(documentStatus, value);
  Future<void> setDocumentRequiredEnabled(bool value) => _setBool(documentRequired, value);

  Future<void> setPromotionsEnabled(bool value) => _setBool(promotions, value);
  Future<void> setReferralBonusEnabled(bool value) => _setBool(referralBonus, value);
  Future<void> setSpecialOffersEnabled(bool value) => _setBool(specialOffers, value);

  Future<void> setSystemUpdatesEnabled(bool value) => _setBool(systemUpdates, value);
  Future<void> setSafetyAlertsEnabled(bool value) => _setBool(safetyAlerts, value);
  Future<void> setMaintenanceEnabled(bool value) => _setBool(maintenance, value);
  Future<void> setOfflineRemindersEnabled(bool value) => _setBool(offlineReminders, value);

  Future<void> _setBool(String key, bool value) async {
    _storage.saveString(key, value.toString());
  }

  // Reset all preferences to default values
  Future<void> resetToDefaults() async {
    await Future.wait([
      setPushEnabled(true),
      setEmailEnabled(true),
      setSmsEnabled(false),
      setRideRequestsEnabled(true),
      setRideUpdatesEnabled(true),
      setRideRemindersEnabled(true),
      setRideHistoryEnabled(true),
      setPaymentUpdatesEnabled(true),
      setWalletUpdatesEnabled(true),
      setWithdrawalUpdatesEnabled(true),
      setEarningsUpdatesEnabled(true),
      setDocumentExpiryEnabled(true),
      setDocumentStatusEnabled(true),
      setDocumentRequiredEnabled(true),
      setPromotionsEnabled(false),
      setReferralBonusEnabled(true),
      setSpecialOffersEnabled(false),
      setSystemUpdatesEnabled(true),
      setSafetyAlertsEnabled(true),
      setMaintenanceEnabled(true),
      setOfflineRemindersEnabled(true),
    ]);
  }
} 