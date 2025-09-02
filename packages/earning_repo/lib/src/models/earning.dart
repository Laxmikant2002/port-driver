class Earning {
  final String id;
  final String driverId;
  final double amount;
  final String tripId;
  final DateTime date;
  final String status;
  final String paymentMethod;
  final String? transactionId;
  final Map<String, dynamic>? additionalData;

  Earning({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.tripId,
    required this.date,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    this.additionalData,
  });

  factory Earning.fromJson(Map<String, dynamic> json) {
    return Earning(
      id: json['id'],
      driverId: json['driverId'],
      amount: (json['amount'] as num).toDouble(),
      tripId: json['tripId'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'amount': amount,
      'tripId': tripId,
      'date': date.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'additionalData': additionalData,
    };
  }

  Earning copyWith({
    String? id,
    String? driverId,
    double? amount,
    String? tripId,
    DateTime? date,
    String? status,
    String? paymentMethod,
    String? transactionId,
    Map<String, dynamic>? additionalData,
  }) {
    return Earning(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      amount: amount ?? this.amount,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}