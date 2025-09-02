import 'dart:convert';
import 'package:earning_repo/earning_repo.dart';

class EarningService {
  final EarningRepo _repository;

  EarningService(this._repository);

  Future<List<Earning>> getDailyEarnings(EarningRequest request) async {
    try {
      final result = await _repository.getDailyEarnings(
        driverId: request.driverId,
        date: request.date ?? DateTime.now(),
      );
      return result;
    } catch (e) {
      print('Error in getDailyEarnings: $e');
      rethrow;
    }
  }

  Future<List<Earning>> getWeeklyEarnings(EarningRequest request) async {
    try {
      final result = await _repository.getWeeklyEarnings(
        driverId: request.driverId,
        startDate: request.startDate!,
        endDate: request.endDate!,
      );
      return result;
    } catch (e) {
      print('Error in getWeeklyEarnings: $e');
      rethrow;
    }
  }

  Future<List<Withdrawal>> getWithdrawalHistory(EarningRequest request) async {
    try {
      final result = await _repository.getWithdrawalHistory(
        driverId: request.driverId,
        startDate: request.startDate!,
        endDate: request.endDate!,
      );
      return result;
    } catch (e) {
      print('Error in getWithdrawalHistory: $e');
      rethrow;
    }
  }

  Future<Withdrawal?> requestWithdrawal(WithdrawalRequest request) async {
    try {
      final result = await _repository.requestWithdrawal(
        driverId: request.driverId,
        amount: request.amount,
        paymentMethod: request.paymentMethod,
        bankAccountId: request.bankAccountId,
      );
      return result;
    } catch (e) {
      print('Error in requestWithdrawal: $e');
      rethrow;
    }
  }

  double calculateTotalEarnings(List<Earning> earnings) {
    return earnings.fold(0, (sum, earning) => sum + earning.amount);
  }

  double calculateTotalWithdrawals(List<Withdrawal> withdrawals) {
    return withdrawals.fold(0, (sum, withdrawal) => sum + withdrawal.amount);
  }
}

class EarningRequest {
  final String driverId;
  final DateTime? date;
  final DateTime? startDate;
  final DateTime? endDate;

  EarningRequest({
    required this.driverId,
    this.date,
    this.startDate,
    this.endDate,
  });

  factory EarningRequest.fromJson(Map<String, dynamic> json) => EarningRequest(
        driverId: json['driverId'],
        date: json['date'] != null ? DateTime.parse(json['date']) : null,
        startDate:
            json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
        endDate:
            json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      );

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'date': date?.toIso8601String(),
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };
}

class WithdrawalRequest {
  final String driverId;
  final double amount;
  final String paymentMethod;
  final String bankAccountId;

  WithdrawalRequest({
    required this.driverId,
    required this.amount,
    required this.paymentMethod,
    required this.bankAccountId,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      WithdrawalRequest(
        driverId: json['driverId'],
        amount: json['amount'],
        paymentMethod: json['paymentMethod'],
        bankAccountId: json['bankAccountId'],
      );

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'bankAccountId': bankAccountId,
      };
}