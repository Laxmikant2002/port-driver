part of 'ride_matching_bloc.dart';

/// Ride phase enum
enum RidePhase {
  pickup,
  dropoff,
  completed,
}

/// Ride matching state containing ride request data and status
final class RideMatchingState extends Equatable {
  const RideMatchingState({
    this.status = FormzSubmissionStatus.initial,
    this.currentBooking,
    this.currentStatus = 'Initializing',
    this.currentPhase = RidePhase.pickup,
    this.requestReceivedAt,
    this.tripStartedAt,
    this.tripCompletedAt,
    this.completedFare,
    this.currentLocation,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final Booking? currentBooking;
  final String currentStatus;
  final RidePhase currentPhase;
  final DateTime? requestReceivedAt;
  final DateTime? tripStartedAt;
  final DateTime? tripCompletedAt;
  final double? completedFare;
  final LatLng? currentLocation;
  final String? errorMessage;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns true if there's an active booking
  bool get hasActiveBooking => currentBooking != null;

  /// Returns true if there's an incoming request
  bool get hasIncomingRequest => currentBooking != null && currentPhase == RidePhase.pickup;

  /// Returns true if the current booking is pending
  bool get isBookingPending => currentBooking?.status == BookingStatus.pending;

  /// Returns true if the current booking is accepted
  bool get isBookingAccepted => currentBooking?.status == BookingStatus.accepted;

  /// Returns true if the current booking is started
  bool get isBookingStarted => currentBooking?.status == BookingStatus.started;

  /// Returns true if the current booking is completed
  bool get isBookingCompleted => currentBooking?.status == BookingStatus.completed;

  /// Returns true if the current booking is cancelled
  bool get isBookingCancelled => currentBooking?.status == BookingStatus.cancelled;

  /// Returns the masked phone number
  String get maskedPhoneNumber {
    if (currentBooking?.passengerPhone == null) return 'N/A';
    final phone = currentBooking!.passengerPhone!;
    if (phone.length < 4) return phone;
    return '${phone.substring(0, 2)}****${phone.substring(phone.length - 2)}';
  }

  /// Returns the fare formatted as currency
  String get fareText => '₹${(currentBooking?.fare ?? 0.0).toStringAsFixed(2)}';

  /// Returns the completed fare formatted as currency
  String get completedFareText => '₹${(completedFare ?? 0.0).toStringAsFixed(2)}';

  /// Returns the distance formatted
  String get distanceText => '${(currentBooking?.distance ?? 0.0).toStringAsFixed(1)} km';

  /// Returns the estimated duration formatted
  String get durationText => '${currentBooking?.estimatedDuration ?? 0} min';

  /// Returns the trip status display text
  String get tripStatusText {
    switch (currentPhase) {
      case RidePhase.pickup:
        return 'En route to pickup';
      case RidePhase.dropoff:
        return 'En route to destination';
      case RidePhase.completed:
        return 'Trip completed';
    }
  }

  /// Returns the trip status color
  Color get tripStatusColor {
    switch (currentPhase) {
      case RidePhase.pickup:
        return AppColors.warning;
      case RidePhase.dropoff:
        return AppColors.info;
      case RidePhase.completed:
        return AppColors.success;
    }
  }

  /// Returns the request timeout remaining in seconds
  int get requestTimeoutRemaining {
    if (requestReceivedAt == null) return 0;
    final elapsed = DateTime.now().difference(requestReceivedAt!).inSeconds;
    return (30 - elapsed).clamp(0, 30); // 30 second timeout
  }

  /// Returns true if request is about to timeout
  bool get isRequestTimingOut => requestTimeoutRemaining <= 10 && requestTimeoutRemaining > 0;

  /// Returns the trip duration if started
  Duration? get tripDuration {
    if (tripStartedAt == null) return null;
    final endTime = tripCompletedAt ?? DateTime.now();
    return endTime.difference(tripStartedAt!);
  }

  /// Returns formatted trip duration
  String get tripDurationText {
    final duration = tripDuration;
    if (duration == null) return 'Not started';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Returns the pickup location
  BookingLocation? get pickupLocation => currentBooking?.pickupLocation;

  /// Returns the dropoff location
  BookingLocation? get dropoffLocation => currentBooking?.dropoffLocation;

  /// Returns the passenger name
  String? get passengerName => currentBooking?.passengerName;

  /// Returns the passenger phone
  String? get passengerPhone => currentBooking?.passengerPhone;

  /// Returns the vehicle type
  String? get vehicleType => currentBooking?.vehicleType;

  /// Returns the payment method
  String? get paymentMethod => currentBooking?.paymentMethod;

  RideMatchingState copyWith({
    FormzSubmissionStatus? status,
    Booking? currentBooking,
    String? currentStatus,
    RidePhase? currentPhase,
    DateTime? requestReceivedAt,
    DateTime? tripStartedAt,
    DateTime? tripCompletedAt,
    double? completedFare,
    LatLng? currentLocation,
    String? errorMessage,
  }) {
    return RideMatchingState(
      status: status ?? this.status,
      currentBooking: currentBooking ?? this.currentBooking,
      currentStatus: currentStatus ?? this.currentStatus,
      currentPhase: currentPhase ?? this.currentPhase,
      requestReceivedAt: requestReceivedAt ?? this.requestReceivedAt,
      tripStartedAt: tripStartedAt ?? this.tripStartedAt,
      tripCompletedAt: tripCompletedAt ?? this.tripCompletedAt,
      completedFare: completedFare ?? this.completedFare,
      currentLocation: currentLocation ?? this.currentLocation,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentBooking,
        currentStatus,
        currentPhase,
        requestReceivedAt,
        tripStartedAt,
        tripCompletedAt,
        completedFare,
        currentLocation,
        errorMessage,
      ];

  @override
  String toString() {
    return 'RideMatchingState('
        'status: $status, '
        'currentBooking: $currentBooking, '
        'currentStatus: $currentStatus, '
        'currentPhase: $currentPhase, '
        'completedFare: $completedFare, '
        'errorMessage: $errorMessage'
        ')';
  }
}