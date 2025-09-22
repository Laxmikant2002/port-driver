part of 'ride_history_bloc.dart';

/// Base class for all RideHistory events
sealed class RideHistoryEvent extends Equatable {
  const RideHistoryEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when ride history is loaded
final class RideHistoryLoaded extends RideHistoryEvent {
  const RideHistoryLoaded({
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
  String toString() => 'RideHistoryLoaded(limit: $limit, offset: $offset, status: $status, startDate: $startDate, endDate: $endDate)';
}

/// Event triggered when ride history is refreshed
final class RideHistoryRefreshed extends RideHistoryEvent {
  const RideHistoryRefreshed();

  @override
  String toString() => 'RideHistoryRefreshed()';
}

/// Event triggered when rides are filtered
final class RidesFiltered extends RideHistoryEvent {
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

/// Event triggered when ride details are requested
final class RideDetailsRequested extends RideHistoryEvent {
  const RideDetailsRequested(this.rideId);

  final String rideId;

  @override
  List<Object> get props => [rideId];

  @override
  String toString() => 'RideDetailsRequested(rideId: $rideId)';
}

/// Event triggered when date range is changed
final class DateRangeChanged extends RideHistoryEvent {
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
final class StatusFilterChanged extends RideHistoryEvent {
  const StatusFilterChanged(this.status);

  final RideStatus? status;

  @override
  List<Object> get props => [status ?? RideStatus.requested];

  @override
  String toString() => 'StatusFilterChanged(status: $status)';
}

/// Event triggered when statistics are requested
final class StatisticsRequested extends RideHistoryEvent {
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
