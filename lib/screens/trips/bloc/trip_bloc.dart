import 'package:flutter_bloc/flutter_bloc.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  TripBloc()
      : super(const TripState(
          selectedCategory: TripCategory.all,
          isPaid: false,
          isMarkedArrivedPressed: {},
          isContactGuestPressed: {},
        )) {
    on<TripCategorySelected>((event, emit) {
      emit(state.copyWith(selectedCategory: event.category));
    });

    on<PaymentStatusUpdated>((event, emit) {
      emit(state.copyWith(isPaid: event.isPaid));
    });

    on<MarkArrivedPressed>((event, emit) {
      final updatedIsMarkedArrivedPressed = Map<int, bool>.from(state.isMarkedArrivedPressed);
      updatedIsMarkedArrivedPressed[event.tripId] = true; 
      emit(state.copyWith(isMarkedArrivedPressed: updatedIsMarkedArrivedPressed));
    });

    on<MarkArrivedReleased>((event, emit) {
      final updatedIsMarkedArrivedPressed = Map<int, bool>.from(state.isMarkedArrivedPressed);
      updatedIsMarkedArrivedPressed[event.tripId] = false;
      emit(state.copyWith(isMarkedArrivedPressed: updatedIsMarkedArrivedPressed));
    });

    on<ContactGuestPressed>((event, emit) {
      final updatedIsContactGuestPressed = Map<int, bool>.from(state.isContactGuestPressed);
      updatedIsContactGuestPressed[event.tripId] = true; 
      emit(state.copyWith(isContactGuestPressed: updatedIsContactGuestPressed));
    });

    on<ContactGuestReleased>((event, emit) {
      final updatedIsContactGuestPressed = Map<int, bool>.from(state.isContactGuestPressed);
      updatedIsContactGuestPressed[event.tripId] = false; 
      emit(state.copyWith(isContactGuestPressed: updatedIsContactGuestPressed));
    });
  }
}
