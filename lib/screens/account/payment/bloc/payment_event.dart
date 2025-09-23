part of 'payment_bloc.dart';

/// Base class for all Payment events
sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when amount is changed
final class PaymentAmountChanged extends PaymentEvent {
  const PaymentAmountChanged(this.amount);

  final String amount;

  @override
  List<Object> get props => [amount];

  @override
  String toString() => 'PaymentAmountChanged(amount: $amount)';
}

/// Event triggered when description is changed
final class PaymentDescriptionChanged extends PaymentEvent {
  const PaymentDescriptionChanged(this.description);

  final String description;

  @override
  List<Object> get props => [description];

  @override
  String toString() => 'PaymentDescriptionChanged(description: $description)';
}

/// Event triggered when payment method is changed
final class PaymentMethodChanged extends PaymentEvent {
  const PaymentMethodChanged(this.paymentMethod);

  final String paymentMethod;

  @override
  List<Object> get props => [paymentMethod];

  @override
  String toString() => 'PaymentMethodChanged(paymentMethod: $paymentMethod)';
}

/// Event triggered when payment form is submitted
final class PaymentSubmitted extends PaymentEvent {
  const PaymentSubmitted({this.metadata});

  final Map<String, dynamic>? metadata;

  @override
  List<Object> get props => [metadata ?? ''];

  @override
  String toString() => 'PaymentSubmitted(metadata: $metadata)';
}

/// Event triggered when payment history is loaded
final class PaymentHistoryLoaded extends PaymentEvent {
  const PaymentHistoryLoaded({
    this.limit,
    this.offset,
  });

  final int? limit;
  final int? offset;

  @override
  List<Object> get props => [limit ?? 0, offset ?? 0];

  @override
  String toString() => 'PaymentHistoryLoaded(limit: $limit, offset: $offset)';
}

/// Event triggered when payment data is refreshed
final class PaymentRefreshRequested extends PaymentEvent {
  const PaymentRefreshRequested();

  @override
  String toString() => 'PaymentRefreshRequested()';
}
