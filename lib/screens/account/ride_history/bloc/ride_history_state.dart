part of 'ride_history_bloc.dart';

/// Ride history state containing ride data and submission status
final class RideHistoryState extends Equatable {
  const RideHistoryState({
    this.allRides = const [],
    this.filteredRides = const [],
    this.selectedRide,
    this.statistics,
    this.selectedStatus,
    this.selectedStartDate,
    this.selectedEndDate,
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
  final FormzSubmissionStatus status;
  final String? errorMessage;

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

  /// Returns true if ride history is currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns total rides count
  int get totalRides => allRides.length;

  /// Returns completed rides count
  int get completedRides => allRides.where((r) => r.status == RideStatus.completed).length;

  /// Returns cancelled rides count
  int get cancelledRides => allRides.where((r) => r.status == RideStatus.cancelled).length;

  /// Returns total earnings from completed rides
  double get totalEarnings => allRides
      .where((r) => r.status == RideStatus.completed)
      .fold(0.0, (sum, r) => sum + r.fare);

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

  RideHistoryState copyWith({
    List<Ride>? allRides,
    List<Ride>? filteredRides,
    Ride? selectedRide,
    RideStatistics? statistics,
    RideStatus? selectedStatus,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RideHistoryState(
      allRides: allRides ?? this.allRides,
      filteredRides: filteredRides ?? this.filteredRides,
      selectedRide: selectedRide ?? this.selectedRide,
      statistics: statistics ?? this.statistics,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedStartDate: selectedStartDate ?? this.selectedStartDate,
      selectedEndDate: selectedEndDate ?? this.selectedEndDate,
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
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'RideHistoryState('
        'allRides: ${allRides.length}, '
        'filteredRides: ${filteredRides.length}, '
        'selectedRide: $selectedRide, '
        'statistics: $statistics, '
        'selectedStatus: $selectedStatus, '
        'selectedStartDate: $selectedStartDate, '
        'selectedEndDate: $selectedEndDate, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}
