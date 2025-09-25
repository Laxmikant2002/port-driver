part of 'earnings_bloc.dart';

abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object> get props => [];
}

/// Event to initialize earnings screen
class EarningsInitialized extends EarningsEvent {
  const EarningsInitialized();
}

/// Event to refresh earnings data
class EarningsRefreshed extends EarningsEvent {
  const EarningsRefreshed();
}

/// Event to filter earnings by date range
class EarningsFilterChanged extends EarningsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const EarningsFilterChanged({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

/// Event to request payout
class PayoutRequested extends EarningsEvent {
  final double amount;

  const PayoutRequested({required this.amount});

  @override
  List<Object> get props => [amount];
}

/// Event to mark cash trip as collected
class CashTripMarkedCollected extends EarningsEvent {
  final String tripId;
  final double amount;

  const CashTripMarkedCollected({
    required this.tripId,
    required this.amount,
  });

  @override
  List<Object> get props => [tripId, amount];
}

/// Event to load trip details for earnings breakdown
class TripDetailsRequested extends EarningsEvent {
  final String tripId;

  const TripDetailsRequested({required this.tripId});

  @override
  List<Object> get props => [tripId];
}