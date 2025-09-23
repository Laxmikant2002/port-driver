part of 'payment_bloc.dart';

enum AmountValidationError { empty, invalid }

class Amount extends FormzInput<String, AmountValidationError> {
  const Amount.pure() : super.pure('');
  const Amount.dirty([super.value = '']) : super.dirty();

  @override
  AmountValidationError? validator(String value) {
    if (value.isEmpty) return AmountValidationError.empty;
    
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return AmountValidationError.invalid;
    }
    
    return null;
  }
}

enum DescriptionValidationError { empty }

class Description extends FormzInput<String, DescriptionValidationError> {
  const Description.pure() : super.pure('');
  const Description.dirty([super.value = '']) : super.dirty();

  @override
  DescriptionValidationError? validator(String value) {
    if (value.isEmpty) return DescriptionValidationError.empty;
    return null;
  }
}

enum PaymentMethodValidationError { empty }

class PaymentMethod extends FormzInput<String, PaymentMethodValidationError> {
  const PaymentMethod.pure() : super.pure('');
  const PaymentMethod.dirty([super.value = '']) : super.dirty();

  @override
  PaymentMethodValidationError? validator(String value) {
    if (value.isEmpty) return PaymentMethodValidationError.empty;
    return null;
  }
}

/// Payment state containing form data and submission status
final class PaymentState extends Equatable {
  const PaymentState({
    this.status = FormzSubmissionStatus.initial,
    this.amount = const Amount.pure(),
    this.description = const Description.pure(),
    this.paymentMethod = const PaymentMethod.pure(),
    this.paymentHistory = const [],
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final Amount amount;
  final Description description;
  final PaymentMethod paymentMethod;
  final List<Payment> paymentHistory;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([amount, description, paymentMethod]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns true if payment data is currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns total number of payments
  int get totalPayments => paymentHistory.length;

  /// Returns recent payments (last 10)
  List<Payment> get recentPayments {
    final sorted = List<Payment>.from(paymentHistory);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(10).toList();
  }

  /// Returns successful payments
  List<Payment> get successfulPayments {
    return paymentHistory.where((p) => p.status == PaymentStatus.completed).toList();
  }

  /// Returns pending payments
  List<Payment> get pendingPayments {
    return paymentHistory.where((p) => p.status == PaymentStatus.pending).toList();
  }

  /// Returns failed payments
  List<Payment> get failedPayments {
    return paymentHistory.where((p) => p.status == PaymentStatus.failed).toList();
  }

  /// Returns payments grouped by date
  Map<String, List<Payment>> get paymentsByDate {
    final Map<String, List<Payment>> grouped = {};
    
    for (final payment in paymentHistory) {
      final date = payment.createdAt.toLocal().toString().split(' ')[0];
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(payment);
    }
    
    // Sort payments within each date by creation time (newest first)
    for (final payments in grouped.values) {
      payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return grouped;
  }

  /// Returns payment status distribution
  Map<PaymentStatus, int> get statusDistribution {
    final distribution = <PaymentStatus, int>{};
    
    for (final status in PaymentStatus.values) {
      distribution[status] = paymentHistory.where((p) => p.status == status).length;
    }
    
    return distribution;
  }

  /// Returns true if there are any payments
  bool get hasPayments => paymentHistory.isNotEmpty;

  /// Returns total amount of all payments
  double get totalAmount {
    return paymentHistory.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Returns total amount of successful payments
  double get totalSuccessfulAmount {
    return successfulPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  PaymentState copyWith({
    FormzSubmissionStatus? status,
    Amount? amount,
    Description? description,
    PaymentMethod? paymentMethod,
    List<Payment>? paymentHistory,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        amount,
        description,
        paymentMethod,
        paymentHistory,
        errorMessage,
      ];

  @override
  String toString() {
    return 'PaymentState('
        'status: $status, '
        'amount: $amount, '
        'description: $description, '
        'paymentMethod: $paymentMethod, '
        'paymentHistory: ${paymentHistory.length}, '
        'errorMessage: $errorMessage'
        ')';
  }
}
