part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadHistory extends HistoryEvent {
  final List<TripHistory> trips;
  const LoadHistory({required this.trips});

  @override
  List<Object> get props => [trips];
}
class ClearHistory extends HistoryEvent {}

class GroupTripsByDate extends HistoryEvent {}
