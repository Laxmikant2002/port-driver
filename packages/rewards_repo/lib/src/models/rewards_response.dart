import 'package:equatable/equatable.dart';
import 'achievement.dart';
import 'challenge.dart';
import 'reward.dart';

/// Rewards API response model
class RewardsResponse extends Equatable {
  const RewardsResponse({
    required this.success,
    this.message,
    this.achievements,
    this.challenges,
    this.rewards,
  });

  final bool success;
  final String? message;
  final List<Achievement>? achievements;
  final List<Challenge>? challenges;
  final List<Reward>? rewards;

  factory RewardsResponse.fromJson(Map<String, dynamic> json) {
    return RewardsResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      challenges: (json['challenges'] as List<dynamic>?)
          ?.map((e) => Challenge.fromJson(e as Map<String, dynamic>))
          .toList(),
      rewards: (json['rewards'] as List<dynamic>?)
          ?.map((e) => Reward.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'achievements': achievements?.map((e) => e.toJson()).toList(),
      'challenges': challenges?.map((e) => e.toJson()).toList(),
      'rewards': rewards?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [success, message, achievements, challenges, rewards];
}
