import 'package:flutter/material.dart';
import 'package:driver/widgets/colors.dart';

/// Popup for displaying fare calculation breakdown
class FareCalculationPopup extends StatelessWidget {
  const FareCalculationPopup({
    super.key,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.totalFare,
    required this.onConfirm,
    required this.onCancel,
    this.commission = 0.0,
    this.driverEarnings = 0.0,
    this.distance,
    this.duration,
    this.tip = 0.0,
  });

  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double totalFare;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final double commission;
  final double driverEarnings;
  final double? distance;
  final Duration? duration;
  final double tip;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.currency_rupee,
                      color: AppColors.surface,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Completed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fare calculation breakdown',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Fare breakdown
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Trip details
                  if (distance != null || duration != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (distance != null)
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.straighten,
                                label: 'Distance',
                                value: '${distance!.toStringAsFixed(1)} km',
                              ),
                            ),
                          if (distance != null && duration != null)
                            Container(
                              height: 30,
                              width: 1,
                              color: AppColors.border,
                            ),
                          if (duration != null)
                            Expanded(
                              child: _buildDetailItem(
                                icon: Icons.access_time,
                                label: 'Duration',
                                value: _formatDuration(duration!),
                              ),
                            ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Fare breakdown
                  _buildFareItem(
                    label: 'Base Fare',
                    amount: baseFare,
                    isHighlight: false,
                  ),
                  
                  _buildFareItem(
                    label: 'Distance Fare',
                    amount: distanceFare,
                    isHighlight: false,
                  ),
                  
                  _buildFareItem(
                    label: 'Time Fare',
                    amount: timeFare,
                    isHighlight: false,
                  ),
                  
                  if (tip > 0)
                    _buildFareItem(
                      label: 'Tip',
                      amount: tip,
                      isHighlight: false,
                      icon: Icons.favorite,
                    ),
                  
                  const Divider(height: 24),
                  
                  _buildFareItem(
                    label: 'Total Fare',
                    amount: totalFare,
                    isHighlight: true,
                  ),
                  
                  if (commission > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildFareItem(
                            label: 'Platform Commission',
                            amount: commission,
                            isHighlight: false,
                            textColor: AppColors.error,
                          ),
                          const SizedBox(height: 8),
                          _buildFareItem(
                            label: 'Your Earnings',
                            amount: driverEarnings,
                            isHighlight: true,
                            textColor: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textTertiary,
                        side: BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Confirm button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textTertiary,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFareItem({
    required String label,
    required double amount,
    required bool isHighlight,
    IconData? icon,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? AppColors.textTertiary,
              size: 16,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isHighlight ? 16 : 14,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: textColor ?? (isHighlight ? AppColors.textPrimary : AppColors.textSecondary),
              ),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isHighlight ? 18 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: textColor ?? (isHighlight ? AppColors.success : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
