part of 'earnings_bloc.dart';

/// State for earnings screen
class EarningsState extends Equatable {
  final FormzSubmissionStatus status;
  final DriverEarnings? todayEarnings;
  final DriverEarnings? weekEarnings;
  final DriverEarnings? monthEarnings;
  final List<Booking> recentTrips;
  final List<Booking> cashTrips;
  final String? errorMessage;
  final bool isRefreshing;
  final EarningsFilter currentFilter;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const EarningsState({
    this.status = FormzSubmissionStatus.initial,
    this.todayEarnings,
    this.weekEarnings,
    this.monthEarnings,
    this.recentTrips = const [],
    this.cashTrips = const [],
    this.errorMessage,
    this.isRefreshing = false,
    this.currentFilter = EarningsFilter.today,
    this.filterStartDate,
    this.filterEndDate,
  });

  EarningsState copyWith({
    FormzSubmissionStatus? status,
    DriverEarnings? todayEarnings,
    DriverEarnings? weekEarnings,
    DriverEarnings? monthEarnings,
    List<Booking>? recentTrips,
    List<Booking>? cashTrips,
    String? errorMessage,
    bool? isRefreshing,
    EarningsFilter? currentFilter,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
  }) {
    return EarningsState(
      status: status ?? this.status,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weekEarnings: weekEarnings ?? this.weekEarnings,
      monthEarnings: monthEarnings ?? this.monthEarnings,
      recentTrips: recentTrips ?? this.recentTrips,
      cashTrips: cashTrips ?? this.cashTrips,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentFilter: currentFilter ?? this.currentFilter,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
    );
  }

  /// Get current earnings based on selected filter
  DriverEarnings? get currentEarnings {
    switch (currentFilter) {
      case EarningsFilter.today:
        return todayEarnings;
      case EarningsFilter.week:
        return weekEarnings;
      case EarningsFilter.month:
        return monthEarnings;
      case EarningsFilter.custom:
        return todayEarnings; // For now, return today's data for custom
    }
  }

  /// Get pending cash amount
  double get pendingCashAmount {
    return cashTrips
        .where((trip) => trip.paymentStatus == PaymentStatus.pending)
        .fold(0.0, (sum, trip) => sum + (trip.fare ?? 0.0));
  }

  /// Get cash collected today
  double get cashCollectedToday {
    return cashTrips
        .where((trip) => 
            trip.paymentStatus == PaymentStatus.paid &&
            trip.createdAt.day == DateTime.now().day)
        .fold(0.0, (sum, trip) => sum + (trip.fare ?? 0.0));
  }

  @override
  List<Object?> get props => [
        status,
        todayEarnings,
        weekEarnings,
        monthEarnings,
        recentTrips,
        cashTrips,
        errorMessage,
        isRefreshing,
        currentFilter,
        filterStartDate,
        filterEndDate,
      ];
}

/// Filter options for earnings
enum EarningsFilter {
  today('Today'),
  week('This Week'),
  month('This Month'),
  custom('Custom');

  const EarningsFilter(this.displayName);
  final String displayName;
}