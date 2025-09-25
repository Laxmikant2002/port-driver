import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/models/booking.dart';

import '../bloc/earnings_bloc.dart';

/// Section showing trip breakdown with fare details
class TripBreakdownSection extends StatelessWidget {
  final List<Booking> trips;

  const TripBreakdownSection({
    super.key,
    required this.trips,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Trip Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trips.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return _buildTripItem(context, trip);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTripItem(BuildContext context, Booking trip) {
    return InkWell(
      onTap: () {
        context.read<EarningsBloc>().add(
          TripDetailsRequested(tripId: trip.id),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Trip info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        trip.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPaymentModeColor(trip.paymentMode).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getPaymentModeColor(trip.paymentMode).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          trip.paymentMode.value,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getPaymentModeColor(trip.paymentMode),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTripTime(trip.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (trip.distanceKm != null && trip.durationMinutes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${trip.distanceKm!.toStringAsFixed(1)} km • ${trip.durationMinutes!} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Fare breakdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${(trip.fare ?? trip.amount).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (trip.commission != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Commission: ₹${trip.commission!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.error,
                    ),
                  ),
                ],
                if (trip.netEarnings != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Earned: ₹${trip.netEarnings!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentModeColor(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.online:
        return AppColors.primary;
      case PaymentMode.cash:
        return AppColors.warning;
    }
  }

  String _formatTripTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}