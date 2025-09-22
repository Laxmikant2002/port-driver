part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentData extends PaymentEvent {
  const LoadPaymentData();
}

class InitiateWithdrawal extends PaymentEvent {
  final double amount;
  final String bankAccountId;
  final String? notes;

  const InitiateWithdrawal({
    required this.amount,
    required this.bankAccountId,
    this.notes,
  });

  @override
  List<Object?> get props => [amount, bankAccountId, notes];
}

class FilterTransactions extends PaymentEvent {
  final String? type;

  const FilterTransactions({this.type});

  @override
  List<Object?> get props => [type];
}