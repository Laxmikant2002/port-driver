import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:rewards_repo/rewards_repo.dart';
import '../data/sample_rewards_data.dart';

part 'rewards_event.dart';
part 'rewards_state.dart';

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  RewardsBloc({required this.rewardsRepo}) : super(const RewardsState()) {
    on<RewardsDashboardLoaded>(_onRewardsDashboardLoaded);
    on<AchievementsLoaded>(_onAchievementsLoaded);
    on<ChallengesLoaded>(_onChallengesLoaded);
    on<DriverProgressLoaded>(_onDriverProgressLoaded);
    on<RewardsRefreshed>(_onRewardsRefreshed);
    on<AchievementRewardClaimed>(_onAchievementRewardClaimed);
    on<ChallengeRewardClaimed>(_onChallengeRewardClaimed);
    on<RewardsTabChanged>(_onRewardsTabChanged);
    on<AchievementDetailsRequested>(_onAchievementDetailsRequested);
    on<ChallengeDetailsRequested>(_onChallengeDetailsRequested);
    on<RewardsSummaryLoaded>(_onRewardsSummaryLoaded);
    on<RewardsLoadedWithSampleData>(_onRewardsLoadedWithSampleData);
  }

  final RewardsRepo rewardsRepo;

  Future<void> _onRewardsDashboardLoaded(
    RewardsDashboardLoaded event,
    Emitter<RewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Load all rewards data
      final achievementsResponse = await rewardsRepo.getAchievements();
      final challengesResponse = await rewardsRepo.getChallenges();
      final progressResponse = await rewardsRepo.getDriverProgress();
      final summaryResponse = await rewardsRepo.getRewardsSummary();
      
      if (achievementsResponse.success && challengesResponse.success && 
          progressResponse.success && summaryResponse.success) {
        
        // Cache the data
        if (achievementsResponse.achievements != null) {
          await rewardsRepo.cacheAchievements(achievementsResponse.achievements!);
        }
        if (challengesResponse.challenges != null) {
          await rewardsRepo.cacheChallenges(challengesResponse.challenges!);
        }
        if (progressResponse.driverProgress != null) {
          await rewardsRepo.cacheDriverProgress(progressResponse.driverProgress!);
        }
        
        emit(state.copyWith(
          achievements: achievementsResponse.achievements ?? [],
          challenges: challengesResponse.challenges ?? [],
          driverProgress: progressResponse.driverProgress,
          totalRewards: summaryResponse.totalRewards ?? 0.0,
          availableRewards: summaryResponse.availableRewards ?? 0.0,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        // Fallback to cached data
        final cachedAchievements = await rewardsRepo.getCachedAchievements();
        final cachedChallenges = await rewardsRepo.getCachedChallenges();
        final cachedProgress = await rewardsRepo.getCachedDriverProgress();
        
        emit(state.copyWith(
          achievements: cachedAchievements,
          challenges: cachedChallenges,
          driverProgress: cachedProgress,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      }
    } catch (error) {
      // Fallback to cached data
      final cachedAchievements = await rewardsRepo.getCachedAchievements();
      final cachedChallenges = await rewardsRepo.getCachedChallenges();
      final cachedProgress = await rewardsRepo.getCachedDriverProgress();
      
      emit(state.copyWith(
        achievements: cachedAchievements,
        challenges: cachedChallenges,
        driverProgress: cachedProgress,
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Dashboard error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onAchievementsLoaded(
    AchievementsLoaded event,
    Emitter<RewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await rewardsRepo.getAchievements(
        status: event.status,
        category: event.category,
      );
      
      if (response.success && response.achievements != null) {
        await rewardsRepo.cacheAchievements(response.achievements!);
        
        emit(state.copyWith(
          achievements: response.achievements!,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        // Fallback to cached data
        final cachedAchievements = await rewardsRepo.getCachedAchievements();
        
        emit(state.copyWith(
          achievements: cachedAchievements,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      }
    } catch (error) {
      // Fallback to cached data
      final cachedAchievements = await rewardsRepo.getCachedAchievements();
      
      emit(state.copyWith(
        achievements: cachedAchievements,
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Achievements error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onChallengesLoaded(
    ChallengesLoaded event,
    Emitter<RewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await rewardsRepo.getChallenges(
        status: event.status,
        type: event.type,
        duration: event.duration,
      );
      
      if (response.success && response.challenges != null) {
        await rewardsRepo.cacheChallenges(response.challenges!);
        
        emit(state.copyWith(
          challenges: response.challenges!,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        // Fallback to cached data
        final cachedChallenges = await rewardsRepo.getCachedChallenges();
        
        emit(state.copyWith(
          challenges: cachedChallenges,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      }
    } catch (error) {
      // Fallback to cached data
      final cachedChallenges = await rewardsRepo.getCachedChallenges();
      
      emit(state.copyWith(
        challenges: cachedChallenges,
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Challenges error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onDriverProgressLoaded(
    DriverProgressLoaded event,
    Emitter<RewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await rewardsRepo.getDriverProgress();
      
      if (response.success && response.driverProgress != null) {
        await rewardsRepo.cacheDriverProgress(response.driverProgress!);
        
        emit(state.copyWith(
          driverProgress: response.driverProgress,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        // Fallback to cached data
        final cachedProgress = await rewardsRepo.getCachedDriverProgress();
        
        emit(state.copyWith(
          driverProgress: cachedProgress,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      }
    } catch (error) {
      // Fallback to cached data
      final cachedProgress = await rewardsRepo.getCachedDriverProgress();
      
      emit(state.copyWith(
        driverProgress: cachedProgress,
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Driver progress error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onRewardsRefreshed(
    RewardsRefreshed event,
    Emitter<RewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Refresh all rewards data
      add(const RewardsDashboardLoaded());
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Refresh error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onAchievementRewardClaimed(
    AchievementRewardClaimed event,
    Emitter<RewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await rewardsRepo.claimAchievementReward(event.achievementId);
      
      if (response.success) {
        // Refresh achievements to get updated data
        add(const AchievementsLoaded());
        
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to claim achievement reward',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Claim error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onChallengeRewardClaimed(
    ChallengeRewardClaimed event,
    Emitter<RewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await rewardsRepo.claimChallengeReward(event.challengeId);
      
      if (response.success) {
        // Refresh challenges to get updated data
        add(const ChallengesLoaded());
        
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to claim challenge reward',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Claim error: ${error.toString()}',
      ));
    }
  }

  void _onRewardsTabChanged(
    RewardsTabChanged event,
    Emitter<RewardsState> emit,
  ) {
    emit(state.copyWith(
      currentTabIndex: event.tabIndex,
      tabIndex: TabIndex.dirty(event.tabIndex),
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onAchievementDetailsRequested(
    AchievementDetailsRequested event,
    Emitter<RewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await rewardsRepo.getAchievement(event.achievementId);
      
      if (response.success && response.achievements != null && response.achievements!.isNotEmpty) {
        emit(state.copyWith(
          selectedAchievement: response.achievements!.first,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to fetch achievement details',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Achievement details error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onChallengeDetailsRequested(
    ChallengeDetailsRequested event,
    Emitter<RewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await rewardsRepo.getChallenge(event.challengeId);
      
      if (response.success && response.challenges != null && response.challenges!.isNotEmpty) {
        emit(state.copyWith(
          selectedChallenge: response.challenges!.first,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to fetch challenge details',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Challenge details error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onRewardsSummaryLoaded(
    RewardsSummaryLoaded event,
    Emitter<RewardsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await rewardsRepo.getRewardsSummary();
      
      if (response.success) {
        emit(state.copyWith(
          totalRewards: response.totalRewards ?? 0.0,
          availableRewards: response.availableRewards ?? 0.0,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to fetch rewards summary',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Summary error: ${error.toString()}',
      ));
    }
  }

  void _onRewardsLoadedWithSampleData(
    RewardsLoadedWithSampleData event,
    Emitter<RewardsState> emit,
  ) {
    final sampleAchievements = SampleRewardsData.getSampleAchievements();
    final sampleChallenges = SampleRewardsData.getSampleChallenges();
    final sampleDriverProgress = SampleRewardsData.getSampleDriverProgress();
    
    emit(state.copyWith(
      achievements: sampleAchievements,
      challenges: sampleChallenges,
      driverProgress: sampleDriverProgress,
      totalRewards: 1250.0,
      availableRewards: 500.0,
      status: FormzSubmissionStatus.success,
      clearError: true,
    ));
  }
}
