import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:history_repo/history_repo.dart';

part 'ride_history_event.dart';
part 'ride_history_state.dart';

class RideHistoryBloc extends Bloc<RideHistoryEvent, RideHistoryState> {
  RideHistoryBloc({required this.historyRepo}) : super(const RideHistoryState()) {
    on<RideHistoryLoaded>(_onRideHistoryLoaded);
    on<RideHistoryRefreshed>(_onRideHistoryRefreshed);
    on<RidesFiltered>(_onRidesFiltered);
    on<RideDetailsRequested>(_onRideDetailsRequested);
    on<DateRangeChanged>(_onDateRangeChanged);
    on<StatusFilterChanged>(_onStatusFilterChanged);
    on<StatisticsRequested>(_onStatisticsRequested);
  }

  final HistoryRepo historyRepo;

  Future<void> _onRideHistoryLoaded(
    RideHistoryLoaded event,
    Emitter<RideHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await historyRepo.getRideHistory(
        limit: event.limit,
        offset: event.offset,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      if (response.success && response.rides != null) {
        await historyRepo.cacheRideHistory(response.rides!);
        
        emit(state.copyWith(
          allRides: response.rides!,
          filteredRides: response.rides!,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        // Fallback to cached data
        final cachedRides = await historyRepo.getCachedRideHistory();
        
        emit(state.copyWith(
          allRides: cachedRides,
          filteredRides: cachedRides,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      }
    } catch (error) {
      // Fallback to cached data
      final cachedRides = await historyRepo.getCachedRideHistory();
      
      emit(state.copyWith(
        allRides: cachedRides,
        filteredRides: cachedRides,
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onRideHistoryRefreshed(
    RideHistoryRefreshed event,
    Emitter<RideHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Refresh ride history data to get latest information
      add(const RideHistoryLoaded());
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Refresh error: ${error.toString()}',
      ));
    }
  }

  void _onRidesFiltered(
    RidesFiltered event,
    Emitter<RideHistoryState> emit,
  ) {
    List<Ride> filteredRides = state.allRides;
    
    // Apply filters
    if (event.status != null) {
      filteredRides = filteredRides.where((r) => r.status == event.status).toList();
    }
    
    if (event.startDate != null) {
      filteredRides = filteredRides.where((r) => r.createdAt.isAfter(event.startDate!)).toList();
    }
    
    if (event.endDate != null) {
      filteredRides = filteredRides.where((r) => r.createdAt.isBefore(event.endDate!)).toList();
    }

    emit(state.copyWith(
      filteredRides: filteredRides,
      selectedStatus: event.status,
      selectedStartDate: event.startDate,
      selectedEndDate: event.endDate,
      status: FormzSubmissionStatus.success,
      clearError: true,
    ));
  }

  Future<void> _onRideDetailsRequested(
    RideDetailsRequested event,
    Emitter<RideHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await historyRepo.getRide(event.rideId);
      
      if (response.success && response.singleRide != null) {
        emit(state.copyWith(
          selectedRide: response.singleRide,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to fetch ride details',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Ride details error: ${error.toString()}',
      ));
    }
  }

  void _onDateRangeChanged(
    DateRangeChanged event,
    Emitter<RideHistoryState> emit,
  ) {
    emit(state.copyWith(
      selectedStartDate: event.startDate,
      selectedEndDate: event.endDate,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onStatusFilterChanged(
    StatusFilterChanged event,
    Emitter<RideHistoryState> emit,
  ) {
    emit(state.copyWith(
      selectedStatus: event.status,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onStatisticsRequested(
    StatisticsRequested event,
    Emitter<RideHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final response = await historyRepo.getRideStatistics(
        startDate: event.startDate,
        endDate: event.endDate,
        period: event.period,
      );
      
      if (response.success && response.statistics != null) {
        await historyRepo.cacheRideStatistics(response.statistics!);
        
        emit(state.copyWith(
          statistics: response.statistics,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        // Fallback to cached statistics
        final cachedStatistics = await historyRepo.getCachedRideStatistics();
        
        emit(state.copyWith(
          statistics: cachedStatistics,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      }
    } catch (error) {
      // Fallback to cached statistics
      final cachedStatistics = await historyRepo.getCachedRideStatistics();
      
      emit(state.copyWith(
        statistics: cachedStatistics,
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Statistics error: ${error.toString()}',
      ));
    }
  }
}
