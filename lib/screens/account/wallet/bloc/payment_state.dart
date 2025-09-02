part of 'payment_bloc.dart';

class PaymentState extends Equatable {
  final double totalEarnings;
  final double totalWithdrawals;
  final double availableBalance;
  final List<Transaction> transactions;
  final FormzSubmissionStatus status;
  final String? error;
  final String note;
  

  const PaymentState({
    this.totalEarnings = 0.0,
    this.totalWithdrawals = 0.0,
    this.availableBalance = 0.0,
    this.transactions = const [],
    this.status = FormzSubmissionStatus.initial,
    this.error,
    this.note = '',
  });

  PaymentState copyWith({
    double? totalEarnings,
    double? totalWithdrawals,
    double? availableBalance,
    List<Transaction>? transactions,
    FormzSubmissionStatus? status,
    String? error,
    String? note,
  }) {
    return PaymentState(
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      availableBalance: availableBalance ?? this.availableBalance,
      transactions: transactions ?? this.transactions,
      status: status ?? this.status,
      error: error ?? this.error,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        totalEarnings,
        totalWithdrawals,
        availableBalance,
        transactions,
        status,
        error,
        note,
      ];
}

class Transaction extends Equatable {
  final String id;
  final double amount;
  final String type;
  final String status;
  final String method;
  final DateTime date;
  final String note;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.method,
    required this.date,
    required this.note,
  });

  @override
  List<Object> get props => [id, amount, type, status, method, date, note];
}
