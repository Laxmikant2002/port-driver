import 'package:api_client/api_client.dart';
import 'package:localstorage/localstorage.dart';
import 'models/transaction.dart';
import 'models/wallet_response.dart';
import 'models/withdrawal_request.dart';
import 'models/payment.dart';

/// Finance repository for managing driver wallet and transactions
class FinanceRepo {
  const FinanceRepo({
    required this.apiClient,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final Localstorage localStorage;

  /// Get wallet balance
  Future<WalletResponse> getWalletBalance() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(FinancePaths.getWalletBalance);

      if (response is DataSuccess) {
        return WalletResponse.fromJson(response.data!);
      } else {
        return WalletResponse(
          success: false,
          message: 'Failed to fetch wallet balance',
        );
      }
    } catch (e) {
      return WalletResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get transaction history
  Future<WalletResponse> getTransactions({
    int? limit,
    int? offset,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (type != null) queryParams['type'] = type.value;
      if (status != null) queryParams['status'] = status.value;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await apiClient.get<Map<String, dynamic>>(
        FinancePaths.getTransactions,
        queryParameters: queryParams,
      );

      if (response is DataSuccess) {
        return WalletResponse.fromJson(response.data!);
      } else {
        return WalletResponse(
          success: false,
          message: 'Failed to fetch transactions',
        );
      }
    } catch (e) {
      return WalletResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Request withdrawal
  Future<WalletResponse> requestWithdrawal(WithdrawalRequest request) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/finance/withdraw'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WalletResponse.fromJson(json);
      } else {
        return WalletResponse(
          success: false,
          message: 'Failed to request withdrawal',
        );
      }
    } catch (e) {
      return WalletResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get withdrawal history
  Future<WalletResponse> getWithdrawalHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse('$baseUrl/finance/withdrawals').replace(queryParameters: queryParams);
      
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WalletResponse.fromJson(json);
      } else {
        return WalletResponse(
          success: false,
          message: 'Failed to fetch withdrawal history',
        );
      }
    } catch (e) {
      return WalletResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get earnings summary
  Future<WalletResponse> getEarningsSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await apiClient.get<Map<String, dynamic>>(
        FinancePaths.getEarningsSummary,
        queryParameters: queryParams,
      );

      if (response is DataSuccess) {
        return WalletResponse.fromJson(response.data!);
      } else {
        return WalletResponse(
          success: false,
          message: 'Failed to fetch earnings summary',
        );
      }
    } catch (e) {
      return WalletResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get cached wallet balance
  Future<WalletBalance?> getCachedBalance() async {
    try {
      final cached = localStorage.getString('cached_wallet_balance');
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return WalletBalance.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache wallet balance
  Future<void> cacheBalance(WalletBalance balance) async {
    try {
      localStorage.saveString('cached_wallet_balance', jsonEncode(balance.toJson()));
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get cached transactions
  Future<List<Transaction>> getCachedTransactions() async {
    try {
      final cached = localStorage.getString('cached_transactions');
      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        return jsonList.map((json) => Transaction.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Cache transactions
  Future<void> cacheTransactions(List<Transaction> transactions) async {
    try {
      final jsonList = transactions.map((t) => t.toJson()).toList();
      localStorage.saveString('cached_transactions', jsonEncode(jsonList));
    } catch (e) {
      // Handle error silently
    }
  }

  /// Process payment
  Future<PaymentResponse> processPayment(PaymentRequest request) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/finance/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PaymentResponse.fromJson(json);
      } else {
        return PaymentResponse(
          success: false,
          message: 'Failed to process payment',
        );
      }
    } catch (e) {
      return PaymentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get payment history
  Future<PaymentResponse> getPaymentHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse('$baseUrl/finance/payments').replace(queryParameters: queryParams);
      
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PaymentResponse.fromJson(json);
      } else {
        return PaymentResponse(
          success: false,
          message: 'Failed to fetch payment history',
        );
      }
    } catch (e) {
      return PaymentResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get cached payments
  Future<List<Payment>> getCachedPayments() async {
    try {
      final cached = localStorage.getString('cached_payments');
      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        return jsonList.map((json) => Payment.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Cache payments
  Future<void> cachePayments(List<Payment> payments) async {
    try {
      final jsonList = payments.map((p) => p.toJson()).toList();
      localStorage.saveString('cached_payments', jsonEncode(jsonList));
    } catch (e) {
      // Handle error silently
    }
  }

  /// Request payout for driver earnings
  Future<WalletResponse> requestPayout({required double amount}) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/finance/payout/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'amount': amount,
          'requestedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WalletResponse.fromJson(json);
      } else {
        return WalletResponse(
          success: false,
          message: 'Failed to request payout',
        );
      }
    } catch (e) {
      return WalletResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get driver earnings
  Future<WalletResponse> getDriverEarnings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl/finance/driver/earnings').replace(queryParameters: queryParams);
      
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WalletResponse.fromJson(json);
      } else {
        return WalletResponse(
          success: false,
          message: 'Failed to fetch driver earnings',
        );
      }
    } catch (e) {
      return WalletResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<String> _getAuthToken() async {
    try {
      final token = localStorage.getString('auth_token');
      return token ?? '';
    } catch (e) {
      return '';
    }
  }
}