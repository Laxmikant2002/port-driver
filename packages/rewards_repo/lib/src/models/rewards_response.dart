import 'package:equatable/equatable.dart';
import 'achievement.dart';
import 'challenge.dart';
import 'driver_level.dart';

/// Rewards response model for API responses
class RewardsResponse extends Equatable {
  const RewardsResponse({
    required this.success,
    this.message,
    this.achievements,
    this.challenges,
    this.driverProgress,
    this.totalRewards,
    this.availableRewards,
  });

  final bool success;
  final String? message;
  final List<Achievement>? achievements;
  final List<Challenge>? challenges;
  final DriverProgress? driverProgress;
  final double? totalRewards;
  final double? availableRewards;

  factory RewardsResponse.fromJson(Map<String, dynamic> json) {
    return RewardsResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      achievements: json['achievements'] != null
          ? (json['achievements'] as List<dynamic>)
              .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      challenges: json['challenges'] != null
          ? (json['challenges'] as List<dynamic>)
              .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      driverProgress: json['driverProgress'] != null
          ? DriverProgress.fromJson(json['driverProgress'] as Map<String, dynamic>)
          : null,
      totalRewards: json['totalRewards'] != null 
          ? (json['totalRewards'] as num).toDouble() 
          : null,
      availableRewards: json['availableRewards'] != null 
          ? (json['availableRewards'] as num).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'achievements': achievements?.map((e) => e.toJson()).toList(),
      'challenges': challenges?.map((e) => e.toJson()).toList(),
      'driverProgress': driverProgress?.toJson(),
      'totalRewards': totalRewards,
      'availableRewards': availableRewards,
    };
  }

  RewardsResponse copyWith({
    bool? success,
    String? message,
    List<Achievement>? achievements,
    List<Challenge>? challenges,
    DriverProgress? driverProgress,
    double? totalRewards,
    double? availableRewards,
  }) {
    return RewardsResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      achievements: achievements ?? this.achievements,
      challenges: challenges ?? this.challenges,
      driverProgress: driverProgress ?? this.driverProgress,
      totalRewards: totalRewards ?? this.totalRewards,
      availableRewards: availableRewards ?? this.availableRewards,
    );
  }

  @override
  List<Object?> get props => [
        success,
        message,
        achievements,
        challenges,
        driverProgress,
        totalRewards,
        availableRewards,
      ];

  @override
  String toString() {
    return 'RewardsResponse('
        'success: $success, '
        'message: $message, '
        'achievements: ${achievements?.length}, '
        'challenges: ${challenges?.length}, '
        'driverProgress: $driverProgress'
        ')';
  }
}
