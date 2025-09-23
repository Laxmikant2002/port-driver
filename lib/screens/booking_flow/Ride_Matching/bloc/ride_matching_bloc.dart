import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:booking_repo/booking_repo.dart';
import 'package:driver/services/socket_service.dart';

part 'ride_matching_event.dart';
part 'ride_matching_state.dart';

class RideMatchingBloc extends Bloc<RideMatchingEvent, RideMatchingState> {
  RideMatchingBloc({
    required this.bookingRepo,
    required this.socketService,
  }) : super(const RideMatchingState()) {
    on<RideMatchingInitialized>(_onInitialized);
    on<RideRequestReceived>(_onRideRequestReceived);
    on<RideAccepted>(_onRideAccepted);
    on<RideRejected>(_onRideRejected);
    on<RideRequestSubmitted>(_onSubmitted);
    on<TimerTick>(_onTimerTick);
    on<RideRequestExpired>(_onRideRequestExpired);
  }

  final BookingRepo bookingRepo;
  final SocketService socketService;

  Future<void> _onInitialized(
    RideMatchingInitialized event,
    Emitter<RideMatchingState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Listen for incoming ride requests via socket
      socketService.socket.on('ride_request', (data) {
        if (data is Map<String, dynamic>) {
          add(RideRequestReceived(Booking.fromJson(data)));
        }
      });

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to initialize ride matching: ${e.toString()}',
      ));
    }
  }

  void _onRideRequestReceived(
    RideRequestReceived event,
    Emitter<RideMatchingState> emit,
  ) {
    emit(state.copyWith(
      currentRequest: event.booking,
      timerSeconds: 10, // 10 second countdown
      status: FormzSubmissionStatus.initial,
    ));

    // Start countdown timer
    _startCountdownTimer(emit);
  }

  void _onRideAccepted(
    RideAccepted event,
    Emitter<RideMatchingState> emit,
  ) {
    if (state.currentRequest == null) return;

    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
    ));
  }

  void _onRideRejected(
    RideRejected event,
    Emitter<RideMatchingState> emit,
  ) {
    if (state.currentRequest == null) return;

    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
    ));
  }

  Future<void> _onSubmitted(
    RideRequestSubmitted event,
    Emitter<RideMatchingState> emit,
  ) async {
    if (state.currentRequest == null) return;

    try {
      BookingResponse response;
      
      if (state.isAccepting) {
        response = await bookingRepo.acceptBooking(state.currentRequest!.id);
      } else {
        response = await bookingRepo.rejectBooking(
          state.currentRequest!.id,
          reason: state.rejectionReason,
        );
      }

      if (response.success) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          currentRequest: null,
          timerSeconds: 0,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to process ride request',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }

  void _onTimerTick(
    TimerTick event,
    Emitter<RideMatchingState> emit,
  ) {
    if (state.timerSeconds > 0) {
      emit(state.copyWith(timerSeconds: state.timerSeconds - 1));
    } else {
      add(const RideRequestExpired());
    }
  }

  void _onRideRequestExpired(
    RideRequestExpired event,
    Emitter<RideMatchingState> emit,
  ) {
    // Auto-reject expired request
    add(const RideRejected());
    add(const RideRequestSubmitted());
  }

  void _startCountdownTimer(Emitter<RideMatchingState> emit) {
    // This would typically use a Timer.periodic in a real implementation
    // For now, we'll simulate the timer with events
    Future.delayed(const Duration(seconds: 1), () {
      if (state.timerSeconds > 0) {
        add(const TimerTick());
      }
    });
  }
}
