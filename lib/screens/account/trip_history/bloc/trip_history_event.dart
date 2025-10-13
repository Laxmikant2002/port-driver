part of 'trip_history_bloc.dart';

/// Base class for all TripHistory events
sealed class TripHistoryEvent extends Equatable {
  const TripHistoryEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when trip history is initialized
final class TripHistoryInitialized extends TripHistoryEvent {
  const TripHistoryInitialized({
    this.limit = 20,
    this.offset = 0,
    this.status,
    this.startDate,
    this.endDate,
  });

  final int limit;
  final int offset;
  final trip_repo.BookingStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object> get props => [
        limit,
        offset,
        status ?? trip_repo.BookingStatus.completed,
        startDate ?? DateTime.now(),
        endDate ?? DateTime.now(),
      ];

  @override
  String toString() => 'TripHistoryInitialized(limit: $limit, offset: $offset, status: $status, startDate: $startDate, endDate: $endDate)';
}

/// Event triggered when trip history is refreshed
final class TripHistoryRefreshed extends TripHistoryEvent {
  const TripHistoryRefreshed();

  @override
  String toString() => 'TripHistoryRefreshed()';
}

/// Event triggered when more trips are loaded (pagination)
final class TripHistoryLoadMore extends TripHistoryEvent {
  const TripHistoryLoadMore();

  @override
  String toString() => 'TripHistoryLoadMore()';
}

/// Event triggered when trips are filtered
final class TripHistoryFilterChanged extends TripHistoryEvent {
  const TripHistoryFilterChanged({
    this.status,
    this.startDate,
    this.endDate,
    this.paymentMode,
  });

  final trip_repo.BookingStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final local_models.PaymentMode? paymentMode;

  @override
  List<Object> get props => [
        status ?? trip_repo.BookingStatus.completed,
        startDate ?? DateTime.now(),
        endDate ?? DateTime.now(),
        paymentMode ?? local_models.PaymentMode.cash,
      ];

  @override
  String toString() => 'TripHistoryFilterChanged(status: $status, startDate: $startDate, endDate: $endDate, paymentMode: $paymentMode)';
}

/// Event triggered when trip details are requested
final class TripDetailsRequested extends TripHistoryEvent {
  const TripDetailsRequested(this.tripId);

  final String tripId;

  @override
  List<Object> get props => [tripId];

  @override
  String toString() => 'TripDetailsRequested(tripId: $tripId)';
}

/// Event triggered when statistics are requested
final class TripStatisticsRequested extends TripHistoryEvent {
  const TripStatisticsRequested({
    this.startDate,
    this.endDate,
    this.period,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? period;

  @override
  List<Object> get props => [
        startDate ?? DateTime.now(),
        endDate ?? DateTime.now(),
        period ?? '',
      ];

  @override
  String toString() => 'TripStatisticsRequested(startDate: $startDate, endDate: $endDate, period: $period)';
}

/// Event triggered when trip is marked as cash collected
final class TripCashCollected extends TripHistoryEvent {
  const TripCashCollected(this.tripId, this.amount);

  final String tripId;
  final double amount;

  @override
  List<Object> get props => [tripId, amount];

  @override
  String toString() => 'TripCashCollected(tripId: $tripId, amount: $amount)';
}

/// Event triggered when search is performed
final class TripHistorySearchPerformed extends TripHistoryEvent {
  const TripHistorySearchPerformed(this.query);

  final String query;

  @override
  List<Object> get props => [query];

  @override
  String toString() => 'TripHistorySearchPerformed(query: $query)';
}
