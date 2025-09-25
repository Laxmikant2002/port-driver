import 'dart:convert';
import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'models/achievement.dart';
import 'models/challenge.dart';
import 'models/driver_level.dart';
import 'models/rewards_response.dart';

/// Rewards repository for managing driver rewards, achievements, and challenges
class RewardsRepo {
  const RewardsRepo({
    required this.baseUrl,
    required this.apiClient,
    required this.localStorage,
  });

  final String baseUrl;
  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Get all achievements
  Future<RewardsResponse> getAchievements({
    AchievementStatus? status,
    AchievementCategory? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status.value;
      if (category != null) queryParams['category'] = category.value;

      final response = await apiClient.get<Map<String, dynamic>>(
        '/rewards/achievements',
        queryParameters: queryParams,
      );

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

  /// Get all challenges
  Future<RewardsResponse> getChallenges({
    ChallengeStatus? status,
    ChallengeType? type,
    ChallengeDuration? duration,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status.value;
      if (type != null) queryParams['type'] = type.value;
      if (duration != null) queryParams['duration'] = duration.value;

      final response = await apiClient.get<Map<String, dynamic>>(
        '/rewards/challenges',
        queryParameters: queryParams,
      );

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

  /// Get driver progress and level information
  Future<RewardsResponse> getDriverProgress() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/rewards/driver-progress',
      );

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to fetch driver progress',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get specific achievement by ID
  Future<RewardsResponse> getAchievement(String achievementId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/rewards/achievements/$achievementId',
      );

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to fetch achievement details',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get specific challenge by ID
  Future<RewardsResponse> getChallenge(String challengeId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/rewards/challenges/$challengeId',
      );

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to fetch challenge details',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Claim achievement reward
  Future<RewardsResponse> claimAchievementReward(String achievementId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/rewards/achievements/$achievementId/claim',
      );

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to claim achievement reward',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Claim challenge reward
  Future<RewardsResponse> claimChallengeReward(String challengeId) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/rewards/challenges/$challengeId/claim',
      );

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to claim challenge reward',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get rewards summary
  Future<RewardsResponse> getRewardsSummary() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/rewards/summary',
      );

      if (response is DataSuccess) {
        return RewardsResponse.fromJson(response.data!);
      } else {
        return RewardsResponse(
          success: false,
          message: 'Failed to fetch rewards summary',
        );
      }
    } catch (e) {
      return RewardsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get cached achievements
  Future<List<Achievement>> getCachedAchievements() async {
    try {
      final cached = localStorage.getString('cached_achievements');
      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        return jsonList.map((json) => Achievement.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Cache achievements
  Future<void> cacheAchievements(List<Achievement> achievements) async {
    try {
      final jsonList = achievements.map((a) => a.toJson()).toList();
      localStorage.saveString('cached_achievements', jsonEncode(jsonList));
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get cached challenges
  Future<List<Challenge>> getCachedChallenges() async {
    try {
      final cached = localStorage.getString('cached_challenges');
      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        return jsonList.map((json) => Challenge.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Cache challenges
  Future<void> cacheChallenges(List<Challenge> challenges) async {
    try {
      final jsonList = challenges.map((c) => c.toJson()).toList();
      localStorage.saveString('cached_challenges', jsonEncode(jsonList));
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get cached driver progress
  Future<DriverProgress?> getCachedDriverProgress() async {
    try {
      final cached = localStorage.getString('cached_driver_progress');
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return DriverProgress.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache driver progress
  Future<void> cacheDriverProgress(DriverProgress progress) async {
    try {
      localStorage.saveString('cached_driver_progress', jsonEncode(progress.toJson()));
    } catch (e) {
      // Handle error silently
    }
  }
}
