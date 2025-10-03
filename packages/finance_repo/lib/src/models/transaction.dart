import 'package:equatable/equatable.dart';

/// Transaction model for wallet transactions
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    this.description,
    this.referenceId,
    this.fee,
    this.netAmount,
    this.metadata,
  });

  final String id;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? description;
  final String? referenceId;
  final double? fee;
  final double? netAmount;
  final Map<String, dynamic>? metadata;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.fromString(json['type'] as String),
      status: TransactionStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      referenceId: json['referenceId'] as String?,
      fee: json['fee'] != null ? (json['fee'] as num).toDouble() : null,
      netAmount: json['netAmount'] != null ? (json['netAmount'] as num).toDouble() : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.value,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'referenceId': referenceId,
      'fee': fee,
      'netAmount': netAmount,
      'metadata': metadata,
    };
  }

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? createdAt,
    String? description,
    String? referenceId,
    double? fee,
    double? netAmount,
    Map<String, dynamic>? metadata,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      referenceId: referenceId ?? this.referenceId,
      fee: fee ?? this.fee,
      netAmount: netAmount ?? this.netAmount,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        status,
        createdAt,
        description,
        referenceId,
        fee,
        netAmount,
        metadata,
      ];

  @override
  String toString() {
    return 'Transaction('
        'id: $id, '
        'amount: $amount, '
        'type: $type, '
        'status: $status, '
        'createdAt: $createdAt'
        ')';
  }
}

/// Transaction types
enum TransactionType {
  earning('earning', 'Earning'),
  withdrawal('withdrawal', 'Withdrawal'),
  bonus('bonus', 'Bonus'),
  penalty('penalty', 'Penalty'),
  refund('refund', 'Refund'),
  adjustment('adjustment', 'Adjustment');

  const TransactionType(this.value, this.displayName);

  final String value;
  final String displayName;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown transaction type: $value'),
    );
  }
}

/// Transaction status
enum TransactionStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed'),
  cancelled('cancelled', 'Cancelled');

  const TransactionStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown transaction status: $value'),
    );
  }
}

/// Wallet balance model
class WalletBalance extends Equatable {
  const WalletBalance({
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalEarnings,
    required this.totalWithdrawals,
    this.currency = 'USD',
    this.lastUpdated,
    this.totalTrips,
    this.onlineEarnings,
    this.cashCollected,
    this.commissionPercentage,
    this.totalCommission,
    this.netEarnings,
    this.payoutStatus,
    this.lastPayoutAmount,
    this.lastPayoutDate,
  });

  final double availableBalance;
  final double pendingBalance;
  final double totalEarnings;
  final double totalWithdrawals;
  final String currency;
  final DateTime? lastUpdated;
  final int? totalTrips;
  final double? onlineEarnings;
  final double? cashCollected;
  final double? commissionPercentage;
  final double? totalCommission;
  final double? netEarnings;
  final String? payoutStatus;
  final double? lastPayoutAmount;
  final DateTime? lastPayoutDate;

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      availableBalance: (json['availableBalance'] as num).toDouble(),
      pendingBalance: (json['pendingBalance'] as num).toDouble(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      totalWithdrawals: (json['totalWithdrawals'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String) 
          : null,
      totalTrips: json['totalTrips'] as int?,
      onlineEarnings: (json['onlineEarnings'] as num?)?.toDouble(),
      cashCollected: (json['cashCollected'] as num?)?.toDouble(),
      commissionPercentage: (json['commissionPercentage'] as num?)?.toDouble(),
      totalCommission: (json['totalCommission'] as num?)?.toDouble(),
      netEarnings: (json['netEarnings'] as num?)?.toDouble(),
      payoutStatus: json['payoutStatus'] as String?,
      lastPayoutAmount: (json['lastPayoutAmount'] as num?)?.toDouble(),
      lastPayoutDate: json['lastPayoutDate'] != null 
          ? DateTime.parse(json['lastPayoutDate'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableBalance': availableBalance,
      'pendingBalance': pendingBalance,
      'totalEarnings': totalEarnings,
      'totalWithdrawals': totalWithdrawals,
      'currency': currency,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'totalTrips': totalTrips,
      'onlineEarnings': onlineEarnings,
      'cashCollected': cashCollected,
      'commissionPercentage': commissionPercentage,
      'totalCommission': totalCommission,
      'netEarnings': netEarnings,
      'payoutStatus': payoutStatus,
      'lastPayoutAmount': lastPayoutAmount,
      'lastPayoutDate': lastPayoutDate?.toIso8601String(),
    };
  }

  WalletBalance copyWith({
    double? availableBalance,
    double? pendingBalance,
    double? totalEarnings,
    double? totalWithdrawals,
    String? currency,
    DateTime? lastUpdated,
    int? totalTrips,
    double? onlineEarnings,
    double? cashCollected,
    double? commissionPercentage,
    double? totalCommission,
    double? netEarnings,
    String? payoutStatus,
    double? lastPayoutAmount,
    DateTime? lastPayoutDate,
  }) {
    return WalletBalance(
      availableBalance: availableBalance ?? this.availableBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalTrips: totalTrips ?? this.totalTrips,
      onlineEarnings: onlineEarnings ?? this.onlineEarnings,
      cashCollected: cashCollected ?? this.cashCollected,
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      totalCommission: totalCommission ?? this.totalCommission,
      netEarnings: netEarnings ?? this.netEarnings,
      payoutStatus: payoutStatus ?? this.payoutStatus,
      lastPayoutAmount: lastPayoutAmount ?? this.lastPayoutAmount,
      lastPayoutDate: lastPayoutDate ?? this.lastPayoutDate,
    );
  }

  @override
  List<Object?> get props => [
        availableBalance,
        pendingBalance,
        totalEarnings,
        totalWithdrawals,
        currency,
        lastUpdated,
        totalTrips,
        onlineEarnings,
        cashCollected,
        commissionPercentage,
        totalCommission,
        netEarnings,
        payoutStatus,
        lastPayoutAmount,
        lastPayoutDate,
      ];
}
