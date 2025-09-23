part of 'booking_bloc.dart';

/// Booking state containing form data and submission status
final class BookingState extends Equatable {
  const BookingState({
    this.status = FormzSubmissionStatus.initial,
    this.currentBooking,
    this.availableBookings = const [],
    this.completedFare,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final Booking? currentBooking;
  final List<Booking> availableBookings;
  final double? completedFare;
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
    switch (currentBooking?.status) {
      case BookingStatus.pending:
        return 'Waiting for pickup';
      case BookingStatus.accepted:
        return 'En route to pickup';
      case BookingStatus.started:
        return 'Trip in progress';
      case BookingStatus.completed:
        return 'Trip completed';
      case BookingStatus.cancelled:
        return 'Trip cancelled';
      default:
        return 'No active trip';
    }
  }

  /// Returns the trip status color
  Color get tripStatusColor {
    switch (currentBooking?.status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.accepted:
        return AppColors.info;
      case BookingStatus.started:
        return AppColors.success;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  BookingState copyWith({
    FormzSubmissionStatus? status,
    Booking? currentBooking,
    List<Booking>? availableBookings,
    double? completedFare,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      currentBooking: currentBooking ?? this.currentBooking,
      availableBookings: availableBookings ?? this.availableBookings,
      completedFare: completedFare ?? this.completedFare,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentBooking,
        availableBookings,
        completedFare,
        errorMessage,
      ];

  @override
  String toString() {
    return 'BookingState('
        'status: $status, '
        'currentBooking: $currentBooking, '
        'availableBookings: ${availableBookings.length}, '
        'completedFare: $completedFare, '
        'errorMessage: $errorMessage'
        ')';
  }
}
