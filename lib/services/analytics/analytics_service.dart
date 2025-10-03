import 'package:driver/services/earnings/unified_earnings_rewards_service.dart';

/// Simple analytics service for basic metrics
class AnalyticsService {
  /// Calculate simple earnings trends
  static Map<String, double> calculateEarningsTrends(EarningsData earningsData) {
    return {
      'totalEarnings': earningsData.summary.totalEarnings,
      'onlineEarnings': earningsData.summary.onlineEarnings,
      'cashCollected': earningsData.summary.cashCollected,
      'pendingPayout': earningsData.summary.pendingPayout,
    };
  }

  /// Calculate simple rewards progress
  static Map<String, double> calculateRewardsProgress(RewardsData rewardsData) {
    final totalAchievements = rewardsData.achievements.length;
    final completedAchievements = rewardsData.achievements.where((a) => a.isUnlocked).length;
    final achievementCompletion = totalAchievements > 0 
        ? (completedAchievements / totalAchievements) * 100 
        : 0.0;

    final totalChallenges = rewardsData.challenges.length;
    final completedChallenges = rewardsData.challenges.where((c) => c.isCompleted).length;
    final challengeCompletion = totalChallenges > 0 
        ? (completedChallenges / totalChallenges) * 100 
        : 0.0;

    return {
      'achievementCompletion': achievementCompletion,
      'challengeCompletion': challengeCompletion,
      'totalRewards': rewardsData.totalRewards,
      'availableRewards': rewardsData.availableRewards,
    };
  }

  /// Calculate simple performance metrics
  static Map<String, double> calculatePerformanceMetrics(
    EarningsData earningsData,
    RewardsData rewardsData,
    CombinedMetrics combinedMetrics,
  ) {
    final totalTrips = earningsData.summary.totalTrips;
    final totalEarnings = earningsData.summary.totalEarnings;
    final earningsPerTrip = totalTrips > 0 ? totalEarnings / totalTrips : 0.0;

    return {
      'earningsPerTrip': earningsPerTrip,
      'totalTrips': totalTrips.toDouble(),
      'totalEarnings': totalEarnings,
      'rewardsImpact': totalEarnings > 0 
          ? (combinedMetrics.totalBonusEarnings / totalEarnings) * 100 
          : 0.0,
    };
  }

  /// Generate simple insights
  static List<String> generateInsights(
    EarningsData earningsData,
    RewardsData rewardsData,
    CombinedMetrics combinedMetrics,
  ) {
    final insights = <String>[];
    
    final earningsPerTrip = earningsData.summary.totalTrips > 0 
        ? earningsData.summary.totalEarnings / earningsData.summary.totalTrips 
        : 0.0;
    
    if (earningsPerTrip < 50) {
      insights.add('Consider focusing on longer trips to increase earnings per trip');
    }
    
    if (earningsData.summary.cashCollected > earningsData.summary.onlineEarnings) {
      insights.add('You have more cash trips than online trips. Consider promoting online payments');
    }
    
    final achievementCompletion = rewardsData.achievements.length > 0 
        ? rewardsData.achievements.where((a) => a.isUnlocked).length / rewardsData.achievements.length 
        : 0.0;
    
    if (achievementCompletion < 0.5) {
      insights.add('Complete more achievements to unlock bonus rewards');
    }
    
    return insights;
  }
}
