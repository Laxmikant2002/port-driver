part of 'trip_history_bloc.dart';

/// Base class for all TripHistory events
sealed class TripHistoryEvent extends Equatable {
  const TripHistoryEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when trip history is loaded
final class TripHistoryLoaded extends TripHistoryEvent {
  const TripHistoryLoaded({
    this.limit,
    this.offset,
    this.status,
    this.startDate,
    this.endDate,
  });

  final int? limit;
  final int? offset;
  final RideStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object> get props => [
        limit ?? 0,
        offset ?? 0,
        status ?? RideStatus.requested,
        startDate ?? DateTime.now(),
        endDate ?? DateTime.now(),
      ];

  @override
  String toString() => 'TripHistoryLoaded(limit: $limit, offset: $offset, status: $status, startDate: $startDate, endDate: $endDate)';
}

/// Event triggered when trip history is refreshed
final class TripHistoryRefreshed extends TripHistoryEvent {
  const TripHistoryRefreshed();

  @override
  String toString() => 'TripHistoryRefreshed()';
}

/// Event triggered when rides are filtered
final class RidesFiltered extends TripHistoryEvent {
  const RidesFiltered({
    this.status,
    this.startDate,
    this.endDate,
  });

  final RideStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object> get props => [
        status ?? RideStatus.requested,
        startDate ?? DateTime.now(),
        endDate ?? DateTime.now(),
      ];

  @override
  String toString() => 'RidesFiltered(status: $status, startDate: $startDate, endDate: $endDate)';
}

/// Event triggered when trip details are requested
final class TripDetailsRequested extends TripHistoryEvent {
  const TripDetailsRequested(this.rideId);

  final String rideId;

  @override
  List<Object> get props => [rideId];

  @override
  String toString() => 'TripDetailsRequested(rideId: $rideId)';
}

/// Event triggered when date range is changed
final class DateRangeChanged extends TripHistoryEvent {
  const DateRangeChanged({
    this.startDate,
    this.endDate,
  });

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object> get props => [startDate ?? DateTime.now(), endDate ?? DateTime.now()];

  @override
  String toString() => 'DateRangeChanged(startDate: $startDate, endDate: $endDate)';
}

/// Event triggered when status filter is changed
final class StatusFilterChanged extends TripHistoryEvent {
  const StatusFilterChanged(this.status);

  final RideStatus? status;

  @override
  List<Object> get props => [status ?? RideStatus.requested];

  @override
  String toString() => 'StatusFilterChanged(status: $status)';
}

/// Event triggered when statistics are requested
final class StatisticsRequested extends TripHistoryEvent {
  const StatisticsRequested({
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
  String toString() => 'StatisticsRequested(startDate: $startDate, endDate: $endDate, period: $period)';
}

/// Event triggered when sample data is loaded for demonstration
final class TripHistoryLoadedWithSampleData extends TripHistoryEvent {
  const TripHistoryLoadedWithSampleData();

  @override
  String toString() => 'TripHistoryLoadedWithSampleData()';
}
