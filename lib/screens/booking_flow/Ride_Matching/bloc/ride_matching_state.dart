part of 'ride_matching_bloc.dart';

/// Ride matching state containing form data and submission status
final class RideMatchingState extends Equatable {
  const RideMatchingState({
    this.status = FormzSubmissionStatus.initial,
    this.currentRequest,
    this.timerSeconds = 0,
    this.isAccepting = false,
    this.rejectionReason,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final Booking? currentRequest;
  final int timerSeconds;
  final bool isAccepting;
  final String? rejectionReason;
  final String? errorMessage;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns true if there's an active ride request
  bool get hasActiveRequest => currentRequest != null && timerSeconds > 0;

  /// Returns true if the timer has expired
  bool get isExpired => timerSeconds == 0 && currentRequest != null;

  /// Returns the masked rider name
  String get maskedRiderName {
    if (currentRequest?.passengerName == null) return 'Anonymous';
    final name = currentRequest!.passengerName!;
    if (name.length <= 2) return name;
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}';
  }

  /// Returns the formatted distance
  String get formattedDistance {
    if (currentRequest == null) return '0 km';
    return '${currentRequest!.distance.toStringAsFixed(1)} km';
  }

  /// Returns the formatted fare
  String get formattedFare {
    if (currentRequest == null) return '₹0';
    return '₹${currentRequest!.fare.toStringAsFixed(2)}';
  }

  /// Returns the formatted pickup location
  String get pickupLocation {
    return currentRequest?.pickupLocation.address ?? 'Unknown location';
  }

  /// Returns the formatted dropoff location
  String get dropoffLocation {
    return currentRequest?.dropoffLocation.address ?? 'Unknown location';
  }

  /// Returns the estimated duration
  String get estimatedDuration {
    if (currentRequest == null) return '0 min';
    return '${currentRequest!.estimatedDuration} min';
  }

  /// Returns the timer display text
  String get timerText {
    if (timerSeconds <= 0) return 'Expired';
    return '${timerSeconds}s';
  }

  /// Returns true if timer is in warning state (last 3 seconds)
  bool get isTimerWarning => timerSeconds <= 3 && timerSeconds > 0;

  RideMatchingState copyWith({
    FormzSubmissionStatus? status,
    Booking? currentRequest,
    int? timerSeconds,
    bool? isAccepting,
    String? rejectionReason,
    String? errorMessage,
  }) {
    return RideMatchingState(
      status: status ?? this.status,
      currentRequest: currentRequest ?? this.currentRequest,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      isAccepting: isAccepting ?? this.isAccepting,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentRequest,
        timerSeconds,
        isAccepting,
        rejectionReason,
        errorMessage,
      ];

  @override
  String toString() {
    return 'RideMatchingState('
        'status: $status, '
        'currentRequest: $currentRequest, '
        'timerSeconds: $timerSeconds, '
        'isAccepting: $isAccepting, '
        'errorMessage: $errorMessage'
        ')';
  }
}
