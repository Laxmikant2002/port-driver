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
  });

  final double availableBalance;
  final double pendingBalance;
  final double totalEarnings;
  final double totalWithdrawals;
  final String currency;
  final DateTime? lastUpdated;

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
    };
  }

  WalletBalance copyWith({
    double? availableBalance,
    double? pendingBalance,
    double? totalEarnings,
    double? totalWithdrawals,
    String? currency,
    DateTime? lastUpdated,
  }) {
    return WalletBalance(
      availableBalance: availableBalance ?? this.availableBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
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
      ];
}
