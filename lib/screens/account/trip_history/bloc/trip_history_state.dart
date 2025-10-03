part of 'trip_history_bloc.dart';

/// Trip history state containing comprehensive trip data and submission status
final class TripHistoryState extends Equatable {
  const TripHistoryState({
    this.tripHistoryData,
    this.selectedTrip,
    this.statistics,
    this.currentFilter,
    this.searchQuery,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  final TripHistoryData? tripHistoryData;
  final local_models.Booking? selectedTrip;
  final TripStatistics? statistics;
  final TripHistoryFilter? currentFilter;
  final String? searchQuery;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final bool isLoadingMore;
  final bool hasReachedMax;

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

  /// Returns the current trips being displayed
  List<local_models.Booking> get currentTrips => tripHistoryData?.bookings ?? [];

  /// Returns filtered trips based on search query
  List<local_models.Booking> get filteredTrips {
    final trips = currentTrips;
    if (searchQuery == null || searchQuery!.isEmpty) return trips;
    
    return trips.where((trip) {
      return trip.customerName.toLowerCase().contains(searchQuery!.toLowerCase()) ||
             trip.pickupAddress.toLowerCase().contains(searchQuery!.toLowerCase()) ||
             trip.dropoffAddress.toLowerCase().contains(searchQuery!.toLowerCase());
    }).toList();
  }

  /// Returns total trips count
  int get totalTrips => tripHistoryData?.totalCount ?? 0;

  /// Returns completed trips count
  int get completedTrips => currentTrips.where((t) => t.status == local_models.BookingStatus.completed).length;

  /// Returns cancelled trips count
  int get cancelledTrips => currentTrips.where((t) => t.status == local_models.BookingStatus.cancelled).length;

  /// Returns total earnings from completed trips
  double get totalEarnings => currentTrips
      .where((t) => t.status == local_models.BookingStatus.completed)
      .fold(0.0, (sum, t) => sum + t.netEarnings);

  /// Returns average rating
  double get averageRating {
    final ratedTrips = currentTrips.where((t) => t.rating != null).toList();
    if (ratedTrips.isEmpty) return 0.0;
    
    final totalRating = ratedTrips.fold(0.0, (sum, t) => sum + (t.rating ?? 0.0));
    return totalRating / ratedTrips.length;
  }

  /// Returns total distance from completed trips
  double get totalDistance => currentTrips
      .where((t) => t.status == local_models.BookingStatus.completed)
      .fold(0.0, (sum, t) => sum + t.distanceKm);

  /// Returns total duration from completed trips (in minutes)
  int get totalDuration => currentTrips
      .where((t) => t.status == local_models.BookingStatus.completed)
      .fold(0, (sum, t) => sum + t.durationMinutes);

  /// Returns cash trips count
  int get cashTripsCount => currentTrips.where((t) => t.paymentMode == local_models.PaymentMode.cash).length;

  /// Returns online trips count
  int get onlineTripsCount => currentTrips.where((t) => t.paymentMode == local_models.PaymentMode.online).length;

  TripHistoryState copyWith({
    TripHistoryData? tripHistoryData,
    local_models.Booking? selectedTrip,
    TripStatistics? statistics,
    TripHistoryFilter? currentFilter,
    String? searchQuery,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool? isLoadingMore,
    bool? hasReachedMax,
    bool clearError = false,
  }) {
    return TripHistoryState(
      tripHistoryData: tripHistoryData ?? this.tripHistoryData,
      selectedTrip: selectedTrip ?? this.selectedTrip,
      statistics: statistics ?? this.statistics,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        tripHistoryData,
        selectedTrip,
        statistics,
        currentFilter,
        searchQuery,
        status,
        errorMessage,
        isLoadingMore,
        hasReachedMax,
      ];

  @override
  String toString() {
    return 'TripHistoryState('
        'trips: ${currentTrips.length}, '
        'selectedTrip: $selectedTrip, '
        'statistics: $statistics, '
        'currentFilter: $currentFilter, '
        'searchQuery: $searchQuery, '
        'status: $status, '
        'errorMessage: $errorMessage, '
        'isLoadingMore: $isLoadingMore, '
        'hasReachedMax: $hasReachedMax'
        ')';
  }
}

/// Trip history filter model
class TripHistoryFilter extends Equatable {
  const TripHistoryFilter({
    this.status,
    this.startDate,
    this.endDate,
    this.paymentMode,
    this.period,
  });

  final trip_repo.BookingStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final local_models.PaymentMode? paymentMode;
  final String? period;

  TripHistoryFilter copyWith({
    trip_repo.BookingStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    local_models.PaymentMode? paymentMode,
    String? period,
  }) {
    return TripHistoryFilter(
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentMode: paymentMode ?? this.paymentMode,
      period: period ?? this.period,
    );
  }

  @override
  List<Object?> get props => [status, startDate, endDate, paymentMode, period];
}
