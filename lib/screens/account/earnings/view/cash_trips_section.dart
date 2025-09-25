import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/models/booking.dart';

import '../bloc/earnings_bloc.dart';

/// Section showing cash trips that need to be marked as collected
class CashTripsSection extends StatelessWidget {
  final List<Booking> cashTrips;
  final double pendingAmount;
  final double collectedToday;

  const CashTripsSection({
    super.key,
    required this.cashTrips,
    required this.pendingAmount,
    required this.collectedToday,
  });

  @override
  Widget build(BuildContext context) {
    final pendingTrips = cashTrips
        .where((trip) => trip.paymentStatus == PaymentStatus.pending)
        .toList();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.money,
                      size: 20,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Cash Trips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCashStat(
                        'Collected Today',
                        '₹${collectedToday.toStringAsFixed(2)}',
                        AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _buildCashStat(
                        'Pending Due',
                        '₹${pendingAmount.toStringAsFixed(2)}',
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (pendingTrips.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mark as Collected',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...pendingTrips.map((trip) => _buildPendingTripItem(
                    context,
                    trip,
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCashStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTripItem(BuildContext context, Booking trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${trip.fare?.toStringAsFixed(2) ?? trip.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<EarningsBloc>().add(
                CashTripMarkedCollected(
                  tripId: trip.id,
                  amount: trip.fare ?? trip.amount,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'Collected',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}