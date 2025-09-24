part of 'trip_history_bloc.dart';

enum DateRangeValidationError { invalid }

class DateRange extends FormzInput<DateTime?, DateRangeValidationError> {
  const DateRange.pure() : super.pure(null);
  const DateRange.dirty([super.value]) : super.dirty();

  @override
  DateRangeValidationError? validator(DateTime? value) {
    if (value != null && value.isAfter(DateTime.now())) {
      return DateRangeValidationError.invalid;
    }
    return null;
  }
}

enum StatusFilterValidationError { empty }

class StatusFilter extends FormzInput<RideStatus?, StatusFilterValidationError> {
  const StatusFilter.pure() : super.pure(null);
  const StatusFilter.dirty([super.value]) : super.dirty();

  @override
  StatusFilterValidationError? validator(RideStatus? value) {
    // Status filter is optional, so no validation needed
    return null;
  }
}

/// Trip history state containing ride data and submission status
final class TripHistoryState extends Equatable {
  const TripHistoryState({
    this.allRides = const [],
    this.filteredRides = const [],
    this.selectedRide,
    this.statistics,
    this.selectedStatus,
    this.selectedStartDate,
    this.selectedEndDate,
    this.startDate = const DateRange.pure(),
    this.endDate = const DateRange.pure(),
    this.statusFilter = const StatusFilter.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final List<Ride> allRides;
  final List<Ride> filteredRides;
  final Ride? selectedRide;
  final RideStatistics? statistics;
  final RideStatus? selectedStatus;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final DateRange startDate;
  final DateRange endDate;
  final StatusFilter statusFilter;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([startDate, endDate, statusFilter]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns the current error message if any
  String? get error => errorMessage;

  /// Returns true if trip history is currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns the current rides being displayed (filtered or all)
  List<Ride> get currentRides => filteredRides.isNotEmpty ? filteredRides : allRides;

  /// Returns total rides count
  int get totalRides => allRides.length;

  /// Returns completed rides count
  int get completedRides => allRides.where((r) => r.status == RideStatus.completed).length;

  /// Returns cancelled rides count
  int get cancelledRides => allRides.where((r) => r.status == RideStatus.cancelled).length;

  /// Returns total earnings from completed rides
  double get totalEarnings => allRides
      .where((r) => r.status == RideStatus.completed)
      .fold(0.0, (sum, r) => sum + (r.earnedAmount ?? r.fare * 0.85));

  /// Returns average rating
  double get averageRating {
    final ratedRides = allRides.where((r) => r.rating != null).toList();
    if (ratedRides.isEmpty) return 0.0;
    
    final totalRating = ratedRides.fold(0.0, (sum, r) => sum + (r.rating ?? 0.0));
    return totalRating / ratedRides.length;
  }

  /// Returns total distance from completed rides
  double get totalDistance => allRides
      .where((r) => r.status == RideStatus.completed)
      .fold(0.0, (sum, r) => sum + r.distance);

  /// Returns total duration from completed rides (in minutes)
  int get totalDuration => allRides
      .where((r) => r.status == RideStatus.completed)
      .fold(0, (sum, r) => sum + r.duration);

  TripHistoryState copyWith({
    List<Ride>? allRides,
    List<Ride>? filteredRides,
    Ride? selectedRide,
    RideStatistics? statistics,
    RideStatus? selectedStatus,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    DateRange? startDate,
    DateRange? endDate,
    StatusFilter? statusFilter,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TripHistoryState(
      allRides: allRides ?? this.allRides,
      filteredRides: filteredRides ?? this.filteredRides,
      selectedRide: selectedRide ?? this.selectedRide,
      statistics: statistics ?? this.statistics,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedStartDate: selectedStartDate ?? this.selectedStartDate,
      selectedEndDate: selectedEndDate ?? this.selectedEndDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      statusFilter: statusFilter ?? this.statusFilter,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        allRides,
        filteredRides,
        selectedRide,
        statistics,
        selectedStatus,
        selectedStartDate,
        selectedEndDate,
        startDate,
        endDate,
        statusFilter,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'TripHistoryState('
        'allRides: ${allRides.length}, '
        'filteredRides: ${filteredRides.length}, '
        'selectedRide: $selectedRide, '
        'statistics: $statistics, '
        'selectedStatus: $selectedStatus, '
        'selectedStartDate: $selectedStartDate, '
        'selectedEndDate: $selectedEndDate, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'statusFilter: $statusFilter, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}
