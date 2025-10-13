import 'package:equatable/equatable.dart';
import 'package:trip_repo/trip_repo.dart' as trip_repo;
import 'package:finance_repo/finance_repo.dart';
import 'package:driver/models/booking.dart' as local_models;

/// Service for managing trip history data
/// Integrates with trip_repo and finance_repo for comprehensive trip data
class TripHistoryService {
  const TripHistoryService({
    required this.tripRepo,
    required this.financeRepo,
  });

  final trip_repo.TripRepo tripRepo;
  final FinanceRepo financeRepo;

  /// Fetch comprehensive trip history data
  Future<TripHistoryData> getTripHistory({
    int? limit,
    int? offset,
    trip_repo.BookingStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Fetch bookings from trip_repo
      final tripsResponse = await tripRepo.getTripHistory(
        page: ((offset ?? 0) ~/ (limit ?? 20)) + 1,
        limit: limit ?? 20,
      );

      if (!tripsResponse.success || tripsResponse.trips == null) {
        throw Exception(tripsResponse.message ?? 'Failed to fetch trips');
      }

      // Convert trip_repo trips to local models
      final localBookings = tripsResponse.trips!
          .map((trip_repo.Trip trip) => _convertTripRepoToLocal(trip))
          .toList();

      // Fetch transaction history for earnings data
      final transactionsResponse = await financeRepo.getTransactions(
        limit: limit ?? 20,
        offset: offset ?? 0,
        startDate: startDate,
        endDate: endDate,
      );

      final List<Transaction> transactions = [];
      if (transactionsResponse.success && transactionsResponse.transactions != null) {
        transactions.addAll(transactionsResponse.transactions!);
      }

      // Calculate statistics
      final statistics = _calculateStatistics(localBookings, transactions);

      return TripHistoryData(
        bookings: localBookings,
        transactions: transactions,
        statistics: statistics,
        hasMore: localBookings.length == (limit ?? 20),
        totalCount: localBookings.length,
      );
    } catch (e) {
      throw Exception('Failed to fetch trip history: $e');
    }
  }

  /// Get trip details by ID
  Future<local_models.Booking?> getTripDetails(String tripId) async {
    try {
      final response = await tripRepo.getBooking(tripId);
      
      if (response.success && response.booking != null) {
        // Convert BookingResponse to Trip and then to local model
        final trip = trip_repo.Trip(
          id: response.booking!.id,
          bookingId: response.booking!.id,
          driverId: response.booking!.driverId ?? '',
          passengerId: response.booking!.passengerId ?? '',
          status: trip_repo.TripStatus.completed, // Default status
          startLocation: trip_repo.TripLocation(
            address: response.booking!.pickupLocation.address,
            latitude: response.booking!.pickupLocation.latitude,
            longitude: response.booking!.pickupLocation.longitude,
          ),
          endLocation: trip_repo.TripLocation(
            address: response.booking!.dropoffLocation.address,
            latitude: response.booking!.dropoffLocation.latitude,
            longitude: response.booking!.dropoffLocation.longitude,
          ),
          fare: response.booking!.fare,
          distance: response.booking!.distance,
          duration: response.booking!.estimatedDuration,
          createdAt: response.booking!.createdAt,
          passengerName: response.booking!.passengerName,
          passengerPhone: response.booking!.passengerPhone,
          vehicleType: response.booking!.vehicleType,
          paymentMethod: response.booking!.paymentMethod,
          completedAt: response.booking!.completedAt,
          rating: response.booking!.rating,
        );

        return _convertTripRepoToLocal(trip);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to fetch trip details: $e');
    }
  }

  /// Get trip statistics for a specific period
  Future<TripStatistics> getTripStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String? period,
  }) async {
    try {
      final tripsResponse = await tripRepo.getTripHistory(
        page: 1,
        limit: 100, // Get more trips for statistics
      );

      if (!tripsResponse.success || tripsResponse.trips == null) {
        throw Exception('Failed to fetch trips for statistics');
      }

      final localBookings = tripsResponse.trips!
          .map((trip_repo.Trip trip) => _convertTripRepoToLocal(trip))
          .toList();

      // Fetch transaction history for earnings
      final transactionsResponse = await financeRepo.getTransactions(
        startDate: startDate,
        endDate: endDate,
      );

      final List<Transaction> transactions = [];
      if (transactionsResponse.success && transactionsResponse.transactions != null) {
        transactions.addAll(transactionsResponse.transactions!);
      }

      return _calculateStatistics(localBookings, transactions);
    } catch (e) {
      throw Exception('Failed to fetch trip statistics: $e');
    }
  }

  /// Convert trip_repo.Trip to local_models.Booking
  local_models.Booking _convertTripRepoToLocal(trip_repo.Trip trip) {
    return local_models.Booking(
      id: trip.id,
      passengerId: trip.passengerId,
      driverId: trip.driverId,
      status: _convertTripStatus(trip.status),
      pickupLocation: local_models.BookingLocation(
        address: trip.startLocation.address ?? '',
        latitude: trip.startLocation.latitude,
        longitude: trip.startLocation.longitude,
        landmark: null, // TripLocation doesn't have landmark
      ),
      dropoffLocation: local_models.BookingLocation(
        address: trip.endLocation.address ?? '',
        latitude: trip.endLocation.latitude,
        longitude: trip.endLocation.longitude,
        landmark: null, // TripLocation doesn't have landmark
      ),
      fare: trip.fare,
      distance: trip.distance,
      estimatedDuration: trip.duration,
      createdAt: trip.createdAt,
      passengerName: trip.passengerName,
      passengerPhone: trip.passengerPhone,
      passengerPhoto: trip.passengerPhoto,
      vehicleType: trip.vehicleType,
      paymentMethod: trip.paymentMethod,
      scheduledTime: null,
      acceptedAt: null,
      startedAt: trip.startedAt,
      completedAt: trip.completedAt,
      cancelledAt: null,
      cancellationReason: null,
      rating: trip.rating,
      metadata: trip.metadata,
      // Derived properties for local model
      amount: trip.fare,
      paymentMode: _convertPaymentMethod(trip.paymentMethod),
      paymentStatus: _convertTripStatusToPaymentStatus(trip.status),
      netEarnings: trip.fare * 0.85, // 85% net earnings
      commission: trip.fare * 0.15, // 15% commission
      distanceKm: trip.distance,
      durationMinutes: trip.duration,
      pickupAddress: trip.startLocation.address ?? '',
      dropoffAddress: trip.endLocation.address ?? '',
      customerName: trip.passengerName ?? 'Unknown Passenger',
    );
  }

  /// Convert trip_repo.TripStatus to local_models.BookingStatus
  local_models.BookingStatus _convertTripStatus(trip_repo.TripStatus status) {
    switch (status) {
      case trip_repo.TripStatus.active:
        return local_models.BookingStatus.started;
      case trip_repo.TripStatus.completed:
        return local_models.BookingStatus.completed;
      case trip_repo.TripStatus.cancelled:
        return local_models.BookingStatus.cancelled;
    }
  }

  /// Convert payment method string to local_models.PaymentMode
  local_models.PaymentMode _convertPaymentMethod(String? paymentMethod) {
    switch (paymentMethod?.toLowerCase()) {
      case 'cash':
        return local_models.PaymentMode.cash;
      case 'online':
        return local_models.PaymentMode.online;
      case 'card':
        return local_models.PaymentMode.card;
      case 'wallet':
        return local_models.PaymentMode.wallet;
      case null:
        return local_models.PaymentMode.cash;
      default:
        return local_models.PaymentMode.cash;
    }
  }

  /// Convert trip status to payment status
  local_models.PaymentStatus _convertTripStatusToPaymentStatus(trip_repo.TripStatus status) {
    switch (status) {
      case trip_repo.TripStatus.completed:
        return local_models.PaymentStatus.completed;
      case trip_repo.TripStatus.cancelled:
        return local_models.PaymentStatus.failed;
      case trip_repo.TripStatus.active:
        return local_models.PaymentStatus.pending;
    }
  }

  /// Calculate comprehensive trip statistics
  TripStatistics _calculateStatistics(
    List<local_models.Booking> bookings,
    List<Transaction> transactions,
  ) {
    final completedBookings = bookings.where((b) => b.status == local_models.BookingStatus.completed).toList();
    final cancelledBookings = bookings.where((b) => b.status == local_models.BookingStatus.cancelled).toList();
    
    final totalEarnings = transactions
        .where((t) => t.type == TransactionType.earning)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final averageRating = completedBookings
        .where((b) => b.rating != null)
        .fold(0.0, (sum, b) => sum + (b.rating ?? 0.0)) / 
        completedBookings.where((b) => b.rating != null).length;
    
    final totalDistance = completedBookings.fold(0.0, (sum, b) => sum + b.distanceKm);
    final totalDuration = completedBookings.fold(0, (sum, b) => sum + b.durationMinutes);

    return TripStatistics(
      totalTrips: bookings.length,
      completedTrips: completedBookings.length,
      cancelledTrips: cancelledBookings.length,
      totalEarnings: totalEarnings,
      averageRating: averageRating.isNaN ? 0.0 : averageRating,
      totalDistance: totalDistance,
      totalDuration: totalDuration,
      period: 'All Time',
    );
  }
}

/// Comprehensive trip history data model
class TripHistoryData extends Equatable {
  const TripHistoryData({
    required this.bookings,
    required this.transactions,
    required this.statistics,
    required this.hasMore,
    required this.totalCount,
  });

  final List<local_models.Booking> bookings;
  final List<Transaction> transactions;
  final TripStatistics statistics;
  final bool hasMore;
  final int totalCount;

  @override
  List<Object?> get props => [bookings, transactions, statistics, hasMore, totalCount];
}

/// Trip statistics model
class TripStatistics extends Equatable {
  const TripStatistics({
    required this.totalTrips,
    required this.completedTrips,
    required this.cancelledTrips,
    required this.totalEarnings,
    required this.averageRating,
    required this.totalDistance,
    required this.totalDuration,
    this.period,
  });

  final int totalTrips;
  final int completedTrips;
  final int cancelledTrips;
  final double totalEarnings;
  final double averageRating;
  final double totalDistance;
  final int totalDuration; // in minutes
  final String? period;

  @override
  List<Object?> get props => [
        totalTrips,
        completedTrips,
        cancelledTrips,
        totalEarnings,
        averageRating,
        totalDistance,
        totalDuration,
        period,
      ];
}
