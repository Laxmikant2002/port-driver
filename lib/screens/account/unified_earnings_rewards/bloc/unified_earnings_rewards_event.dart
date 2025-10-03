part of 'unified_earnings_rewards_bloc.dart';

/// Base class for all unified earnings and rewards events
sealed class UnifiedEarningsRewardsEvent extends Equatable {
  const UnifiedEarningsRewardsEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when unified data is initialized
final class UnifiedDataInitialized extends UnifiedEarningsRewardsEvent {
  const UnifiedDataInitialized();

  @override
  String toString() => 'UnifiedDataInitialized()';
}

/// Event triggered when unified data is refreshed
final class UnifiedDataRefreshed extends UnifiedEarningsRewardsEvent {
  const UnifiedDataRefreshed({
    this.startDate,
    this.endDate,
  });

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [startDate, endDate];

  @override
  String toString() => 'UnifiedDataRefreshed(startDate: $startDate, endDate: $endDate)';
}

/// Event triggered when filter is changed
final class UnifiedFilterChanged extends UnifiedEarningsRewardsEvent {
  const UnifiedFilterChanged(this.filter);

  final UnifiedFilter filter;

  @override
  List<Object> get props => [filter];

  @override
  String toString() => 'UnifiedFilterChanged(filter: $filter)';
}

/// Event triggered when payout is requested
final class UnifiedPayoutRequested extends UnifiedEarningsRewardsEvent {
  const UnifiedPayoutRequested(this.amount);

  final double amount;

  @override
  List<Object> get props => [amount];

  @override
  String toString() => 'UnifiedPayoutRequested(amount: $amount)';
}

/// Event triggered when cash trip is marked as collected
final class UnifiedCashTripMarkedCollected extends UnifiedEarningsRewardsEvent {
  const UnifiedCashTripMarkedCollected(this.tripId);

  final String tripId;

  @override
  List<Object> get props => [tripId];

  @override
  String toString() => 'UnifiedCashTripMarkedCollected(tripId: $tripId)';
}

/// Event triggered when reward is claimed
final class UnifiedRewardClaimed extends UnifiedEarningsRewardsEvent {
  const UnifiedRewardClaimed(this.rewardId);

  final String rewardId;

  @override
  List<Object> get props => [rewardId];

  @override
  String toString() => 'UnifiedRewardClaimed(rewardId: $rewardId)';
}

/// Event triggered when challenge is accepted
final class UnifiedChallengeAccepted extends UnifiedEarningsRewardsEvent {
  const UnifiedChallengeAccepted(this.challengeId);

  final String challengeId;

  @override
  List<Object> get props => [challengeId];

  @override
  String toString() => 'UnifiedChallengeAccepted(challengeId: $challengeId)';
}

/// Event triggered when achievement is unlocked
final class UnifiedAchievementUnlocked extends UnifiedEarningsRewardsEvent {
  const UnifiedAchievementUnlocked(this.achievementId);

  final String achievementId;

  @override
  List<Object> get props => [achievementId];

  @override
  String toString() => 'UnifiedAchievementUnlocked(achievementId: $achievementId)';
}

/// Event triggered when tab is changed
final class UnifiedTabChanged extends UnifiedEarningsRewardsEvent {
  const UnifiedTabChanged(this.tabIndex);

  final int tabIndex;

  @override
  List<Object> get props => [tabIndex];

  @override
  String toString() => 'UnifiedTabChanged(tabIndex: $tabIndex)';
}

/// Filter options for unified data
enum UnifiedFilter {
  today,
  week,
  month,
  all,
}
