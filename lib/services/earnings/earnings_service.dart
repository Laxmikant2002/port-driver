import 'package:finance_repo/finance_repo.dart';
import 'package:trip_repo/trip_repo.dart' as trip_repo;
import 'package:equatable/equatable.dart';
import 'package:driver/core/error/error_handler.dart';
import 'package:driver/core/extensions/extensions.dart';
import 'package:driver/models/booking.dart' as local_models;
import 'package:driver/services/earnings/unified_earnings_rewards_service.dart';
import 'package:intl/intl.dart';

/// Modern earnings service that integrates with backend packages
class EarningsService {
  const EarningsService({
    required this.financeRepo,
    required this.tripRepo,
  });

  final FinanceRepo financeRepo;
  final trip_repo.TripRepo tripRepo;

  /// Get comprehensive earnings data for a date range
  Future<EarningsData> getEarningsData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get earnings summary from finance repo
      final earningsResponse = await financeRepo.getEarningsSummary(
        startDate: startDate,
        endDate: endDate,
      );

      if (!earningsResponse.success) {
        throw Exception(earningsResponse.message ?? 'Failed to fetch earnings');
      }

      // Get wallet balance
      final walletResponse = await financeRepo.getWalletBalance();
      if (!walletResponse.success) {
        throw Exception(walletResponse.message ?? 'Failed to fetch wallet balance');
      }

      // Get recent transactions
      final transactionsResponse = await financeRepo.getTransactions(
        limit: 20,
        type: TransactionType.earning,
        startDate: startDate,
        endDate: endDate,
      );

      // Get cash trips
      final cashTripsResponse = await tripRepo.getCashTrips(date: endDate);

      // Build earnings data
      final earningsData = EarningsData(
        summary: EarningsSummary(
          totalEarnings: earningsResponse.balance?.totalEarnings ?? 0.0,
          totalTrips: earningsResponse.balance?.totalTrips ?? 0,
          onlineEarnings: earningsResponse.balance?.onlineEarnings ?? 0.0,
          cashEarnings: earningsResponse.balance?.cashCollected ?? 0.0,
          commissionPercentage: earningsResponse.balance?.commissionPercentage ?? 0.0,
          totalCommission: earningsResponse.balance?.totalCommission ?? 0.0,
          netEarnings: earningsResponse.balance?.netEarnings ?? 0.0,
          availableBalance: walletResponse.balance?.availableBalance ?? 0.0,
          pendingBalance: walletResponse.balance?.pendingBalance ?? 0.0,
          payoutStatus: _parsePayoutStatus(walletResponse.balance?.payoutStatus) ?? PayoutStatus.pending,
          lastPayoutAmount: walletResponse.balance?.lastPayoutAmount ?? 0.0,
          lastPayoutDate: walletResponse.balance?.lastPayoutDate,
          currency: walletResponse.balance?.currency ?? '₹',
        ),
        recentTrips: cashTripsResponse.success && cashTripsResponse.bookings != null
            ? cashTripsResponse.bookings!
                .map((b) => _convertTripRepoBookingToLocal(b))
                .toList()
            : <local_models.Booking>[],
        cashTrips: cashTripsResponse.success && cashTripsResponse.bookings != null
            ? cashTripsResponse.bookings!
                .map((b) => _convertTripRepoBookingToLocal(b))
                .toList()
            : <local_models.Booking>[],
        transactionHistory: transactionsResponse.success && transactionsResponse.transactions != null
            ? transactionsResponse.transactions!
            : <Transaction>[],
      );

      return earningsData;
    } catch (e) {
      throw Exception('Failed to fetch earnings data: ${e.toString()}');
    }
  }

  /// Get today's earnings
  Future<EarningsData> getTodayEarnings() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getEarningsData(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get this week's earnings
  Future<EarningsData> getWeekEarnings() async {
    final now = DateTime.now();
    final weekDay = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekDay - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getEarningsData(startDate: startOfWeekDate, endDate: endOfDay);
  }

  /// Get this month's earnings
  Future<EarningsData> getMonthEarnings() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getEarningsData(startDate: startOfMonth, endDate: endOfDay);
  }

  /// Request payout
  Future<void> requestPayout(double amount) async {
    try {
      final response = await financeRepo.requestPayout(amount: amount);
      
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to request payout');
      }
    } catch (e) {
      throw Exception('Failed to request payout: ${e.toString()}');
    }
  }

  /// Mark cash trip as collected
  Future<void> markCashCollected(String tripId, double amount) async {
    try {
      final response = await tripRepo.markCashCollected(tripId, amount);
      
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to mark cash collected');
      }
    } catch (e) {
      throw Exception('Failed to mark cash collected: ${e.toString()}');
    }
  }

  /// Get transaction history with pagination
  Future<List<Transaction>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await financeRepo.getTransactions(
        limit: limit,
        offset: (page - 1) * limit,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to fetch transactions');
      }

      return response.transactions ?? [];
    } catch (e) {
      throw Exception('Failed to fetch transaction history: ${e.toString()}');
    }
  }

  /// Convert trip_repo Booking to local Booking model
  local_models.Booking _convertTripRepoBookingToLocal(trip_repo.Booking tripBooking) {
    return local_models.Booking(
      id: tripBooking.id,
      status: _convertBookingStatus(tripBooking.status),
      pickupLocation: local_models.BookingLocation(
        address: tripBooking.pickupLocation.address,
        latitude: tripBooking.pickupLocation.latitude,
        longitude: tripBooking.pickupLocation.longitude,
        landmark: tripBooking.pickupLocation.landmark,
      ),
      dropoffLocation: local_models.BookingLocation(
        address: tripBooking.dropoffLocation.address,
        latitude: tripBooking.dropoffLocation.latitude,
        longitude: tripBooking.dropoffLocation.longitude,
        landmark: tripBooking.dropoffLocation.landmark,
      ),
      fare: tripBooking.fare,
      distance: tripBooking.distance,
      estimatedDuration: tripBooking.estimatedDuration,
      createdAt: tripBooking.createdAt,
      // Derived properties
      amount: tripBooking.fare,
      paymentMode: local_models.PaymentMode.cash, // Default to cash
      paymentStatus: local_models.PaymentStatus.pending, // Default to pending
      netEarnings: tripBooking.fare * 0.8, // Assume 20% commission
      commission: tripBooking.fare * 0.2, // Assume 20% commission
      distanceKm: tripBooking.distance,
      durationMinutes: tripBooking.estimatedDuration,
      pickupAddress: tripBooking.pickupLocation.address,
      dropoffAddress: tripBooking.dropoffLocation.address,
      customerName: tripBooking.passengerName ?? 'Unknown',
    );
  }

  /// Convert trip_repo Trip to local Booking model
  local_models.Booking _convertTripRepoTripToLocal(trip_repo.Trip trip) {
    return local_models.Booking(
      id: trip.id,
      status: _convertTripStatus(trip.status),
      pickupLocation: local_models.BookingLocation(
        address: trip.startLocation.address ?? 'Unknown Location',
        latitude: trip.startLocation.latitude,
        longitude: trip.startLocation.longitude,
        landmark: null, // TripLocation doesn't have landmark
      ),
      dropoffLocation: local_models.BookingLocation(
        address: trip.endLocation.address ?? 'Unknown Location',
        latitude: trip.endLocation.latitude,
        longitude: trip.endLocation.longitude,
        landmark: null, // TripLocation doesn't have landmark
      ),
      fare: trip.fare,
      distance: trip.distance,
      estimatedDuration: trip.duration, // Use duration instead of estimatedDuration
      createdAt: trip.createdAt,
      // Derived properties
      amount: trip.fare,
      paymentMode: local_models.PaymentMode.cash, // Default to cash
      paymentStatus: local_models.PaymentStatus.pending, // Default to pending
      netEarnings: trip.fare * 0.8, // Assume 20% commission
      commission: trip.fare * 0.2, // Assume 20% commission
      distanceKm: trip.distance,
      durationMinutes: trip.duration,
      pickupAddress: trip.startLocation.address ?? 'Unknown Location',
      dropoffAddress: trip.endLocation.address ?? 'Unknown Location',
      customerName: trip.passengerName ?? 'Unknown',
    );
  }

  /// Convert trip_repo BookingStatus to local BookingStatus
  local_models.BookingStatus _convertBookingStatus(trip_repo.BookingStatus status) {
    switch (status) {
      case trip_repo.BookingStatus.pending:
        return local_models.BookingStatus.pending;
      case trip_repo.BookingStatus.accepted:
        return local_models.BookingStatus.accepted;
      case trip_repo.BookingStatus.started:
        return local_models.BookingStatus.started;
      case trip_repo.BookingStatus.completed:
        return local_models.BookingStatus.completed;
      case trip_repo.BookingStatus.cancelled:
        return local_models.BookingStatus.cancelled;
    }
  }

  /// Convert trip_repo TripStatus to local BookingStatus
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
}

/// Comprehensive earnings data model
class EarningsData extends Equatable {
  const EarningsData({
    required this.summary,
    this.recentTrips = const [],
    this.cashTrips = const [],
    this.transactionHistory = const [],
  });

  final EarningsSummary summary;
  final List<local_models.Booking> recentTrips;
  final List<local_models.Booking> cashTrips;
  final List<Transaction> transactionHistory;

  @override
  List<Object?> get props => [summary, recentTrips, cashTrips, transactionHistory];
}

/// Earnings summary model
class EarningsSummary extends Equatable {
  const EarningsSummary({
    required this.totalEarnings,
    required this.totalTrips,
    required this.onlineEarnings,
    required this.cashEarnings,
    required this.commissionPercentage,
    required this.totalCommission,
    required this.netEarnings,
    required this.availableBalance,
    required this.pendingBalance,
    required this.payoutStatus,
    required this.lastPayoutAmount,
    this.lastPayoutDate,
    this.currency = '₹',
  });

  final double totalEarnings;
  final int totalTrips;
  final double onlineEarnings;
  final double cashEarnings;
  final double commissionPercentage;
  final double totalCommission;
  final double netEarnings;
  final double availableBalance;
  final double pendingBalance;
  final PayoutStatus payoutStatus;
  final double lastPayoutAmount;
  final DateTime? lastPayoutDate;
  final String currency;

  /// Average earnings per trip
  double get averagePerTrip {
    if (totalTrips == 0) return 0.0;
    return netEarnings / totalTrips;
  }

  @override
  List<Object?> get props => [
        totalEarnings,
        totalTrips,
        onlineEarnings,
        cashEarnings,
        commissionPercentage,
        totalCommission,
        netEarnings,
        availableBalance,
        pendingBalance,
        payoutStatus,
        lastPayoutAmount,
        lastPayoutDate,
        currency,
      ];
}

/// Helper method to parse payout status string to enum
PayoutStatus? _parsePayoutStatus(String? status) {
  if (status == null) return null;
  
  switch (status.toLowerCase()) {
    case 'none':
      return PayoutStatus.none;
    case 'pending':
      return PayoutStatus.pending;
    case 'processing':
      return PayoutStatus.processing;
    case 'completed':
      return PayoutStatus.completed;
    case 'failed':
      return PayoutStatus.failed;
    default:
      return PayoutStatus.pending;
  }
}