import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:finance_repo/finance_repo.dart';
import 'package:driver/core/error/error_handler.dart';
import 'package:driver/core/extensions/extensions.dart';
import 'package:driver/services/earnings/unified_earnings_rewards_service.dart';
import 'package:driver/models/booking.dart' as local_models;

part 'unified_earnings_rewards_event.dart';
part 'unified_earnings_rewards_state.dart';

/// Unified BLoC that combines earnings and rewards functionality
/// This eliminates the need for separate EarningsBloc and RewardsBloc
class UnifiedEarningsRewardsBloc extends Bloc<UnifiedEarningsRewardsEvent, UnifiedEarningsRewardsState> {
  UnifiedEarningsRewardsBloc({
    required this.unifiedService,
  }) : super(const UnifiedEarningsRewardsState()) {
    on<UnifiedDataInitialized>(_onInitialized);
    on<UnifiedDataRefreshed>(_onRefreshed);
    on<UnifiedFilterChanged>(_onFilterChanged);
    on<UnifiedPayoutRequested>(_onPayoutRequested);
    on<UnifiedCashTripMarkedCollected>(_onCashTripMarkedCollected);
    on<UnifiedRewardClaimed>(_onRewardClaimed);
    on<UnifiedChallengeAccepted>(_onChallengeAccepted);
    on<UnifiedAchievementUnlocked>(_onAchievementUnlocked);
    on<UnifiedTabChanged>(_onTabChanged);
  }

  final UnifiedEarningsRewardsService unifiedService;

  Future<void> _onInitialized(
    UnifiedDataInitialized event,
    Emitter<UnifiedEarningsRewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final data = await unifiedService.getUnifiedData();
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        unifiedData: data,
        clearError: true,
      ));
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onRefreshed(
    UnifiedDataRefreshed event,
    Emitter<UnifiedEarningsRewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final data = await unifiedService.getUnifiedData(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        unifiedData: data,
        clearError: true,
      ));
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onFilterChanged(
    UnifiedFilterChanged event,
    Emitter<UnifiedEarningsRewardsState> emit,
  ) {
    emit(state.copyWith(
      currentFilter: event.filter,
      status: FormzSubmissionStatus.inProgress,
    ));

    // Calculate date range based on filter
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (event.filter) {
      case UnifiedFilter.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = now;
        break;
      case UnifiedFilter.week:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = now;
        break;
      case UnifiedFilter.month:
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        break;
      case UnifiedFilter.all:
        startDate = null;
        endDate = null;
        break;
    }

    // Refresh data with new filter
    add(UnifiedDataRefreshed(startDate: startDate, endDate: endDate));
  }

  Future<void> _onPayoutRequested(
    UnifiedPayoutRequested event,
    Emitter<UnifiedEarningsRewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final success = await unifiedService.requestPayoutWithRewards(event.amount);
      
      if (success) {
        // Refresh data to get updated balances
        add(const UnifiedDataRefreshed());
        
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          payoutRequested: true,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: ErrorHandler.handleError(Exception('Payout request failed')),
        ));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onCashTripMarkedCollected(
    UnifiedCashTripMarkedCollected event,
    Emitter<UnifiedEarningsRewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final success = await unifiedService.markCashTripCollectedWithRewards(event.tripId);
      
      if (success) {
        // Refresh data to get updated earnings and rewards
        add(const UnifiedDataRefreshed());
        
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: ErrorHandler.handleError(Exception('Failed to mark cash trip as collected')),
        ));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onRewardClaimed(
    UnifiedRewardClaimed event,
    Emitter<UnifiedEarningsRewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // This would typically involve claiming a specific reward
      // For now, we'll just refresh the data
      add(const UnifiedDataRefreshed());
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onChallengeAccepted(
    UnifiedChallengeAccepted event,
    Emitter<UnifiedEarningsRewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // This would typically involve accepting a challenge
      // For now, we'll just refresh the data
      add(const UnifiedDataRefreshed());
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onAchievementUnlocked(
    UnifiedAchievementUnlocked event,
    Emitter<UnifiedEarningsRewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // This would typically involve unlocking an achievement
      // For now, we'll just refresh the data
      add(const UnifiedDataRefreshed());
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onTabChanged(
    UnifiedTabChanged event,
    Emitter<UnifiedEarningsRewardsState> emit,
  ) {
    emit(state.copyWith(
      currentTabIndex: event.tabIndex,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }
}
