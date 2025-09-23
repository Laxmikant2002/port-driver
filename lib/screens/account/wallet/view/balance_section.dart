import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../bloc/wallet_bloc.dart';

class BalanceSection extends StatelessWidget {
  final WalletState state;

  const BalanceSection({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     // Navigate to withdrawals screen
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.black,
                //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                //   child: const Text(
                //     'Withdrawals',
                //     style: TextStyle(fontSize: 14, color: Colors.white),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(state.availableBalance),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to withdrawal screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Withdrawal',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: _BalanceCard(
                        title: 'Total Earnings',
                        amount: currencyFormat.format(state.totalEarnings),
                        icon: Icons.arrow_upward,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BalanceCard(
                        title: 'Total Withdrawals',
                        amount: currencyFormat.format(state.totalWithdrawals),
                        icon: Icons.arrow_downward,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to cash out screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cash Out',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}