import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<ClearHistory>(_onClearHistory);
    on<GroupTripsByDate>(_onGroupTripsByDate);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      emit(HistoryLoading());
      await Future.delayed(const Duration(seconds: 1));
      emit(HistoryLoaded(event.trips));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onClearHistory(
    ClearHistory event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      emit(HistoryLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(HistoryLoaded([]));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onGroupTripsByDate(
    GroupTripsByDate event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;
        final sortedTrips = List<TripHistory>.from(currentState.trips)
          ..sort((a, b) => b.date.compareTo(a.date));
        emit(HistoryLoaded(sortedTrips));
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
