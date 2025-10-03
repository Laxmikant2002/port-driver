import 'package:finance_repo/finance_repo.dart';
import 'package:trip_repo/trip_repo.dart' as trip_repo;
import 'package:equatable/equatable.dart';
import 'package:driver/models/booking.dart' as local_models;
import 'earnings_service.dart';

/// Payout status enum
enum PayoutStatus {
  none,
  pending,
  processing,
  completed,
  failed,
}

/// Unified service that combines earnings and rewards functionality
/// This eliminates duplication and provides a single source of truth
class UnifiedEarningsRewardsService {
  const UnifiedEarningsRewardsService({
    required this.financeRepo,
    required this.tripRepo,
  });

  final FinanceRepo financeRepo;
  final trip_repo.TripRepo tripRepo;

  /// Get comprehensive earnings and rewards data
  Future<UnifiedEarningsRewardsData> getUnifiedData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get earnings data
      final earningsData = await _getEarningsData(startDate, endDate);
      
      // Get rewards data
      final rewardsData = await _getRewardsData();
      
      // Calculate combined metrics
      final combinedMetrics = _calculateCombinedMetrics(earningsData, rewardsData);

      return UnifiedEarningsRewardsData(
        earnings: earningsData,
        rewards: rewardsData,
        combinedMetrics: combinedMetrics,
      );
    } catch (e) {
      throw Exception('Failed to fetch unified data: ${e.toString()}');
    }
  }

  /// Get earnings data (existing functionality)
  Future<EarningsData> _getEarningsData(DateTime? startDate, DateTime? endDate) async {
    // Get earnings summary from finance repo
    final earningsResponse = await financeRepo.getEarningsSummary(
      startDate: startDate,
      endDate: endDate,
    );

    if (!earningsResponse.success) {
      throw Exception(earningsResponse.message ?? 'Failed to fetch earnings');
    }

    // Get wallet balance
    final walletResponse = await financeRepo.getWalletBalance();
    if (!walletResponse.success) {
      throw Exception(walletResponse.message ?? 'Failed to fetch wallet balance');
    }

    // Get recent transactions
    final transactionsResponse = await financeRepo.getTransactions(
      limit: 20,
      type: TransactionType.earning,
      startDate: startDate,
      endDate: endDate,
    );

    // Get cash trips
    final cashTripsResponse = await tripRepo.getCashTrips(date: endDate);

    // Convert to local models
    final cashTrips = cashTripsResponse.bookings?.map(_convertTripRepoBookingToLocal).toList() ?? [];

    // Since the backend doesn't have EarningsSummary, we'll create a simple one based on available data
    final totalEarnings = walletResponse.balance?.totalEarnings ?? 0.0;
    final onlineEarnings = totalEarnings * 0.7; // Estimate 70% online
    final cashEarnings = totalEarnings * 0.3; // Estimate 30% cash
    
    return EarningsData(
      summary: EarningsSummary(
        totalEarnings: totalEarnings,
        onlineEarnings: onlineEarnings,
        cashEarnings: cashEarnings,
        commissionPercentage: 0.0,
        totalCommission: 0.0,
        netEarnings: totalEarnings,
        totalTrips: cashTrips.length,
        currency: '₹',
        lastPayoutDate: null,
        lastPayoutAmount: 0.0,
        payoutStatus: PayoutStatus.none,
        availableBalance: walletResponse.balance?.availableBalance ?? 0.0,
        pendingBalance: walletResponse.balance?.pendingBalance ?? 0.0,
      ),
      recentTrips: cashTrips,
      cashTrips: cashTrips,
      transactionHistory: transactionsResponse.transactions ?? [],
    );
  }

  /// Get rewards data (mock implementation using finance_repo)
  Future<RewardsData> _getRewardsData() async {
    try {
      // Create mock achievements based on earnings data
      final achievements = _createMockAchievements();
      
      // Create mock challenges based on trip data
      final challenges = _createMockChallenges();
      
      // Create mock driver progress
      final driverProgress = _createMockDriverProgress();
      
      // Calculate rewards based on earnings
      final walletResponse = await financeRepo.getWalletBalance();
      final totalEarnings = walletResponse.balance?.totalEarnings ?? 0.0;
      final totalRewards = totalEarnings * 0.05; // 5% of earnings as rewards
      
      final availableRewards = totalRewards * 0.3; // 30% available for withdrawal

      return RewardsData(
        achievements: achievements,
        challenges: challenges,
        driverProgress: driverProgress,
        totalRewards: totalRewards,
        availableRewards: availableRewards,
      );
    } catch (e) {
      // Return empty rewards data if there's an error
      return const RewardsData(
        achievements: [],
        challenges: [],
        driverProgress: null,
        totalRewards: 0.0,
        availableRewards: 0.0,
      );
    }
  }

  /// Create mock achievements
  List<Achievement> _createMockAchievements() {
    return const [
      Achievement(
        id: '1',
        title: 'First Trip',
        description: 'Complete your first trip',
        isUnlocked: true,
        isInProgress: false,
        isLocked: false,
        reward: 50.0,
        progress: 100.0,
        target: 1.0,
      ),
      Achievement(
        id: '2',
        title: 'Weekend Warrior',
        description: 'Complete 10 trips in a weekend',
        isUnlocked: false,
        isInProgress: true,
        isLocked: false,
        reward: 200.0,
        progress: 6.0,
        target: 10.0,
      ),
      Achievement(
        id: '3',
        title: 'Cash Master',
        description: 'Collect ₹1000 in cash trips',
        isUnlocked: false,
        isInProgress: false,
        isLocked: true,
        reward: 100.0,
        progress: 0.0,
        target: 1000.0,
      ),
    ];
  }

  /// Create mock challenges
  List<Challenge> _createMockChallenges() {
    return const [
      Challenge(
        id: '1',
        title: 'Daily Driver',
        description: 'Complete 5 trips today',
        isActive: true,
        isCompleted: false,
        reward: 150.0,
        progress: 3.0,
        target: 5.0,
        duration: ChallengeDuration.daily,
      ),
      Challenge(
        id: '2',
        title: 'Weekend Challenge',
        description: 'Earn ₹2000 this weekend',
        isActive: true,
        isCompleted: false,
        reward: 300.0,
        progress: 1200.0,
        target: 2000.0,
        duration: ChallengeDuration.weekly,
      ),
    ];
  }

  /// Create mock driver progress
  DriverProgress _createMockDriverProgress() {
    return const DriverProgress(
      currentLevel: DriverLevel(
        id: 'bronze',
        name: 'Bronze Driver',
        color: '#CD7F32',
      ),
      nextLevel: DriverLevel(
        id: 'silver',
        name: 'Silver Driver',
        color: '#C0C0C0',
      ),
      currentRating: 4.5,
      currentStreak: 7,
      levelProgress: 65.0,
      canLevelUp: false,
      isMaxLevel: false,
    );
  }

  /// Calculate combined metrics that integrate earnings and rewards
  CombinedMetrics _calculateCombinedMetrics(EarningsData earnings, RewardsData rewards) {
    // Calculate streak bonus earnings
    final streakBonus = _calculateStreakBonus(rewards.driverProgress?.currentStreak ?? 0);
    
    // Calculate achievement bonus earnings
    final achievementBonus = _calculateAchievementBonus(rewards.achievements);
    
    // Calculate challenge bonus earnings
    final challengeBonus = _calculateChallengeBonus(rewards.challenges);
    
    // Calculate total bonus earnings
    final totalBonusEarnings = streakBonus + achievementBonus + challengeBonus;
    
    // Calculate level-based earnings multiplier
    final earningsMultiplier = _calculateEarningsMultiplier(rewards.driverProgress?.currentLevel);
    
    // Calculate adjusted earnings (base earnings * multiplier + bonuses)
    final adjustedEarnings = (earnings.summary.totalEarnings * earningsMultiplier) + totalBonusEarnings;

    return CombinedMetrics(
      streakBonus: streakBonus,
      achievementBonus: achievementBonus,
      challengeBonus: challengeBonus,
      totalBonusEarnings: totalBonusEarnings,
      earningsMultiplier: earningsMultiplier,
      adjustedEarnings: adjustedEarnings,
      driverLevel: rewards.driverProgress?.currentLevel,
      nextLevelProgress: rewards.driverProgress?.levelProgress ?? 0.0,
      levelBonus: 0.0,
      totalRewards: rewards.totalRewards,
      availableRewards: rewards.availableRewards,
      pendingRewards: rewards.totalRewards - rewards.availableRewards,
    );
  }

  /// Calculate streak bonus based on consecutive working days
  double _calculateStreakBonus(int currentStreak) {
    if (currentStreak < 3) return 0.0;
    if (currentStreak < 7) return currentStreak * 50.0;
    if (currentStreak < 15) return currentStreak * 100.0;
    return currentStreak * 200.0;
  }

  /// Calculate achievement bonus from unlocked achievements
  double _calculateAchievementBonus(List<Achievement> achievements) {
    return achievements
        .where((achievement) => achievement.isUnlocked)
        .fold(0.0, (sum, achievement) => sum + achievement.reward);
  }

  /// Calculate challenge bonus from completed challenges
  double _calculateChallengeBonus(List<Challenge> challenges) {
    return challenges
        .where((challenge) => challenge.isCompleted)
        .fold(0.0, (sum, challenge) => sum + challenge.reward);
  }

  /// Calculate earnings multiplier based on driver level
  double _calculateEarningsMultiplier(DriverLevel? level) {
    if (level == null) return 1.0;
    
    switch (level.id) {
      case 'bronze':
        return 1.0;
      case 'silver':
        return 1.1;
      case 'gold':
        return 1.2;
      case 'platinum':
        return 1.3;
      default:
        return 1.0;
    }
  }

  /// Request payout with rewards integration
  Future<bool> requestPayoutWithRewards(double amount) async {
    try {
      // Check if driver has any pending rewards
      final rewardsData = await _getRewardsData();
      final hasPendingRewards = rewardsData.availableRewards > 0;
      
      if (hasPendingRewards) {
        // Claim all pending rewards first
        await _claimAllPendingRewards(rewardsData);
      }

      // Process payout
      final payoutRequest = WithdrawalRequest(
        amount: amount,
        bankAccountId: 'default_bank_account',
        notes: 'Payout with rewards integration',
        metadata: {
          'includesRewards': hasPendingRewards,
          'totalRewardsClaimed': rewardsData.availableRewards,
        },
      );

      final response = await financeRepo.requestWithdrawal(payoutRequest);
      return response.success;
    } catch (e) {
      throw Exception('Failed to request payout: ${e.toString()}');
    }
  }

  /// Claim all pending rewards (mock implementation)
  Future<void> _claimAllPendingRewards(RewardsData rewardsData) async {
    // Since we're using mock rewards, we just simulate claiming them
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// Mark cash trip as collected with rewards integration
  Future<bool> markCashTripCollectedWithRewards(String tripId) async {
    try {
      // Mark cash trip as collected (requires both tripId and amount)
      // Note: In a real implementation, you would get the amount from the trip details
      final response = await tripRepo.markCashCollected(tripId, 0.0);
      
      if (response.success) {
        // Check if this completes any challenges
        await _checkAndUpdateChallenges();
        
        // Check if this unlocks any achievements
        await _checkAndUpdateAchievements();
        
        return true;
      }
      
      return false;
    } catch (e) {
      throw Exception('Failed to mark cash trip as collected: ${e.toString()}');
    }
  }

  /// Check and update challenges based on recent activity (mock implementation)
  Future<void> _checkAndUpdateChallenges() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  /// Check and update achievements based on recent activity (mock implementation)
  Future<void> _checkAndUpdateAchievements() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  /// Convert trip_repo Booking to local Booking model
  local_models.Booking _convertTripRepoBookingToLocal(trip_repo.Booking booking) {
    return local_models.Booking(
      id: booking.id,
      customerName: booking.passengerName ?? 'Unknown',
      customerPhone: booking.passengerPhone ?? '',
      peopleCount: 1,
      amount: booking.fare,
      status: _convertBookingStatus(booking.status),
      createdAt: booking.createdAt,
      paymentMode: booking.paymentMethod == 'cash'
          ? local_models.PaymentMode.cash
          : local_models.PaymentMode.online,
             paymentStatus: booking.status == trip_repo.BookingStatus.completed
                 ? local_models.PaymentStatus.completed
                 : local_models.PaymentStatus.pending,
      fare: booking.fare,
      distanceKm: booking.distance,
      durationMinutes: booking.estimatedDuration,
    );
  }

  /// Convert trip_repo BookingStatus to local BookingStatus
  local_models.BookingStatus _convertBookingStatus(trip_repo.BookingStatus status) {
    switch (status) {
      case trip_repo.BookingStatus.pending:
        return local_models.BookingStatus.confirmed;
      case trip_repo.BookingStatus.accepted:
        return local_models.BookingStatus.checkedIn;
      case trip_repo.BookingStatus.started:
        return local_models.BookingStatus.checkedIn;
      case trip_repo.BookingStatus.completed:
        return local_models.BookingStatus.completed;
      case trip_repo.BookingStatus.cancelled:
        return local_models.BookingStatus.cancelled;
    }
  }
}

/// Unified data model that combines earnings and rewards
class UnifiedEarningsRewardsData extends Equatable {
  const UnifiedEarningsRewardsData({
    required this.earnings,
    required this.rewards,
    required this.combinedMetrics,
  });

  final EarningsData earnings;
  final RewardsData rewards;
  final CombinedMetrics combinedMetrics;

  @override
  List<Object?> get props => [earnings, rewards, combinedMetrics];
}

/// Rewards data model
class RewardsData extends Equatable {
  const RewardsData({
    required this.achievements,
    required this.challenges,
    this.driverProgress,
    required this.totalRewards,
    required this.availableRewards,
  });

  final List<Achievement> achievements;
  final List<Challenge> challenges;
  final DriverProgress? driverProgress;
  final double totalRewards;
  final double availableRewards;

  @override
  List<Object?> get props => [achievements, challenges, driverProgress, totalRewards, availableRewards];
}

/// Combined metrics for earnings and rewards
class CombinedMetrics extends Equatable {
  const CombinedMetrics({
    required this.totalBonusEarnings,
    required this.earningsMultiplier,
    required this.streakBonus,
    required this.achievementBonus,
    required this.challengeBonus,
    required this.levelBonus,
    required this.totalRewards,
    required this.availableRewards,
    required this.pendingRewards,
    required this.adjustedEarnings,
    this.driverLevel,
    required this.nextLevelProgress,
  });

  final double totalBonusEarnings;
  final double earningsMultiplier;
  final double streakBonus;
  final double achievementBonus;
  final double challengeBonus;
  final double levelBonus;
  final double totalRewards;
  final double availableRewards;
  final double pendingRewards;
  final double adjustedEarnings;
  final DriverLevel? driverLevel;
  final double nextLevelProgress;

  @override
  List<Object?> get props => [
        totalBonusEarnings,
        earningsMultiplier,
        streakBonus,
        achievementBonus,
        challengeBonus,
        levelBonus,
        totalRewards,
        availableRewards,
        pendingRewards,
        adjustedEarnings,
        driverLevel,
        nextLevelProgress,
      ];
}

/// Achievement model for rewards system
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.isUnlocked,
    required this.isInProgress,
    required this.isLocked,
    required this.reward,
    required this.progress,
    required this.target,
  });

  final String id;
  final String title;
  final String description;
  final bool isUnlocked;
  final bool isInProgress;
  final bool isLocked;
  final double reward;
  final double progress;
  final double target;

  @override
  List<Object?> get props => [id, title, description, isUnlocked, isInProgress, isLocked, reward, progress, target];
}

/// Challenge model for rewards system
class Challenge extends Equatable {
  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    required this.isCompleted,
    required this.reward,
    required this.progress,
    required this.target,
    required this.duration,
  });

  final String id;
  final String title;
  final String description;
  final bool isActive;
  final bool isCompleted;
  final double reward;
  final double progress;
  final double target;
  final ChallengeDuration duration;

  @override
  List<Object?> get props => [id, title, description, isActive, isCompleted, reward, progress, target, duration];
}

/// Challenge duration enum
enum ChallengeDuration {
  daily,
  weekly,
  monthly,
}

/// Driver progress model
class DriverProgress extends Equatable {
  const DriverProgress({
    required this.currentLevel,
    required this.nextLevel,
    required this.currentRating,
    required this.currentStreak,
    required this.levelProgress,
    required this.canLevelUp,
    required this.isMaxLevel,
  });

  final DriverLevel currentLevel;
  final DriverLevel nextLevel;
  final double currentRating;
  final int currentStreak;
  final double levelProgress;
  final bool canLevelUp;
  final bool isMaxLevel;

  @override
  List<Object?> get props => [currentLevel, nextLevel, currentRating, currentStreak, levelProgress, canLevelUp, isMaxLevel];
}

/// Driver level model
class DriverLevel extends Equatable {
  const DriverLevel({
    required this.id,
    required this.name,
    required this.color,
  });

  final String id;
  final String name;
  final String color;

  @override
  List<Object?> get props => [id, name, color];
}

/// Earnings data model (existing)
class EarningsData extends Equatable {
  const EarningsData({
    required this.summary,
    this.recentTrips = const [],
    this.cashTrips = const [],
    this.transactionHistory = const [],
  });

  final EarningsSummary summary;
  final List<local_models.Booking> recentTrips;
  final List<local_models.Booking> cashTrips;
  final List<Transaction> transactionHistory;

  @override
  List<Object?> get props => [summary, recentTrips, cashTrips, transactionHistory];
}
