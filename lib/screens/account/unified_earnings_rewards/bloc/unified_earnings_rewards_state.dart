part of 'unified_earnings_rewards_bloc.dart';

/// State for unified earnings and rewards
final class UnifiedEarningsRewardsState extends Equatable {
  const UnifiedEarningsRewardsState({
    this.status = FormzSubmissionStatus.initial,
    this.unifiedData,
    this.currentFilter = UnifiedFilter.today,
    this.currentTabIndex = 0,
    this.errorMessage,
    this.payoutRequested = false,
  });

  final FormzSubmissionStatus status;
  final UnifiedEarningsRewardsData? unifiedData;
  final UnifiedFilter currentFilter;
  final int currentTabIndex;
  final String? errorMessage;
  final bool payoutRequested;

  /// Returns true if data is loading
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns true if data loaded successfully
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if there's an error
  bool get hasError => status == FormzSubmissionStatus.failure && errorMessage != null;

  /// Returns earnings data if available
  EarningsData? get earningsData => unifiedData?.earnings;

  /// Returns rewards data if available
  RewardsData? get rewardsData => unifiedData?.rewards;

  /// Returns combined metrics if available
  CombinedMetrics? get combinedMetrics => unifiedData?.combinedMetrics;

  /// Returns wallet balance if available
  WalletBalance? get walletBalance => earningsData?.summary.availableBalance != null
      ? WalletBalance(
          availableBalance: earningsData!.summary.availableBalance,
          pendingBalance: earningsData!.summary.pendingBalance,
          totalEarnings: earningsData!.summary.totalEarnings,
          totalWithdrawals: earningsData!.summary.lastPayoutAmount,
          currency: earningsData!.summary.currency,
          lastUpdated: earningsData!.summary.lastPayoutDate,
        )
      : null;

  /// Returns transactions if available
  List<Transaction> get transactions => earningsData?.transactionHistory ?? [];

  /// Returns recent trips if available
  List<local_models.Booking> get recentTrips => earningsData?.recentTrips ?? [];

  /// Returns cash trips if available
  List<local_models.Booking> get cashTrips => earningsData?.cashTrips ?? [];

  /// Returns achievements if available
  List<Achievement> get achievements => rewardsData?.achievements ?? [];

  /// Returns challenges if available
  List<Challenge> get challenges => rewardsData?.challenges ?? [];

  /// Returns driver progress if available
  DriverProgress? get driverProgress => rewardsData?.driverProgress;

  /// Returns current earnings (base + bonuses)
  double get currentEarnings => combinedMetrics?.adjustedEarnings ?? 0.0;

  /// Returns total bonus earnings
  double get totalBonusEarnings => combinedMetrics?.totalBonusEarnings ?? 0.0;

  /// Returns earnings multiplier
  double get earningsMultiplier => combinedMetrics?.earningsMultiplier ?? 1.0;

  /// Returns driver level
  DriverLevel? get driverLevel => combinedMetrics?.driverLevel;

  /// Returns next level progress
  double get nextLevelProgress => combinedMetrics?.nextLevelProgress ?? 0.0;

  /// Returns pending cash amount
  double get pendingCashAmount => cashTrips
      .where((trip) => trip.paymentStatus == local_models.PaymentStatus.pending)
      .fold(0.0, (sum, trip) => sum + trip.amount);

  /// Returns cash collected today
  double get cashCollectedToday => cashTrips
      .where((trip) => trip.paymentStatus == local_models.PaymentStatus.completed)
      .fold(0.0, (sum, trip) => sum + trip.amount);

  /// Returns unlocked achievements
  List<Achievement> get unlockedAchievements => 
      achievements.where((a) => a.isUnlocked).toList();

  /// Returns in-progress achievements
  List<Achievement> get inProgressAchievements => 
      achievements.where((a) => a.isInProgress).toList();

  /// Returns locked achievements
  List<Achievement> get lockedAchievements => 
      achievements.where((a) => a.isLocked).toList();

  /// Returns active challenges
  List<Challenge> get activeChallenges => 
      challenges.where((c) => c.isActive).toList();

  /// Returns completed challenges
  List<Challenge> get completedChallenges => 
      challenges.where((c) => c.isCompleted).toList();

  /// Returns daily challenges
  List<Challenge> get dailyChallenges => 
      challenges.where((c) => c.duration == ChallengeDuration.daily).toList();

  /// Returns weekly challenges
  List<Challenge> get weeklyChallenges => 
      challenges.where((c) => c.duration == ChallengeDuration.weekly).toList();

  /// Returns monthly challenges
  List<Challenge> get monthlyChallenges => 
      challenges.where((c) => c.duration == ChallengeDuration.monthly).toList();

  /// Returns current tab name
  String get currentTabName {
    switch (currentTabIndex) {
      case 0:
        return 'Earnings';
      case 1:
        return 'Rewards';
      case 2:
        return 'Analytics';
      case 3:
        return 'History';
      default:
        return 'Earnings';
    }
  }

  /// Returns driver level name
  String get driverLevelName => driverLevel?.name ?? 'Bronze Driver';

  /// Returns driver level color
  String get driverLevelColor => driverLevel?.color ?? '#CD7F32';

  /// Returns level progress percentage
  double get levelProgressPercentage => nextLevelProgress;

  /// Returns level progress as integer
  int get levelProgressPercentageInt => (nextLevelProgress * 100).round();

  /// Returns total trips
  int get totalTrips => earningsData?.summary.totalTrips ?? 0;

  /// Returns current rating
  double get currentRating => driverProgress?.currentRating ?? 0.0;

  /// Returns current streak
  int get currentStreak => driverProgress?.currentStreak ?? 0;

  /// Returns next level name
  String get nextLevelName => driverProgress?.nextLevel?.name ?? 'Max Level';

  /// Returns whether driver can level up
  bool get canLevelUp => driverProgress?.canLevelUp ?? false;

  /// Returns whether driver is at max level
  bool get isMaxLevel => driverProgress?.isMaxLevel ?? false;

  /// Returns total rewards
  double get totalRewards => rewardsData?.totalRewards ?? 0.0;

  /// Returns available rewards
  double get availableRewards => rewardsData?.availableRewards ?? 0.0;

  /// Creates a copy of this state with the given fields replaced
  UnifiedEarningsRewardsState copyWith({
    FormzSubmissionStatus? status,
    UnifiedEarningsRewardsData? unifiedData,
    UnifiedFilter? currentFilter,
    int? currentTabIndex,
    String? errorMessage,
    bool? payoutRequested,
    bool clearError = false,
  }) {
    return UnifiedEarningsRewardsState(
      status: status ?? this.status,
      unifiedData: unifiedData ?? this.unifiedData,
      currentFilter: currentFilter ?? this.currentFilter,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      payoutRequested: payoutRequested ?? this.payoutRequested,
    );
  }

  @override
  List<Object?> get props => [
        status,
        unifiedData,
        currentFilter,
        currentTabIndex,
        errorMessage,
        payoutRequested,
      ];

  @override
  String toString() {
    return 'UnifiedEarningsRewardsState('
        'status: $status, '
        'unifiedData: $unifiedData, '
        'currentFilter: $currentFilter, '
        'currentTabIndex: $currentTabIndex, '
        'errorMessage: $errorMessage, '
        'payoutRequested: $payoutRequested'
        ')';
  }
}
