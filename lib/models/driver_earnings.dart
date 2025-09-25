import 'package:equatable/equatable.dart';

/// Model for driver earnings and settlement
class DriverEarnings extends Equatable {
  final String driverId;
  final DateTime date;
  final int totalTrips;
  final int onlineTrips;
  final int cashTrips;
  final double totalFare;
  final double totalCommission;
  final double netEarnings;
  final double cashCollected;
  final double pendingDue;
  final double onlineEarnings;
  final PayoutStatus payoutStatus;
  final DateTime? lastPayoutDate;
  final double? lastPayoutAmount;

  const DriverEarnings({
    required this.driverId,
    required this.date,
    required this.totalTrips,
    required this.onlineTrips,
    required this.cashTrips,
    required this.totalFare,
    required this.totalCommission,
    required this.netEarnings,
    required this.cashCollected,
    required this.pendingDue,
    required this.onlineEarnings,
    required this.payoutStatus,
    this.lastPayoutDate,
    this.lastPayoutAmount,
  });

  factory DriverEarnings.fromJson(Map<String, dynamic> json) {
    return DriverEarnings(
      driverId: json['driverId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalTrips: json['totalTrips'] as int,
      onlineTrips: json['onlineTrips'] as int,
      cashTrips: json['cashTrips'] as int,
      totalFare: (json['totalFare'] as num).toDouble(),
      totalCommission: (json['totalCommission'] as num).toDouble(),
      netEarnings: (json['netEarnings'] as num).toDouble(),
      cashCollected: (json['cashCollected'] as num).toDouble(),
      pendingDue: (json['pendingDue'] as num).toDouble(),
      onlineEarnings: (json['onlineEarnings'] as num).toDouble(),
      payoutStatus: PayoutStatus.values.firstWhere(
        (status) => status.value == json['payoutStatus'],
        orElse: () => PayoutStatus.pending,
      ),
      lastPayoutDate: json['lastPayoutDate'] != null
          ? DateTime.parse(json['lastPayoutDate'] as String)
          : null,
      lastPayoutAmount: json['lastPayoutAmount'] != null
          ? (json['lastPayoutAmount'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'date': date.toIso8601String(),
      'totalTrips': totalTrips,
      'onlineTrips': onlineTrips,
      'cashTrips': cashTrips,
      'totalFare': totalFare,
      'totalCommission': totalCommission,
      'netEarnings': netEarnings,
      'cashCollected': cashCollected,
      'pendingDue': pendingDue,
      'onlineEarnings': onlineEarnings,
      'payoutStatus': payoutStatus.value,
      'lastPayoutDate': lastPayoutDate?.toIso8601String(),
      'lastPayoutAmount': lastPayoutAmount,
    };
  }

  DriverEarnings copyWith({
    String? driverId,
    DateTime? date,
    int? totalTrips,
    int? onlineTrips,
    int? cashTrips,
    double? totalFare,
    double? totalCommission,
    double? netEarnings,
    double? cashCollected,
    double? pendingDue,
    double? onlineEarnings,
    PayoutStatus? payoutStatus,
    DateTime? lastPayoutDate,
    double? lastPayoutAmount,
  }) {
    return DriverEarnings(
      driverId: driverId ?? this.driverId,
      date: date ?? this.date,
      totalTrips: totalTrips ?? this.totalTrips,
      onlineTrips: onlineTrips ?? this.onlineTrips,
      cashTrips: cashTrips ?? this.cashTrips,
      totalFare: totalFare ?? this.totalFare,
      totalCommission: totalCommission ?? this.totalCommission,
      netEarnings: netEarnings ?? this.netEarnings,
      cashCollected: cashCollected ?? this.cashCollected,
      pendingDue: pendingDue ?? this.pendingDue,
      onlineEarnings: onlineEarnings ?? this.onlineEarnings,
      payoutStatus: payoutStatus ?? this.payoutStatus,
      lastPayoutDate: lastPayoutDate ?? this.lastPayoutDate,
      lastPayoutAmount: lastPayoutAmount ?? this.lastPayoutAmount,
    );
  }

  @override
  List<Object?> get props => [
        driverId,
        date,
        totalTrips,
        onlineTrips,
        cashTrips,
        totalFare,
        totalCommission,
        netEarnings,
        cashCollected,
        pendingDue,
        onlineEarnings,
        payoutStatus,
        lastPayoutDate,
        lastPayoutAmount,
      ];
}

/// Enum for payout status
enum PayoutStatus {
  pending('PENDING'),
  processing('PROCESSING'),
  completed('COMPLETED'),
  failed('FAILED');

  const PayoutStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case PayoutStatus.pending:
        return 'Pending';
      case PayoutStatus.processing:
        return 'Processing';
      case PayoutStatus.completed:
        return 'Completed';
      case PayoutStatus.failed:
        return 'Failed';
    }
  }
}

/// Model for fare calculation configuration
class FareConfig extends Equatable {
  final double baseFare;
  final double perKmRate;
  final double perMinuteRate;
  final double commissionPercentage;
  final double surgeMultiplier;
  final double minimumFare;
  final double cancellationFee;
  final Map<String, double> additionalCharges;

  const FareConfig({
    required this.baseFare,
    required this.perKmRate,
    required this.perMinuteRate,
    required this.commissionPercentage,
    this.surgeMultiplier = 1.0,
    required this.minimumFare,
    this.cancellationFee = 0.0,
    this.additionalCharges = const {},
  });

  factory FareConfig.fromJson(Map<String, dynamic> json) {
    return FareConfig(
      baseFare: (json['baseFare'] as num).toDouble(),
      perKmRate: (json['perKmRate'] as num).toDouble(),
      perMinuteRate: (json['perMinuteRate'] as num).toDouble(),
      commissionPercentage: (json['commissionPercentage'] as num).toDouble(),
      surgeMultiplier: (json['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
      minimumFare: (json['minimumFare'] as num).toDouble(),
      cancellationFee: (json['cancellationFee'] as num?)?.toDouble() ?? 0.0,
      additionalCharges: Map<String, double>.from(
        json['additionalCharges'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseFare': baseFare,
      'perKmRate': perKmRate,
      'perMinuteRate': perMinuteRate,
      'commissionPercentage': commissionPercentage,
      'surgeMultiplier': surgeMultiplier,
      'minimumFare': minimumFare,
      'cancellationFee': cancellationFee,
      'additionalCharges': additionalCharges,
    };
  }

  /// Calculate fare based on distance and duration
  double calculateFare(double distanceKm, int durationMinutes) {
    final distanceFare = distanceKm * perKmRate;
    final timeFare = durationMinutes * perMinuteRate;
    final totalFare = (baseFare + distanceFare + timeFare) * surgeMultiplier;
    
    // Add additional charges
    final additionalTotal = additionalCharges.values.fold(0.0, (sum, charge) => sum + charge);
    
    return (totalFare + additionalTotal).clamp(minimumFare, double.infinity);
  }

  /// Calculate commission amount
  double calculateCommission(double fare) {
    return fare * (commissionPercentage / 100);
  }

  /// Calculate net earnings for driver
  double calculateNetEarnings(double fare) {
    return fare - calculateCommission(fare);
  }

  FareConfig copyWith({
    double? baseFare,
    double? perKmRate,
    double? perMinuteRate,
    double? commissionPercentage,
    double? surgeMultiplier,
    double? minimumFare,
    double? cancellationFee,
    Map<String, double>? additionalCharges,
  }) {
    return FareConfig(
      baseFare: baseFare ?? this.baseFare,
      perKmRate: perKmRate ?? this.perKmRate,
      perMinuteRate: perMinuteRate ?? this.perMinuteRate,
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
      minimumFare: minimumFare ?? this.minimumFare,
      cancellationFee: cancellationFee ?? this.cancellationFee,
      additionalCharges: additionalCharges ?? this.additionalCharges,
    );
  }

  @override
  List<Object?> get props => [
        baseFare,
        perKmRate,
        perMinuteRate,
        commissionPercentage,
        surgeMultiplier,
        minimumFare,
        cancellationFee,
        additionalCharges,
      ];
}