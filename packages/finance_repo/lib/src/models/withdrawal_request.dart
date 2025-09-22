import 'package:equatable/equatable.dart';

/// Withdrawal request model
class WithdrawalRequest extends Equatable {
  const WithdrawalRequest({
    required this.amount,
    required this.bankAccountId,
    this.notes,
    this.metadata,
  });

  final double amount;
  final String bankAccountId;
  final String? notes;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'bankAccountId': bankAccountId,
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      amount: (json['amount'] as num).toDouble(),
      bankAccountId: json['bankAccountId'] as String,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  WithdrawalRequest copyWith({
    double? amount,
    String? bankAccountId,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return WithdrawalRequest(
      amount: amount ?? this.amount,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [amount, bankAccountId, notes, metadata];

  @override
  String toString() {
    return 'WithdrawalRequest(amount: $amount, bankAccountId: $bankAccountId)';
  }
}
