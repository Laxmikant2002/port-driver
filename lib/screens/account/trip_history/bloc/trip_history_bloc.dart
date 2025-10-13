import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:trip_repo/trip_repo.dart' as trip_repo;
import 'package:finance_repo/finance_repo.dart';
import 'package:driver/models/booking.dart' as local_models;
import 'package:driver/services/trip_history/trip_history_service.dart';

part 'trip_history_event.dart';
part 'trip_history_state.dart';

class TripHistoryBloc extends Bloc<TripHistoryEvent, TripHistoryState> {
  TripHistoryBloc({
    required this.tripHistoryService,
  }) : super(const TripHistoryState()) {
    on<TripHistoryInitialized>(_onTripHistoryInitialized);
    on<TripHistoryRefreshed>(_onTripHistoryRefreshed);
    on<TripHistoryLoadMore>(_onTripHistoryLoadMore);
    on<TripHistoryFilterChanged>(_onTripHistoryFilterChanged);
    on<TripDetailsRequested>(_onTripDetailsRequested);
    on<TripStatisticsRequested>(_onTripStatisticsRequested);
    on<TripCashCollected>(_onTripCashCollected);
    on<TripHistorySearchPerformed>(_onTripHistorySearchPerformed);
  }

  final TripHistoryService tripHistoryService;

  Future<void> _onTripHistoryInitialized(
    TripHistoryInitialized event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final tripHistoryData = await tripHistoryService.getTripHistory(
        limit: event.limit,
        offset: event.offset,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      emit(state.copyWith(
        tripHistoryData: tripHistoryData,
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to load trip history: ${error.toString()}',
      ));
    }
  }

  Future<void> _onTripHistoryRefreshed(
    TripHistoryRefreshed event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final currentFilter = state.currentFilter;
      final tripHistoryData = await tripHistoryService.getTripHistory(
        limit: 20,
        offset: 0,
        status: currentFilter?.status,
        startDate: currentFilter?.startDate,
        endDate: currentFilter?.endDate,
      );
      
      emit(state.copyWith(
        tripHistoryData: tripHistoryData,
        status: FormzSubmissionStatus.success,
        clearError: true,
        hasReachedMax: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to refresh trip history: ${error.toString()}',
      ));
    }
  }

  Future<void> _onTripHistoryLoadMore(
    TripHistoryLoadMore event,
    Emitter<TripHistoryState> emit,
  ) async {
    if (state.isLoadingMore || state.hasReachedMax) return;
    
    emit(state.copyWith(isLoadingMore: true));
    
    try {
      final currentData = state.tripHistoryData;
      if (currentData == null) return;
      
      final currentFilter = state.currentFilter;
      final newData = await tripHistoryService.getTripHistory(
        limit: 20,
        offset: currentData.bookings.length,
        status: currentFilter?.status,
        startDate: currentFilter?.startDate,
        endDate: currentFilter?.endDate,
      );
      
      // Combine existing and new data
      final combinedBookings = [...currentData.bookings, ...newData.bookings];
      final combinedTransactions = [...currentData.transactions, ...newData.transactions];
      
      final updatedData = TripHistoryData(
        bookings: combinedBookings,
        transactions: combinedTransactions,
        statistics: newData.statistics,
        hasMore: newData.hasMore,
        totalCount: newData.totalCount,
      );
      
      emit(state.copyWith(
        tripHistoryData: updatedData,
        isLoadingMore: false,
        hasReachedMax: !newData.hasMore,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more trips: ${error.toString()}',
      ));
    }
  }

  Future<void> _onTripHistoryFilterChanged(
    TripHistoryFilterChanged event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final filter = TripHistoryFilter(
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
        paymentMode: event.paymentMode,
      );
      
      final tripHistoryData = await tripHistoryService.getTripHistory(
        limit: 20,
        offset: 0,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      emit(state.copyWith(
        tripHistoryData: tripHistoryData,
        currentFilter: filter,
        status: FormzSubmissionStatus.success,
        clearError: true,
        hasReachedMax: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to apply filters: ${error.toString()}',
      ));
    }
  }

  Future<void> _onTripDetailsRequested(
    TripDetailsRequested event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final tripDetails = await tripHistoryService.getTripDetails(event.tripId);
      
      emit(state.copyWith(
        selectedTrip: tripDetails,
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to fetch trip details: ${error.toString()}',
      ));
    }
  }

  Future<void> _onTripStatisticsRequested(
    TripStatisticsRequested event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final statistics = await tripHistoryService.getTripStatistics(
        startDate: event.startDate,
        endDate: event.endDate,
        period: event.period,
      );
      
      emit(state.copyWith(
        statistics: statistics,
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to fetch statistics: ${error.toString()}',
      ));
    }
  }

  Future<void> _onTripCashCollected(
    TripCashCollected event,
    Emitter<TripHistoryState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Mark cash as collected in trip_repo
      await tripHistoryService.tripRepo.markCashCollected(event.tripId, event.amount);
      
      // Refresh the trip history to get updated data
      add(const TripHistoryRefreshed());
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to mark cash as collected: ${error.toString()}',
      ));
    }
  }

  void _onTripHistorySearchPerformed(
    TripHistorySearchPerformed event,
    Emitter<TripHistoryState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: event.query,
      status: FormzSubmissionStatus.success,
      clearError: true,
    ));
  }
}
