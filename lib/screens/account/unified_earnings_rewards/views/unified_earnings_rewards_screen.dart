import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/services/services.dart';
import 'package:driver/locator.dart';
import 'package:driver/models/booking.dart' as local_models;
import 'package:finance_repo/finance_repo.dart';
import 'package:driver/screens/account/unified_earnings_rewards/bloc/unified_earnings_rewards_bloc.dart';
import 'package:formz/formz.dart';
import 'package:rewards_repo/rewards_repo.dart' as rewards_repo;

/// Unified screen that combines earnings and rewards functionality
/// This replaces the separate EarningsScreen and RewardsScreen
class UnifiedEarningsRewardsScreen extends StatelessWidget {
  const UnifiedEarningsRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UnifiedEarningsRewardsBloc(
        unifiedService: sl<UnifiedEarningsRewardsService>(),
      )..add(const UnifiedDataInitialized()),
      child: const UnifiedEarningsRewardsView(),
    );
  }
}

class UnifiedEarningsRewardsView extends StatefulWidget {
  const UnifiedEarningsRewardsView({super.key});

  @override
  State<UnifiedEarningsRewardsView> createState() => _UnifiedEarningsRewardsViewState();
}

class _UnifiedEarningsRewardsViewState extends State<UnifiedEarningsRewardsView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      context.read<UnifiedEarningsRewardsBloc>().add(
        UnifiedTabChanged(_tabController.index),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Earnings & Rewards',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              context.read<UnifiedEarningsRewardsBloc>().add(
                const UnifiedDataRefreshed(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.cyan,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.cyan,
          tabs: const [
            Tab(text: 'Earnings'),
            Tab(text: 'Rewards'),
            Tab(text: 'Analytics'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: BlocBuilder<UnifiedEarningsRewardsBloc, UnifiedEarningsRewardsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.hasError) {
            return _buildErrorState(context, state.errorMessage!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildEarningsTab(context, state),
              _buildRewardsTab(context, state),
              _buildAnalyticsTab(context, state),
              _buildHistoryTab(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<UnifiedEarningsRewardsBloc>().add(
                  const UnifiedDataInitialized(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsTab(BuildContext context, UnifiedEarningsRewardsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UnifiedEarningsRewardsBloc>().add(
          const UnifiedDataRefreshed(),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildFilterSection(context, state),
            const SizedBox(height: 24),
            _buildWalletBalanceCard(context, state),
            const SizedBox(height: 24),
            _buildEarningsSummaryCard(context, state),
            const SizedBox(height: 24),
            _buildRewardsBonusCard(context, state),
            const SizedBox(height: 24),
            _buildQuickActionsCard(context, state),
            const SizedBox(height: 24),
            _buildCashTripsSection(context, state),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsTab(BuildContext context, UnifiedEarningsRewardsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UnifiedEarningsRewardsBloc>().add(
          const UnifiedDataRefreshed(),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildDriverLevelCard(context, state),
            const SizedBox(height: 24),
            _buildAchievementsSection(context, state),
            const SizedBox(height: 24),
            _buildChallengesSection(context, state),
            const SizedBox(height: 24),
            _buildRewardsSummaryCard(context, state),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, UnifiedEarningsRewardsState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildEarningsTrendsCard(context, state),
          const SizedBox(height: 24),
          _buildRewardsProgressCard(context, state),
          const SizedBox(height: 24),
          _buildPerformanceMetricsCard(context, state),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, UnifiedEarningsRewardsState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildTransactionHistoryCard(context, state),
          const SizedBox(height: 24),
          _buildTripHistoryCard(context, state),
          const SizedBox(height: 24),
          _buildRewardsHistoryCard(context, state),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, UnifiedEarningsRewardsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip(
              context,
              'Today',
              UnifiedFilter.today,
              state.currentFilter == UnifiedFilter.today,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip(
              context,
              'Week',
              UnifiedFilter.week,
              state.currentFilter == UnifiedFilter.week,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip(
              context,
              'Month',
              UnifiedFilter.month,
              state.currentFilter == UnifiedFilter.month,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip(
              context,
              'All',
              UnifiedFilter.all,
              state.currentFilter == UnifiedFilter.all,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    UnifiedFilter filter,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<UnifiedEarningsRewardsBloc>().add(
          UnifiedFilterChanged(filter),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyan : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.cyan : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildWalletBalanceCard(BuildContext context, UnifiedEarningsRewardsState state) {
    final walletBalance = state.walletBalance;
    if (walletBalance == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cyan, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Wallet Balance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${walletBalance.currency} ${walletBalance.availableBalance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pending: ${walletBalance.currency} ${walletBalance.pendingBalance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSummaryCard(BuildContext context, UnifiedEarningsRewardsState state) {
    final earningsData = state.earningsData;
    if (earningsData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Earnings',
                  '${earningsData.summary.currency} ${state.currentEarnings.toStringAsFixed(2)}',
                  AppColors.success,
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Bonus Earnings',
                  '${earningsData.summary.currency} ${state.totalBonusEarnings.toStringAsFixed(2)}',
                  AppColors.warning,
                  Icons.stars,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Online',
                  '${earningsData.summary.currency} ${earningsData.summary.onlineEarnings.toStringAsFixed(2)}',
                  AppColors.cyan,
                  Icons.credit_card,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Cash',
                  '${earningsData.summary.currency} ${earningsData.summary.cashEarnings.toStringAsFixed(2)}',
                  AppColors.primary,
                  Icons.money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsBonusCard(BuildContext context, UnifiedEarningsRewardsState state) {
    final combinedMetrics = state.combinedMetrics;
    if (combinedMetrics == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Rewards Bonus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Earnings Multiplier',
                  '${combinedMetrics.earningsMultiplier}x',
                  AppColors.warning,
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Driver Level',
                  state.driverLevelName,
                  AppColors.cyan,
                  Icons.emoji_events,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Streak Bonus',
                  '${state.earningsData?.summary.currency ?? '₹'} ${combinedMetrics.streakBonus.toStringAsFixed(2)}',
                  AppColors.success,
                  Icons.local_fire_department,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Achievement Bonus',
                  '${state.earningsData?.summary.currency ?? '₹'} ${combinedMetrics.achievementBonus.toStringAsFixed(2)}',
                  AppColors.primary,
                  Icons.military_tech,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverLevelCard(BuildContext context, UnifiedEarningsRewardsState state) {
    final driverProgress = state.driverProgress;
    if (driverProgress == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(state.driverLevelColor.replaceFirst('#', '0xff'))),
            Color(int.parse(state.driverLevelColor.replaceFirst('#', '0xff'))).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse(state.driverLevelColor.replaceFirst('#', '0xff'))).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                state.driverLevelName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Level ${driverProgress.currentLevel?.id ?? 'Bronze'}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.levelProgressPercentageInt}% to ${state.nextLevelName}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: state.levelProgressPercentage,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, UnifiedEarningsRewardsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Request Payout',
                  Icons.account_balance_wallet,
                  AppColors.cyan,
                  () => _showPayoutDialog(context, state),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Mark Cash Collected',
                  Icons.money,
                  AppColors.success,
                  () => _showCashCollectionDialog(context, state),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCashTripsSection(BuildContext context, UnifiedEarningsRewardsState state) {
    final cashTrips = state.cashTrips;
    if (cashTrips.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Trips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...cashTrips.take(5).map((trip) => _buildCashTripItem(context, trip, state)),
        ],
      ),
    );
  }

  Widget _buildCashTripItem(BuildContext context, local_models.Booking trip, UnifiedEarningsRewardsState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.money,
              size: 20,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.customerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(trip.fare ?? trip.amount).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          if (trip.paymentStatus == local_models.PaymentStatus.pending)
            ElevatedButton(
              onPressed: () {
                context.read<UnifiedEarningsRewardsBloc>().add(
                  UnifiedCashTripMarkedCollected(trip.id),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Mark Collected'),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, UnifiedEarningsRewardsState state) {
    final achievements = state.achievements;
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...achievements.take(5).map((achievement) => _buildAchievementItem(context, achievement)),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(BuildContext context, rewards_repo.Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: achievement.isUnlocked 
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.border.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              achievement.isUnlocked ? Icons.military_tech : Icons.lock,
              size: 20,
              color: achievement.isUnlocked ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (achievement.isUnlocked)
            Text(
              '${achievement.rewardAmount ?? 0}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChallengesSection(BuildContext context, UnifiedEarningsRewardsState state) {
    final challenges = state.activeChallenges;
    if (challenges.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Challenges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...challenges.take(3).map((challenge) => _buildChallengeItem(context, challenge)),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(BuildContext context, rewards_repo.Challenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.emoji_events,
              size: 20,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${challenge.rewardAmount ?? 0}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSummaryCard(BuildContext context, UnifiedEarningsRewardsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rewards Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Rewards',
                  '${state.totalRewards.toStringAsFixed(2)}',
                  AppColors.warning,
                  Icons.stars,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Available',
                  '${state.availableRewards.toStringAsFixed(2)}',
                  AppColors.success,
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Unlocked',
                  '${state.unlockedAchievements.length}',
                  AppColors.success,
                  Icons.military_tech,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Active',
                  '${state.activeChallenges.length}',
                  AppColors.warning,
                  Icons.emoji_events,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTrendsCard(BuildContext context, UnifiedEarningsRewardsState state) {
    final earningsData = state.earningsData;
    final combinedMetrics = state.combinedMetrics;
    
    if (earningsData == null || combinedMetrics == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Earnings trends will be displayed here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsProgressCard(BuildContext context, UnifiedEarningsRewardsState state) {
    final rewardsData = state.rewardsData;
    final combinedMetrics = state.combinedMetrics;
    
    if (rewardsData == null || combinedMetrics == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rewards Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Rewards progress will be displayed here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsCard(BuildContext context, UnifiedEarningsRewardsState state) {
    final earningsData = state.earningsData;
    final rewardsData = state.rewardsData;
    final combinedMetrics = state.combinedMetrics;
    
    if (earningsData == null || rewardsData == null || combinedMetrics == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Performance metrics will be displayed here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistoryCard(BuildContext context, UnifiedEarningsRewardsState state) {
    final transactions = state.transactions;
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...transactions.take(10).map((transaction) => _buildTransactionItem(context, transaction)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 20,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.createdAt.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripHistoryCard(BuildContext context, UnifiedEarningsRewardsState state) {
    final recentTrips = state.recentTrips;
    if (recentTrips.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Trips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...recentTrips.take(10).map((trip) => _buildTripItem(context, trip)),
        ],
      ),
    );
  }

  Widget _buildTripItem(BuildContext context, local_models.Booking trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_car,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.customerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trip.createdAt.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(trip.fare ?? trip.amount).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsHistoryCard(BuildContext context, UnifiedEarningsRewardsState state) {
    final achievements = state.unlockedAchievements;
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rewards History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...achievements.take(10).map((achievement) => _buildAchievementItem(context, achievement)),
        ],
      ),
    );
  }

  void _showPayoutDialog(BuildContext context, UnifiedEarningsRewardsState state) {
    final walletBalance = state.walletBalance;
    if (walletBalance == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Payout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available Balance: ${walletBalance.currency} ${walletBalance.availableBalance.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount to withdraw',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle payout request
              Navigator.of(context).pop();
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showCashCollectionDialog(BuildContext context, UnifiedEarningsRewardsState state) {
    final pendingCashTrips = state.cashTrips
        .where((trip) => trip.paymentStatus == local_models.PaymentStatus.pending)
        .toList();

    if (pendingCashTrips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pending cash trips'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Cash Collected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${pendingCashTrips.length} pending cash trips'),
            const SizedBox(height: 16),
            ...pendingCashTrips.take(3).map((trip) => ListTile(
              title: Text(trip.customerName),
              subtitle: Text('${(trip.fare ?? trip.amount).toStringAsFixed(2)}'),
              trailing: ElevatedButton(
                onPressed: () {
                  context.read<UnifiedEarningsRewardsBloc>().add(
                    UnifiedCashTripMarkedCollected(trip.id),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Mark Collected'),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
