part of 'rewards_bloc.dart';

enum TabValidationError { invalid }

class TabIndex extends FormzInput<int, TabValidationError> {
  const TabIndex.pure() : super.pure(0);
  const TabIndex.dirty(int value) : super.dirty(value);

  @override
  TabValidationError? validator(int value) {
    if (value < 0 || value > 2) {
      return TabValidationError.invalid;
    }
    return null;
  }
}

/// Rewards state containing achievements, challenges, and driver progress
final class RewardsState extends Equatable {
  const RewardsState({
    this.achievements = const [],
    this.challenges = const [],
    this.driverProgress,
    this.selectedAchievement,
    this.selectedChallenge,
    this.totalRewards = 0.0,
    this.availableRewards = 0.0,
    this.currentTabIndex = 0,
    this.tabIndex = const TabIndex.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final List<Achievement> achievements;
  final List<Challenge> challenges;
  final DriverProgress? driverProgress;
  final Achievement? selectedAchievement;
  final Challenge? selectedChallenge;
  final double totalRewards;
  final double availableRewards;
  final int currentTabIndex;
  final TabIndex tabIndex;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([tabIndex]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns the current error message if any
  String? get error => errorMessage;

  /// Returns true if rewards are currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

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
        return 'Daily Targets';
      case 1:
        return 'Weekly & Monthly';
      case 2:
        return 'Achievements';
      default:
        return 'Daily Targets';
    }
  }

  /// Returns driver level name
  String get driverLevelName => driverProgress?.currentLevel.name ?? 'Bronze Driver';

  /// Returns driver level color
  String get driverLevelColor => driverProgress?.currentLevel.color ?? '#FFD700';

  /// Returns level progress percentage
  double get levelProgressPercentage => driverProgress?.progressPercentage ?? 0.0;

  /// Returns level progress as integer
  int get levelProgressPercentageInt => driverProgress?.progressPercentageInt ?? 0;

  /// Returns total trips
  int get totalTrips => driverProgress?.totalTrips ?? 0;

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

  RewardsState copyWith({
    List<Achievement>? achievements,
    List<Challenge>? challenges,
    DriverProgress? driverProgress,
    Achievement? selectedAchievement,
    Challenge? selectedChallenge,
    double? totalRewards,
    double? availableRewards,
    int? currentTabIndex,
    TabIndex? tabIndex,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RewardsState(
      achievements: achievements ?? this.achievements,
      challenges: challenges ?? this.challenges,
      driverProgress: driverProgress ?? this.driverProgress,
      selectedAchievement: selectedAchievement ?? this.selectedAchievement,
      selectedChallenge: selectedChallenge ?? this.selectedChallenge,
      totalRewards: totalRewards ?? this.totalRewards,
      availableRewards: availableRewards ?? this.availableRewards,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      tabIndex: tabIndex ?? this.tabIndex,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        achievements,
        challenges,
        driverProgress,
        selectedAchievement,
        selectedChallenge,
        totalRewards,
        availableRewards,
        currentTabIndex,
        tabIndex,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'RewardsState('
        'achievements: ${achievements.length}, '
        'challenges: ${challenges.length}, '
        'driverProgress: $driverProgress, '
        'totalRewards: $totalRewards, '
        'availableRewards: $availableRewards, '
        'currentTabIndex: $currentTabIndex, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}
