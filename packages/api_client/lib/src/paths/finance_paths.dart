import 'base_paths.dart';

class FinancePaths extends BasePaths {
  // Wallet & Balance
  static final String getWalletBalance = "${BasePaths.baseUrl}/driver/finance/wallet/balance";
  static final String getTransactions = "${BasePaths.baseUrl}/driver/finance/transactions";
  
  // Earnings & Summary
  static final String getEarningsSummary = "${BasePaths.baseUrl}/driver/finance/earnings";
  static final String getDriverEarnings = "${BasePaths.baseUrl}/driver/finance/driver/earnings";
  
  // Withdrawals & Payouts
  static final String requestWithdrawal = "${BasePaths.baseUrl}/driver/finance/withdraw";
  static final String getWithdrawalHistory = "${BasePaths.baseUrl}/driver/finance/withdrawals";
  static final String requestPayout = "${BasePaths.baseUrl}/driver/finance/payout/request";
  
  // Payments
  static final String processPayment = "${BasePaths.baseUrl}/driver/finance/payments";
  static final String getPaymentHistory = "${BasePaths.baseUrl}/driver/finance/payments";
  
  // Admin Endpoints (for reference)
  static final String adminMarkPayoutPaid = "${BasePaths.baseUrl}/admin/finance/payout";
  static final String adminGetDriverEarnings = "${BasePaths.baseUrl}/admin/finance/driver";
  static final String adminProcessPayout = "${BasePaths.baseUrl}/admin/finance/process-payout";
}
