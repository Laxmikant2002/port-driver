import 'package:flutter/material.dart';
import 'package:driver/screens/account/wallet/view/send_to_bank_screen.dart';
import 'package:driver/screens/account/wallet/view/wallet_screen.dart';

class FinanceRoutes {
  // Wallet and earnings management (admin handles payouts, no withdrawal needed)
  static const String wallet = '/wallet';
  static const String earnings = '/earnings';
  static const String transactionHistory = '/transaction-history';
  static const String earningsSummary = '/earnings-summary';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      wallet: (context) {
        // TODO: Pass FinanceRepo when available
        return const Scaffold(
          body: Center(
            child: Text('Wallet Screen - FinanceRepo required'),
          ),
        );
      },
      earnings: (context) {
        // This could be a dedicated earnings screen
        return const Scaffold(
          body: Center(
            child: Text('Earnings - Full screen implementation needed'),
          ),
        );
      },
      transactionHistory: (context) {
        // This could be a dedicated transaction history screen
        return const Scaffold(
          body: Center(
            child: Text('Transaction History - Full screen implementation needed'),
          ),
        );
      },
      earningsSummary: (context) {
        // This could be an earnings summary screen
        return const Scaffold(
          body: Center(
            child: Text('Earnings Summary - Full screen implementation needed'),
          ),
        );
      },
    };
  }
}
