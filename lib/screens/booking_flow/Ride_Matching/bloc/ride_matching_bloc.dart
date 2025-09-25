import 'package:booking_repo/booking_repo.dart';
import 'package:driver/widgets/colors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'ride_matching_event.dart';
part 'ride_matching_state.dart';

class RideMatchingBloc extends Bloc<RideMatchingEvent, RideMatchingState> {
  RideMatchingBloc({
    required this.bookingRepo,
  }) : super(const RideMatchingState()) {
    on<RideMatchingInitialized>(_onInitialized);
    on<IncomingRideRequest>(_onIncomingRideRequest);
    on<RideRequestAccepted>(_onRideRequestAccepted);
    on<RideRequestRejected>(_onRideRequestRejected);
    on<RideRequestTimeout>(_onRideRequestTimeout);
    on<DriverArrivedAtPickup>(_onDriverArrivedAtPickup);
    on<TripStarted>(_onTripStarted);
    on<TripCompleted>(_onTripCompleted);
    on<LocationUpdated>(_onLocationUpdated);
  }

  final BookingRepo bookingRepo;

  Future<void> _onInitialized(
    RideMatchingInitialized event,
    Emitter<RideMatchingState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Initialize ride matching - listen for incoming requests
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        currentStatus: 'Waiting for ride requests',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to initialize ride matching: ${e.toString()}',
      ));
    }
  }

  void _onIncomingRideRequest(
    IncomingRideRequest event,
    Emitter<RideMatchingState> emit,
  ) {
    emit(state.copyWith(
      currentBooking: event.booking,
      currentStatus: 'Incoming ride request',
      requestReceivedAt: DateTime.now(),
    ));

    // Start timeout timer (typically 30 seconds)
    _startRequestTimeout();
  }

  Future<void> _onRideRequestAccepted(
    RideRequestAccepted event,
    Emitter<RideMatchingState> emit,
  ) async {
    if (state.currentBooking == null) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final response = await bookingRepo.acceptBooking(state.currentBooking!.id);

      if (response.success) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          currentBooking: response.booking ?? state.currentBooking,
          currentStatus: 'Ride accepted - En route to pickup',
          currentPhase: RidePhase.pickup,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to accept ride request',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRideRequestRejected(
    RideRequestRejected event,
    Emitter<RideMatchingState> emit,
  ) async {
    if (state.currentBooking == null) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final response = await bookingRepo.rejectBooking(
        state.currentBooking!.id,
        reason: event.reason,
      );

      if (response.success) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          currentBooking: null,
          currentStatus: 'Waiting for ride requests',
          currentPhase: RidePhase.pickup,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to reject ride request',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }

  void _onRideRequestTimeout(
    RideRequestTimeout event,
    Emitter<RideMatchingState> emit,
  ) {
    emit(state.copyWith(
      currentBooking: null,
      currentStatus: 'Request timed out - Waiting for new requests',
      requestReceivedAt: null,
    ));
  }

  Future<void> _onDriverArrivedAtPickup(
    DriverArrivedAtPickup event,
    Emitter<RideMatchingState> emit,
  ) async {
    if (state.currentBooking == null) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final response = await bookingRepo.startBooking(state.currentBooking!.id);

      if (response.success) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          currentBooking: response.booking ?? state.currentBooking,
          currentStatus: 'Arrived at pickup location',
          tripStartedAt: DateTime.now(),
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to confirm arrival',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }

  Future<void> _onTripStarted(
    TripStarted event,
    Emitter<RideMatchingState> emit,
  ) async {
    if (state.currentBooking == null) return;

    emit(state.copyWith(
      currentStatus: 'Trip in progress - En route to destination',
      currentPhase: RidePhase.dropoff,
      tripStartedAt: DateTime.now(),
    ));
  }

  Future<void> _onTripCompleted(
    TripCompleted event,
    Emitter<RideMatchingState> emit,
  ) async {
    if (state.currentBooking == null) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final response = await bookingRepo.completeBooking(state.currentBooking!.id);

      if (response.success) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          currentBooking: response.booking ?? state.currentBooking,
          currentStatus: 'Trip completed',
          currentPhase: RidePhase.completed,
          completedFare: state.currentBooking!.fare,
          tripCompletedAt: DateTime.now(),
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to complete trip',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${e.toString()}',
      ));
    }
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<RideMatchingState> emit,
  ) {
    // Handle location updates during trip
    emit(state.copyWith(
      currentLocation: event.location,
    ));
  }

  void _startRequestTimeout() {
    // Implement timeout logic (typically 30 seconds)
    // This would be handled by the UI layer with a timer
  }

  /// Calculate distance to pickup location
  double? calculateDistanceToPickup(LatLng driverLocation) {
    if (state.currentBooking?.pickupLocation == null) return null;
    
    final pickup = state.currentBooking!.pickupLocation;
    return _calculateDistance(
      driverLocation.latitude,
      driverLocation.longitude,
      pickup.latitude,
      pickup.longitude,
    );
  }

  /// Calculate distance to dropoff location
  double? calculateDistanceToDropoff(LatLng driverLocation) {
    if (state.currentBooking?.dropoffLocation == null) return null;
    
    final dropoff = state.currentBooking!.dropoffLocation;
    return _calculateDistance(
      driverLocation.latitude,
      driverLocation.longitude,
      dropoff.latitude,
      dropoff.longitude,
    );
  }

  /// Calculate distance between two points in meters
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * (dLon / 2).sin() * (dLon / 2).sin();
    final double c = 2 * (a.sqrt()).asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}