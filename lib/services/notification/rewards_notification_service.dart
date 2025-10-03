import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:rewards_repo/rewards_repo.dart' as rewards_repo;
import 'package:driver/services/services.dart';
import 'package:driver/locator.dart';

/// Service for handling push notifications related to achievements and challenges
class RewardsNotificationService {
  static final RewardsNotificationService _instance = RewardsNotificationService._internal();
  factory RewardsNotificationService() => _instance;
  RewardsNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Show achievement unlocked notification
  Future<void> showAchievementUnlockedNotification(rewards_repo.Achievement achievement) async {
    await _showNotification(
      id: achievement.id.hashCode,
      title: '🎉 Achievement Unlocked!',
      body: 'You unlocked "${achievement.name}" - ${achievement.description}',
      payload: 'achievement:${achievement.id}',
    );
  }

  /// Show challenge completed notification
  Future<void> showChallengeCompletedNotification(rewards_repo.Challenge challenge) async {
    await _showNotification(
      id: challenge.id.hashCode,
      title: '🏆 Challenge Completed!',
      body: 'You completed "${challenge.name}" - Claim your reward!',
      payload: 'challenge:${challenge.id}',
    );
  }

  /// Show level up notification
  Future<void> showLevelUpNotification(DriverLevel newLevel) async {
    await _showNotification(
      id: newLevel.id.hashCode,
      title: '⭐ Level Up!',
      body: 'Congratulations! You reached ${newLevel.name} level!',
      payload: 'levelup:${newLevel.id}',
    );
  }

  /// Show streak milestone notification
  Future<void> showStreakMilestoneNotification(int streakDays) async {
    await _showNotification(
      id: streakDays,
      title: '🔥 Streak Milestone!',
      body: 'Amazing! You have a $streakDays day streak! Keep it up!',
      payload: 'streak:$streakDays',
    );
  }

  /// Show daily challenge notification
  Future<void> showDailyChallengeNotification(rewards_repo.Challenge challenge) async {
    await _showNotification(
      id: challenge.id.hashCode + 1000, // Offset to avoid conflicts
      title: '📅 Daily Challenge',
      body: 'New daily challenge: "${challenge.name}"',
      payload: 'dailychallenge:${challenge.id}',
    );
  }

  /// Show weekly challenge notification
  Future<void> showWeeklyChallengeNotification(rewards_repo.Challenge challenge) async {
    await _showNotification(
      id: challenge.id.hashCode + 2000, // Offset to avoid conflicts
      title: '📆 Weekly Challenge',
      body: 'New weekly challenge: "${challenge.name}"',
      payload: 'weeklychallenge:${challenge.id}',
    );
  }

  /// Show earnings bonus notification
  Future<void> showEarningsBonusNotification(double bonusAmount) async {
    await _showNotification(
      id: bonusAmount.hashCode,
      title: '💰 Bonus Earned!',
      body: 'You earned a ₹${bonusAmount.toStringAsFixed(2)} bonus!',
      payload: 'bonus:$bonusAmount',
    );
  }

  /// Show payout ready notification
  Future<void> showPayoutReadyNotification(double amount) async {
    await _showNotification(
      id: amount.hashCode,
      title: '💳 Payout Ready',
      body: 'Your payout of ₹${amount.toStringAsFixed(2)} is ready!',
      payload: 'payout:$amount',
    );
  }

  /// Show reminder notification for incomplete challenges
  Future<void> showChallengeReminderNotification(rewards_repo.Challenge challenge) async {
    await _showNotification(
      id: challenge.id.hashCode + 3000, // Offset to avoid conflicts
      title: '⏰ Challenge Reminder',
      body: 'Don\'t forget: "${challenge.name}" expires soon!',
      payload: 'reminder:${challenge.id}',
    );
  }

  /// Show achievement progress notification
  Future<void> showAchievementProgressNotification(rewards_repo.Achievement achievement, double progress) async {
    final progressPercent = (progress * 100).toInt();
    await _showNotification(
      id: achievement.id.hashCode + 4000, // Offset to avoid conflicts
      title: '📈 Achievement Progress',
      body: '${achievement.name}: $progressPercent% complete!',
      payload: 'progress:${achievement.id}',
    );
  }

  /// Show leaderboard notification
  Future<void> showLeaderboardNotification(int rank) async {
    await _showNotification(
      id: rank,
      title: '🏅 Leaderboard Update',
      body: 'You are now ranked #$rank on the leaderboard!',
      payload: 'leaderboard:$rank',
    );
  }

  /// Schedule daily challenge notification
  Future<void> scheduleDailyChallengeNotification() async {
    await _notifications.zonedSchedule(
      1,
      'Daily Challenge',
      'Check out today\'s new challenge!',
      _nextInstanceOfTime(9, 0), // 9:00 AM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_challenges',
          'Daily Challenges',
          channelDescription: 'Notifications for daily challenges',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule weekly challenge notification
  Future<void> scheduleWeeklyChallengeNotification() async {
    await _notifications.zonedSchedule(
      2,
      'Weekly Challenge',
      'New weekly challenge is available!',
      _nextInstanceOfWeekday(DateTime.monday, 10, 0), // Monday 10:00 AM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_challenges',
          'Weekly Challenges',
          channelDescription: 'Notifications for weekly challenges',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule streak reminder notification
  Future<void> scheduleStreakReminderNotification() async {
    await _notifications.zonedSchedule(
      3,
      'Streak Reminder',
      'Don\'t break your streak! Complete a trip today.',
      _nextInstanceOfTime(18, 0), // 6:00 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminders',
          'Streak Reminders',
          channelDescription: 'Reminders to maintain your streak',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Show a generic notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'rewards_notifications',
      'Rewards & Achievements',
      channelDescription: 'Notifications for rewards, achievements, and challenges',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final parts = payload.split(':');
    if (parts.length != 2) return;

    final type = parts[0];
    final id = parts[1];

    switch (type) {
      case 'achievement':
        _handleAchievementTap(id);
        break;
      case 'challenge':
        _handleChallengeTap(id);
        break;
      case 'levelup':
        _handleLevelUpTap(id);
        break;
      case 'streak':
        _handleStreakTap(id);
        break;
      case 'bonus':
        _handleBonusTap(id);
        break;
      case 'payout':
        _handlePayoutTap(id);
        break;
      case 'leaderboard':
        _handleLeaderboardTap(id);
        break;
    }
  }

  void _handleAchievementTap(String achievementId) {
    // Navigate to achievements tab in unified screen
    // This would typically use a navigation service or bloc
  }

  void _handleChallengeTap(String challengeId) {
    // Navigate to challenges tab in unified screen
  }

  void _handleLevelUpTap(String levelId) {
    // Navigate to rewards tab in unified screen
  }

  void _handleStreakTap(String streakDays) {
    // Navigate to rewards tab in unified screen
  }

  void _handleBonusTap(String bonusAmount) {
    // Navigate to earnings tab in unified screen
  }

  void _handlePayoutTap(String amount) {
    // Navigate to earnings tab in unified screen
  }

  void _handleLeaderboardTap(String rank) {
    // Navigate to rewards tab in unified screen
  }

  /// Helper method to get next instance of time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Helper method to get next instance of weekday
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }
}

/// Extension to add notification capabilities to the unified service
extension RewardsNotificationExtension on UnifiedEarningsRewardsService {
  /// Check for new achievements and show notifications
  Future<void> checkAndNotifyAchievements() async {
    try {
      final rewardsData = await getRewardsData();
      final notificationService = RewardsNotificationService();
      
      // Check for newly unlocked achievements
      for (final achievement in rewardsData.achievements) {
        if (achievement.isUnlocked && (achievement.rewardAmount ?? 0) > 0) {
          await notificationService.showAchievementUnlockedNotification(achievement);
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Check for completed challenges and show notifications
  Future<void> checkAndNotifyChallenges() async {
    try {
      final rewardsData = await getRewardsData();
      final notificationService = RewardsNotificationService();
      
      // Check for completed challenges
      for (final challenge in rewardsData.challenges) {
        if (challenge.isCompleted && (challenge.rewardAmount ?? 0) > 0) {
          await notificationService.showChallengeCompletedNotification(challenge);
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Check for level up and show notification
  Future<void> checkAndNotifyLevelUp() async {
    try {
      final rewardsData = await getRewardsData();
      final notificationService = RewardsNotificationService();
      
      if (rewardsData.driverProgress?.canLevelUp == true) {
        final newLevel = rewardsData.driverProgress!.nextLevel;
        if (newLevel != null) {
          await notificationService.showLevelUpNotification(newLevel);
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Check for streak milestones and show notification
  Future<void> checkAndNotifyStreakMilestones() async {
    try {
      final rewardsData = await getRewardsData();
      final notificationService = RewardsNotificationService();
      
      final currentStreak = rewardsData.driverProgress?.currentStreak ?? 0;
      
      // Notify for streak milestones (7, 14, 30, 60, 90 days)
      if ([7, 14, 30, 60, 90].contains(currentStreak)) {
        await notificationService.showStreakMilestoneNotification(currentStreak);
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
