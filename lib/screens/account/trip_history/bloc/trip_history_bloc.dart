import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:history_repo/history_repo.dart';
import '../data/sample_trip_data.dart';

part 'trip_history_event.dart';
part 'trip_history_state.dart';

class TripHistoryBloc extends Bloc<TripHistoryEvent, TripHistoryState> {
  TripHistoryBloc({required this.historyRepo}) : super(const TripHistoryState()) {
    on<TripHistoryLoaded>(_onTripHistoryLoaded);
    on<TripHistoryRefreshed>(_onTripHistoryRefreshed);
    on<RidesFiltered>(_onRidesFiltered);
    on<TripDetailsRequested>(_onTripDetailsRequested);
    on<DateRangeChanged>(_onDateRangeChanged);
    on<StatusFilterChanged>(_onStatusFilterChanged);
    on<StatisticsRequested>(_onStatisticsRequested);
    on<TripHistoryLoadedWithSampleData>(_onTripHistoryLoadedWithSampleData);
  }

  final HistoryRepo historyRepo;

  Future<void> _onTripHistoryLoaded(
    TripHistoryLoaded event,
    Emitter<TripHistoryState> emit,
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

  Future<void> _onTripHistoryRefreshed(
    TripHistoryRefreshed event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Refresh trip history data to get latest information
      add(const TripHistoryLoaded());
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Refresh error: ${error.toString()}',
      ));
    }
  }

  void _onRidesFiltered(
    RidesFiltered event,
    Emitter<TripHistoryState> emit,
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

  Future<void> _onTripDetailsRequested(
    TripDetailsRequested event,
    Emitter<TripHistoryState> emit,
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
          errorMessage: response.message ?? 'Failed to fetch trip details',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Trip details error: ${error.toString()}',
      ));
    }
  }

  void _onDateRangeChanged(
    DateRangeChanged event,
    Emitter<TripHistoryState> emit,
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
    Emitter<TripHistoryState> emit,
  ) {
    emit(state.copyWith(
      selectedStatus: event.status,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onStatisticsRequested(
    StatisticsRequested event,
    Emitter<TripHistoryState> emit,
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

  void _onTripHistoryLoadedWithSampleData(
    TripHistoryLoadedWithSampleData event,
    Emitter<TripHistoryState> emit,
  ) {
    final sampleTrips = SampleTripData.getSampleTrips();
    final sampleStatistics = SampleTripData.getSampleStatistics();
    
    emit(state.copyWith(
      allRides: sampleTrips,
      filteredRides: sampleTrips,
      statistics: sampleStatistics,
      status: FormzSubmissionStatus.success,
      clearError: true,
    ));
  }
}
