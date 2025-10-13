import 'package:shared_preferences/shared_preferences.dart';
import 'package:driver/services/earnings/unified_earnings_rewards_service.dart';
import 'package:driver/locator.dart';

/// Simple offline service for basic data caching
class OfflineEarningsRewardsService {
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _offlineModeKey = 'offline_mode_enabled';

  final SharedPreferences _prefs = sl<SharedPreferences>();

  /// Enable offline mode
  Future<void> enableOfflineMode() async {
    await _prefs.setBool(_offlineModeKey, true);
  }

  /// Disable offline mode
  Future<void> disableOfflineMode() async {
    await _prefs.setBool(_offlineModeKey, false);
  }

  /// Check if offline mode is enabled
  bool get isOfflineModeEnabled => _prefs.getBool(_offlineModeKey) ?? false;

  /// Get last sync timestamp
  DateTime? get lastSyncTimestamp {
    final timestamp = _prefs.getString(_lastSyncKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  /// Check if data is stale (older than 30 minutes)
  bool get isDataStale {
    final lastSync = lastSyncTimestamp;
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync).inMinutes >= 30;
  }

  /// Update last sync timestamp
  Future<void> updateLastSync() async {
    await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Get data with simple offline fallback
  Future<UnifiedEarningsRewardsData?> getDataWithOfflineFallback() async {
    try {
      // Try to get fresh data first
      final unifiedService = sl<UnifiedEarningsRewardsService>();
      final data = await unifiedService.getUnifiedData();
      
      // Update sync timestamp
      await updateLastSync();
      
      return data;
    } catch (e) {
      // If offline mode is enabled and data is not too stale, return null
      // This will show a simple offline message
      if (isOfflineModeEnabled && !isDataStale) {
        return null;
      }
      
      // Otherwise, throw the original error
      rethrow;
    }
  }
}
