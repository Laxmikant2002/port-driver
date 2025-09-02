class Withdrawal {
  final String id;
  final String driverId;
  final double amount;
  final DateTime date;
  final String status;
  final String paymentMethod;
  final String? transactionId;
  final String? bankAccountId;
  final Map<String, dynamic>? additionalData;

  const Withdrawal({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.date,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    this.bankAccountId,
    this.additionalData,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'],
      driverId: json['driverId'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      bankAccountId: json['bankAccountId'],
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
      'bankAccountId': bankAccountId,
      'additionalData': additionalData,
    };
  }
}