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
  final String paymentMethod;
  final String bankAccountId; // Add this property

  const InitiateWithdrawal({
    required this.amount,
    required this.paymentMethod,
    required this.bankAccountId, // Include in constructor
  });

  @override
  List<Object> get props => [amount, paymentMethod, bankAccountId]; // Add to props
}

class FilterTransactions extends PaymentEvent {
  final String type;

  const FilterTransactions({required this.type});

  @override
  List<Object?> get props => [type];
}