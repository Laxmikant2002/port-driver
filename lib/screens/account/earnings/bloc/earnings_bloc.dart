import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:finance_repo/finance_repo.dart' hide PaymentStatus;
import 'package:trip_repo/trip_repo.dart' hide Booking;
import 'package:driver/models/driver_earnings.dart';
import 'package:driver/models/booking.dart';
import 'package:equatable/equatable.dart';

part 'earnings_event.dart';
part 'earnings_state.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  EarningsBloc({
    required this.financeRepo,
    required this.bookingRepo,
  }) : super(const EarningsState()) {
    on<EarningsInitialized>(_onInitialized);
    on<EarningsRefreshed>(_onRefreshed);
    on<EarningsFilterChanged>(_onFilterChanged);
    on<PayoutRequested>(_onPayoutRequested);
    on<CashTripMarkedCollected>(_onCashTripMarkedCollected);
    on<TripDetailsRequested>(_onTripDetailsRequested);
  }

  final FinanceRepo financeRepo;
  final TripRepo bookingRepo;

  Future<void> _onInitialized(
    EarningsInitialized event,
    Emitter<EarningsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Load earnings data
      await _loadEarningsData(emit);
      
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to load earnings: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshed(
    EarningsRefreshed event,
    Emitter<EarningsState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));

    try {
      await _loadEarningsData(emit);
      emit(state.copyWith(isRefreshing: false));
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh earnings: ${e.toString()}',
      ));
    }
  }

  Future<void> _onFilterChanged(
    EarningsFilterChanged event,
    Emitter<EarningsState> emit,
  ) async {
    emit(state.copyWith(
      currentFilter: EarningsFilter.custom,
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
      status: FormzSubmissionStatus.inProgress,
    ));

    try {
      // Load filtered earnings data
      final filteredEarnings = await _loadFilteredEarnings(
        event.startDate,
        event.endDate,
      );
      
      emit(state.copyWith(
        todayEarnings: filteredEarnings,
        status: FormzSubmissionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to load filtered earnings: ${e.toString()}',
      ));
    }
  }

  Future<void> _onPayoutRequested(
    PayoutRequested event,
    Emitter<EarningsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Request payout through finance repo
      // TODO: Implement requestPayout method in FinanceRepo
      // final response = await financeRepo.requestPayout(amount: event.amount);
      
      // Mock successful payout request for now
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // Refresh earnings data after successful payout request
      await _loadEarningsData(emit);
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to request payout: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCashTripMarkedCollected(
    CashTripMarkedCollected event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      // Mark trip as cash collected
      // TODO: Implement markCashCollected method in BookingRepo
      // await bookingRepo.markCashCollected(event.tripId, event.amount);
      
      // Mock successful cash collection for now
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      // Refresh data
      await _loadEarningsData(emit);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to mark cash collected: ${e.toString()}',
      ));
    }
  }

  Future<void> _onTripDetailsRequested(
    TripDetailsRequested event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      // Load trip details - implementation depends on booking repo
      // This would navigate to trip details or show a modal
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load trip details: ${e.toString()}',
      ));
    }
  }

  /// Load all earnings data
  Future<void> _loadEarningsData(Emitter<EarningsState> emit) async {
    final now = DateTime.now();
    
    // Load today's earnings
    final todayEarnings = await _loadEarningsForDate(now);
    
    // Load week's earnings
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEarnings = await _loadEarningsForDateRange(weekStart, now);
    
    // Load month's earnings
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEarnings = await _loadEarningsForDateRange(monthStart, now);
    
    // Load recent trips
    final recentTrips = await _loadRecentTrips();
    
    // Load cash trips
    final cashTrips = await _loadCashTrips();

    emit(state.copyWith(
      todayEarnings: todayEarnings,
      weekEarnings: weekEarnings,
      monthEarnings: monthEarnings,
      recentTrips: recentTrips,
      cashTrips: cashTrips,
    ));
  }

  /// Load earnings for a specific date
  Future<DriverEarnings> _loadEarningsForDate(DateTime date) async {
    // Mock implementation - replace with actual API call
    return DriverEarnings(
      driverId: 'driver123',
      date: date,
      totalTrips: 8,
      onlineTrips: 6,
      cashTrips: 2,
      totalFare: 2400.0,
      totalCommission: 240.0,
      netEarnings: 2160.0,
      cashCollected: 450.0,
      pendingDue: 150.0,
      onlineEarnings: 1710.0,
      payoutStatus: PayoutStatus.pending,
    );
  }

  /// Load earnings for date range
  Future<DriverEarnings> _loadEarningsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Mock implementation - replace with actual API call
    final days = endDate.difference(startDate).inDays + 1;
    return DriverEarnings(
      driverId: 'driver123',
      date: endDate,
      totalTrips: 8 * days,
      onlineTrips: 6 * days,
      cashTrips: 2 * days,
      totalFare: 2400.0 * days,
      totalCommission: 240.0 * days,
      netEarnings: 2160.0 * days,
      cashCollected: 450.0 * days,
      pendingDue: 150.0 * days,
      onlineEarnings: 1710.0 * days,
      payoutStatus: PayoutStatus.pending,
    );
  }

  /// Load filtered earnings
  Future<DriverEarnings> _loadFilteredEarnings(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _loadEarningsForDateRange(startDate, endDate);
  }

  /// Load recent trips
  Future<List<Booking>> _loadRecentTrips() async {
    // Mock implementation - replace with actual API call
    return [];
  }

  /// Load cash trips
  Future<List<Booking>> _loadCashTrips() async {
    // Mock implementation - replace with actual API call
    return [];
  }
}