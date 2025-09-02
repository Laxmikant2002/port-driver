part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<TripHistory> trips;

  const HistoryLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class TripHistory {
  final String date;
  final String time;
  final String passenger;
  final String source;
  final String destination;
  final String amount;
  final int rating;

  TripHistory({
    required this.date,
    required this.time,
    required this.passenger,
    required this.source,
    required this.destination,
    required this.amount,
    required this.rating,
  });
}

