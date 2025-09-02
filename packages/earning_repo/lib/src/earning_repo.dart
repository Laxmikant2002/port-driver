import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:earning_repo/earning_repo.dart';

class EarningRepo {
  final ApiClient apiClient;

  EarningRepo(this.apiClient);

  Future<List<Earning>> getDailyEarnings({
    required String driverId,
    required DateTime date,
  }) async {
    try {
      final res = await apiClient.getReq(
        '/driver/earnings/daily',
        queryParameters: {
          'driverId': driverId,
          'date': date.toIso8601String(),
        },
      );

      if (res is DataFailed) {
        return _handleError(res);
      }

      if (res is DataSuccess) {
        final rawData = res.data;
        return (rawData as List).map((e) => Earning.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error in getDailyEarnings: $e');
      rethrow;
    }
    return [];
  }

  Future<List<Earning>> getWeeklyEarnings({
    required String driverId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await apiClient.getReq<List<Earning>>(
        '/driver/earnings/weekly',
        queryParameters: {
          'driverId': driverId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (result is DataFailed) {
        return _handleError(result as DataFailed<dynamic>); // Cast result to DataFailed<dynamic>
      }

      if (result is DataSuccess) {
        final rawData = result.data;
        return (rawData as List).map((e) => Earning.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error in getWeeklyEarnings: $e');
      rethrow;
    }
    return [];
  }

  Future<List<Withdrawal>> getWithdrawalHistory({
    required String driverId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final res = await apiClient.getReq(
        '/driver/withdrawals/history',
        queryParameters: {
          'driverId': driverId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (res is DataFailed) {
        return _handleError(res);
      }

      if (res is DataSuccess) {
        final rawData = res.data;
        return (rawData as List).map((e) => Withdrawal.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error in getWithdrawalHistory: $e');
      rethrow;
    }
    return [];
  }

  Future<Withdrawal?> requestWithdrawal({
    required String driverId,
    required double amount,
    required String paymentMethod,
    required String bankAccountId,
  }) async {
    try {
      final res = await apiClient.postReq(
        '/driver/withdrawals/request',
        bodyJson: {
          'driverId': driverId,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'bankAccountId': bankAccountId,
        },
      );

      if (res is DataFailed) {
        _handleError(res);
        return null;
      }

      if (res is DataSuccess) {
        final rawData = res.data;
        return Withdrawal.fromJson(rawData);
      }
    } catch (e) {
      print('Error in requestWithdrawal: $e');
      rethrow;
    }
    return null;
  }

  List<T> _handleError<T>(DataFailed res) {
    try {
      final errorResponse = jsonDecode(res.error?.error ?? '{}');
      final errors = errorResponse['error'] as List<dynamic>;
      final response = errors.map((e) => e['error'] as String).join(', ');
      print('Error: $response');
    } catch (e) {
      print('Error parsing error response: $e');
    }
    throw Exception('An error occurred while processing the request.');
  }
}