import 'package:equatable/equatable.dart';

/// Payment model for payment transactions
class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.amount,
    required this.description,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.referenceId,
    this.metadata,
  });

  final String id;
  final double amount;
  final String description;
  final String paymentMethod;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? referenceId;
  final Map<String, dynamic>? metadata;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      paymentMethod: json['paymentMethod'] as String,
      status: PaymentStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      referenceId: json['referenceId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'paymentMethod': paymentMethod,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'referenceId': referenceId,
      'metadata': metadata,
    };
  }

  Payment copyWith({
    String? id,
    double? amount,
    String? description,
    String? paymentMethod,
    PaymentStatus? status,
    DateTime? createdAt,
    String? referenceId,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      referenceId: referenceId ?? this.referenceId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        description,
        paymentMethod,
        status,
        createdAt,
        referenceId,
        metadata,
      ];

  @override
  String toString() {
    return 'Payment('
        'id: $id, '
        'amount: $amount, '
        'description: $description, '
        'paymentMethod: $paymentMethod, '
        'status: $status, '
        'createdAt: $createdAt'
        ')';
  }
}

/// Payment status enum
enum PaymentStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed'),
  cancelled('cancelled', 'Cancelled');

  const PaymentStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown payment status: $value'),
    );
  }
}

/// Payment request model
class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.amount,
    required this.description,
    required this.paymentMethod,
    this.metadata,
  });

  final double amount;
  final String description;
  final String paymentMethod;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'paymentMethod': paymentMethod,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [amount, description, paymentMethod, metadata];
}

/// Payment response model
class PaymentResponse extends Equatable {
  const PaymentResponse({
    required this.success,
    this.message,
    this.payment,
    this.payments,
  });

  final bool success;
  final String? message;
  final Payment? payment;
  final List<Payment>? payments;

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      payment: json['payment'] != null 
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      payments: json['payments'] != null
          ? (json['payments'] as List<dynamic>)
              .map((p) => Payment.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [success, message, payment, payments];
}
