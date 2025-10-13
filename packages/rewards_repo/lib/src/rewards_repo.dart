import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'models/achievement.dart';
import 'models/challenge.dart';
import 'models/reward.dart';
import 'models/rewards_response.dart';

/// Repository for managing driver rewards, achievements, and challenges
class RewardsRepo {
  const RewardsRepo({
    required this.apiClient,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Get driver achievements
  Future<RewardsResponse> getAchievements() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/driver/achievements');

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to fetch achievements',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get driver challenges
  Future<RewardsResponse> getChallenges() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/driver/challenges');

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to fetch challenges',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get driver rewards
  Future<RewardsResponse> getRewards() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/driver/rewards');

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to fetch rewards',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Claim a reward
  Future<RewardsResponse> claimReward(String rewardId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/driver/rewards/$rewardId/claim',
      );

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to claim reward',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update challenge progress
  Future<RewardsResponse> updateChallengeProgress(String challengeId, double progress) async {
    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        '/driver/challenges/$challengeId/progress',
        data: {'progress': progress},
      );

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to update challenge progress',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
