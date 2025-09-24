part of 'rewards_bloc.dart';

/// Base class for all Rewards events
sealed class RewardsEvent extends Equatable {
  const RewardsEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when rewards dashboard is loaded
final class RewardsDashboardLoaded extends RewardsEvent {
  const RewardsDashboardLoaded();

  @override
  String toString() => 'RewardsDashboardLoaded()';
}

/// Event triggered when achievements are loaded
final class AchievementsLoaded extends RewardsEvent {
  const AchievementsLoaded({
    this.status,
    this.category,
  });

  final AchievementStatus? status;
  final AchievementCategory? category;

  @override
  List<Object> get props => [status ?? AchievementStatus.locked, category ?? AchievementCategory.special];

  @override
  String toString() => 'AchievementsLoaded(status: $status, category: $category)';
}

/// Event triggered when challenges are loaded
final class ChallengesLoaded extends RewardsEvent {
  const ChallengesLoaded({
    this.status,
    this.type,
    this.duration,
  });

  final ChallengeStatus? status;
  final ChallengeType? type;
  final ChallengeDuration? duration;

  @override
  List<Object> get props => [
        status ?? ChallengeStatus.locked,
        type ?? ChallengeType.trips,
        duration ?? ChallengeDuration.daily,
      ];

  @override
  String toString() => 'ChallengesLoaded(status: $status, type: $type, duration: $duration)';
}

/// Event triggered when driver progress is loaded
final class DriverProgressLoaded extends RewardsEvent {
  const DriverProgressLoaded();

  @override
  String toString() => 'DriverProgressLoaded()';
}

/// Event triggered when rewards are refreshed
final class RewardsRefreshed extends RewardsEvent {
  const RewardsRefreshed();

  @override
  String toString() => 'RewardsRefreshed()';
}

/// Event triggered when achievement reward is claimed
final class AchievementRewardClaimed extends RewardsEvent {
  const AchievementRewardClaimed(this.achievementId);

  final String achievementId;

  @override
  List<Object> get props => [achievementId];

  @override
  String toString() => 'AchievementRewardClaimed(achievementId: $achievementId)';
}

/// Event triggered when challenge reward is claimed
final class ChallengeRewardClaimed extends RewardsEvent {
  const ChallengeRewardClaimed(this.challengeId);

  final String challengeId;

  @override
  List<Object> get props => [challengeId];

  @override
  String toString() => 'ChallengeRewardClaimed(challengeId: $challengeId)';
}

/// Event triggered when tab is changed
final class RewardsTabChanged extends RewardsEvent {
  const RewardsTabChanged(this.tabIndex);

  final int tabIndex;

  @override
  List<Object> get props => [tabIndex];

  @override
  String toString() => 'RewardsTabChanged(tabIndex: $tabIndex)';
}

/// Event triggered when achievement details are requested
final class AchievementDetailsRequested extends RewardsEvent {
  const AchievementDetailsRequested(this.achievementId);

  final String achievementId;

  @override
  List<Object> get props => [achievementId];

  @override
  String toString() => 'AchievementDetailsRequested(achievementId: $achievementId)';
}

/// Event triggered when challenge details are requested
final class ChallengeDetailsRequested extends RewardsEvent {
  const ChallengeDetailsRequested(this.challengeId);

  final String challengeId;

  @override
  List<Object> get props => [challengeId];

  @override
  String toString() => 'ChallengeDetailsRequested(challengeId: $challengeId)';
}

/// Event triggered when rewards summary is loaded
final class RewardsSummaryLoaded extends RewardsEvent {
  const RewardsSummaryLoaded();

  @override
  String toString() => 'RewardsSummaryLoaded()';
}

/// Event triggered when sample data is loaded for demonstration
final class RewardsLoadedWithSampleData extends RewardsEvent {
  const RewardsLoadedWithSampleData();

  @override
  String toString() => 'RewardsLoadedWithSampleData()';
}
