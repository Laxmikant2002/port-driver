import 'package:booking_repo/booking_repo.dart';
import 'package:driver/widgets/colors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({
    required this.bookingRepo,
  }) : super(const BookingState()) {
    on<BookingInitialized>(_onInitialized);
    on<RideRequestReceived>(_onRideRequestReceived);
    on<RideAccepted>(_onRideAccepted);
    on<RideRejected>(_onRideRejected);
    on<TripStarted>(_onTripStarted);
    on<TripCompleted>(_onTripCompleted);
    on<BookingSubmitted>(_onSubmitted);
  }

  final BookingRepo bookingRepo;

  Future<void> _onInitialized(
    BookingInitialized event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Get available ride requests
      final response = await bookingRepo.getAvailableBookings();

      if (response.success) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          availableBookings: response.bookings ?? [],
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to load ride requests',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }

  void _onRideRequestReceived(
    RideRequestReceived event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      currentBooking: event.booking,
      status: FormzSubmissionStatus.initial,
    ));
  }

  void _onRideAccepted(
    RideAccepted event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
    ));
  }

  void _onRideRejected(
    RideRejected event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
    ));
  }

  void _onTripStarted(
    TripStarted event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
    ));
  }

  void _onTripCompleted(
    TripCompleted event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
    ));
  }

  Future<void> _onSubmitted(
    BookingSubmitted event,
    Emitter<BookingState> emit,
  ) async {
    if (state.currentBooking == null) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'No active booking found',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      BookingResponse response;
      
      switch (event.action) {
        case BookingAction.accept:
          response = await bookingRepo.acceptBooking(state.currentBooking!.id);
          break;
        case BookingAction.reject:
          response = await bookingRepo.rejectBooking(
            state.currentBooking!.id,
            reason: event.reason,
          );
          break;
        case BookingAction.start:
          response = await bookingRepo.startBooking(state.currentBooking!.id);
          break;
        case BookingAction.complete:
          response = await bookingRepo.completeBooking(state.currentBooking!.id);
          break;
      }

      if (response.success) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          currentBooking: response.booking ?? state.currentBooking,
          completedFare: event.action == BookingAction.complete ? state.currentBooking!.fare : null,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Action failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }
}
