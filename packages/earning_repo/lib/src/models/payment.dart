class Payment {
  final String id;
  final String driverId;
  final double amount;
  final DateTime date;
  final String status;
  final String paymentMethod;
  final String? transactionId;
  final String? description;
  final Map<String, dynamic>? additionalData;

  Payment({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.date,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    this.description,
    this.additionalData,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      driverId: json['driverId'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      description: json['description'],
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'description': description,
      'additionalData': additionalData,
    };
  }

  Payment copyWith({
    String? id,
    String? driverId,
    double? amount,
    DateTime? date,
    String? status,
    String? paymentMethod,
    String? transactionId,
    String? description,
    Map<String, dynamic>? additionalData,
  }) {
    return Payment(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      description: description ?? this.description,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}