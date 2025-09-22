import 'package:equatable/equatable.dart';
import 'transaction.dart';

/// Wallet response model for API responses
class WalletResponse extends Equatable {
  const WalletResponse({
    required this.success,
    this.message,
    this.balance,
    this.transactions,
    this.transaction,
  });

  final bool success;
  final String? message;
  final WalletBalance? balance;
  final List<Transaction>? transactions;
  final Transaction? transaction;

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      balance: json['balance'] != null
          ? WalletBalance.fromJson(json['balance'] as Map<String, dynamic>)
          : null,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List<dynamic>)
              .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      transaction: json['transaction'] != null
          ? Transaction.fromJson(json['transaction'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'balance': balance?.toJson(),
      'transactions': transactions?.map((e) => e.toJson()).toList(),
      'transaction': transaction?.toJson(),
    };
  }

  WalletResponse copyWith({
    bool? success,
    String? message,
    WalletBalance? balance,
    List<Transaction>? transactions,
    Transaction? transaction,
  }) {
    return WalletResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      transaction: transaction ?? this.transaction,
    );
  }

  @override
  List<Object?> get props => [success, message, balance, transactions, transaction];

  @override
  String toString() {
    return 'WalletResponse(success: $success, message: $message, balance: $balance, transactions: ${transactions?.length})';
  }
}
