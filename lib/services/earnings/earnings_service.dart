import 'package:finance_repo/finance_repo.dart';
import 'package:trip_repo/trip_repo.dart' as trip_repo;
import 'package:equatable/equatable.dart';
import 'package:driver/core/error/error_handler.dart';
import 'package:driver/core/extensions/extensions.dart';
import 'package:driver/models/booking.dart' as local_models;

/// Modern earnings service that integrates with backend packages
class EarningsService {
  const EarningsService({
    required this.financeRepo,
    required this.tripRepo,
  });

  final FinanceRepo financeRepo;
  final TripRepo tripRepo;

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
          payoutStatus: walletResponse.balance?.payoutStatus ?? PayoutStatus.pending,
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
    return getEarningsData(startDate: now.startOfDay, endDate: now.endOfDay);
  }

  /// Get this week's earnings
  Future<EarningsData> getWeekEarnings() async {
    final now = DateTime.now();
    return getEarningsData(startDate: now.startOfWeek, endDate: now.endOfDay);
  }

  /// Get this month's earnings
  Future<EarningsData> getMonthEarnings() async {
    final now = DateTime.now();
    return getEarningsData(startDate: now.startOfMonth, endDate: now.endOfDay);
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
      customerName: tripBooking.passengerName ?? 'Unknown',
      customerPhone: tripBooking.passengerPhone ?? '',
      peopleCount: 1, // Default to 1 passenger
      amount: tripBooking.fare,
      status: _convertBookingStatus(tripBooking.status),
      createdAt: tripBooking.createdAt,
      paymentMode: tripBooking.paymentMethod == 'cash' 
          ? local_models.PaymentMode.cash 
          : local_models.PaymentMode.online,
      paymentStatus: tripBooking.status == trip_repo.BookingStatus.completed
          ? local_models.PaymentStatus.completed
          : local_models.PaymentStatus.pending,
      fare: tripBooking.fare,
      distanceKm: tripBooking.distance,
      durationMinutes: tripBooking.estimatedDuration,
    );
  }

  /// Convert trip_repo Trip to local Booking model
  local_models.Booking _convertTripRepoTripToLocal(trip_repo.Trip trip) {
    return local_models.Booking(
      id: trip.id,
      customerName: trip.passengerName ?? 'Unknown',
      customerPhone: trip.passengerPhone ?? '',
      peopleCount: 1, // Default to 1 passenger
      amount: trip.fare,
      status: _convertTripStatus(trip.status),
      createdAt: trip.createdAt,
      paymentMode: trip.paymentMethod == 'cash' 
          ? local_models.PaymentMode.cash 
          : local_models.PaymentMode.online,
      paymentStatus: trip.status == trip_repo.TripStatus.completed
          ? local_models.PaymentStatus.completed
          : local_models.PaymentStatus.pending,
      fare: trip.fare,
      distanceKm: trip.distance,
      durationMinutes: trip.estimatedDuration,
    );
  }

  /// Convert trip_repo BookingStatus to local BookingStatus
  local_models.BookingStatus _convertBookingStatus(trip_repo.BookingStatus status) {
    switch (status) {
      case trip_repo.BookingStatus.pending:
        return local_models.BookingStatus.confirmed;
      case trip_repo.BookingStatus.accepted:
        return local_models.BookingStatus.checkedIn;
      case trip_repo.BookingStatus.started:
        return local_models.BookingStatus.checkedIn;
      case trip_repo.BookingStatus.completed:
        return local_models.BookingStatus.completed;
      case trip_repo.BookingStatus.cancelled:
        return local_models.BookingStatus.cancelled;
    }
  }

  /// Convert trip_repo TripStatus to local BookingStatus
  local_models.BookingStatus _convertTripStatus(trip_repo.TripStatus status) {
    switch (status) {
      case trip_repo.TripStatus.pending:
        return local_models.BookingStatus.confirmed;
      case trip_repo.TripStatus.accepted:
        return local_models.BookingStatus.checkedIn;
      case trip_repo.TripStatus.started:
        return local_models.BookingStatus.checkedIn;
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