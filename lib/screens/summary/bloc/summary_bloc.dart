import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/screens/summary/bloc/summary_event.dart';
import 'package:driver/screens/summary/bloc/summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  SummaryBloc() : super(SummaryState.initial()) {
    on<LoadSummary>(_onLoadSummary);
    on<CompleteTrip>(_onCompleteTrip);
  }

  void _onLoadSummary(LoadSummary event, Emitter<SummaryState> emit) {
    // Simulate loading data
    emit(state.copyWith(
      guestName: 'John Doe',
      pickupLocation: '123 Beachside Road',
      dropLocation: '789 Downtown Street',
      timeRange: 'Today, 2:00 - 4:00 PM',
      distance: 8.2,
      durationMinutes: 20,
      price: 25.0,
      paymentMethod: 'Cash',
    ));
  }

  void _onCompleteTrip(CompleteTrip event, Emitter<SummaryState> emit) {
    emit(state.copyWith(tripCompleted: true));
  }
}
