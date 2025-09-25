import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/models/driver_earnings.dart';

import '../bloc/earnings_bloc.dart';

/// Section for payout requests and balance management
class PayoutSection extends StatelessWidget {
  final DriverEarnings earnings;

  const PayoutSection({
    super.key,
    required this.earnings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Payout & Balance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Balance breakdown
            _buildBalanceRow(
              'Total Fare',
              '₹${earnings.totalFare.toStringAsFixed(2)}',
              AppColors.textPrimary,
            ),
            const SizedBox(height: 8),
            _buildBalanceRow(
              'Commission (${(earnings.totalCommission / earnings.totalFare * 100).toStringAsFixed(1)}%)',
              '- ₹${earnings.totalCommission.toStringAsFixed(2)}',
              AppColors.error,
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildBalanceRow(
              'Net Earnings',
              '₹${earnings.netEarnings.toStringAsFixed(2)}',
              AppColors.success,
              isTotal: true,
            ),
            
            const SizedBox(height: 16),
            
            // Payout status and last payout info
            if (earnings.lastPayoutDate != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Last payout: ₹${earnings.lastPayoutAmount?.toStringAsFixed(2)} on ${_formatDate(earnings.lastPayoutDate!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Payout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: earnings.netEarnings > 0 && 
                         earnings.payoutStatus != PayoutStatus.processing
                    ? () => _showPayoutDialog(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _getPayoutButtonText(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow(
    String label,
    String amount,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getPayoutButtonText() {
    switch (earnings.payoutStatus) {
      case PayoutStatus.pending:
        return 'Request Payout';
      case PayoutStatus.processing:
        return 'Processing...';
      case PayoutStatus.completed:
        return 'Request New Payout';
      case PayoutStatus.failed:
        return 'Retry Payout';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPayoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request Payout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available Balance: ₹${earnings.netEarnings.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'This amount will be transferred to your registered bank account within 1-2 business days.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<EarningsBloc>().add(
                PayoutRequested(amount: earnings.netEarnings),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Request Payout'),
          ),
        ],
      ),
    );
  }
}