import 'package:flutter/material.dart';
import 'package:driver/widgets/colors.dart';

/// Bottom sheet for ride details during navigation
class RideDetailsSheet extends StatelessWidget {
  const RideDetailsSheet({
    super.key,
    required this.riderName,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.estimatedTime,
    required this.estimatedDistance,
    required this.onContactRider,
    required this.onCancelRide,
    required this.onArrived,
    required this.arrivedEnabled,
    this.riderPhone,
    this.currentPhase = RidePhase.pickup,
    this.actualFare,
    this.tripStartedAt,
  });

  final String riderName;
  final String pickupLocation;
  final String dropoffLocation;
  final String estimatedTime;
  final String estimatedDistance;
  final VoidCallback onContactRider;
  final VoidCallback onCancelRide;
  final VoidCallback onArrived;
  final bool arrivedEnabled;
  final String? riderPhone;
  final RidePhase currentPhase;
  final double? actualFare;
  final DateTime? tripStartedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header with phase indicator
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Phase indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getPhaseColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getPhaseColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPhaseIcon(),
                        color: _getPhaseColor(),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getPhaseText(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getPhaseColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Rider info
                Row(
                  children: [
                    // Rider avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Rider details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            riderName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                color: AppColors.textTertiary,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                riderPhone != null 
                                    ? _maskPhoneNumber(riderPhone!)
                                    : 'Phone not available',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Contact button
                    IconButton(
                      onPressed: onContactRider,
                      icon: Icon(
                        Icons.phone,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Trip details
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Current destination
                _buildLocationRow(
                  icon: currentPhase == RidePhase.pickup ? Icons.location_on : Icons.flag,
                  iconColor: currentPhase == RidePhase.pickup ? AppColors.success : AppColors.error,
                  title: currentPhase == RidePhase.pickup ? 'Pickup Location' : 'Dropoff Location',
                  address: currentPhase == RidePhase.pickup ? pickupLocation : dropoffLocation,
                ),
                
                // Route line
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 20,
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Container(
                        width: 2,
                        height: 20,
                        color: AppColors.border,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.border,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Next destination
                _buildLocationRow(
                  icon: currentPhase == RidePhase.pickup ? Icons.flag : Icons.location_on,
                  iconColor: currentPhase == RidePhase.pickup ? AppColors.error : AppColors.success,
                  title: currentPhase == RidePhase.pickup ? 'Dropoff Location' : 'Pickup Location',
                  address: currentPhase == RidePhase.pickup ? dropoffLocation : pickupLocation,
                ),
              ],
            ),
          ),
          
          // Trip info
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Estimated time
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.access_time,
                    label: 'ETA',
                    value: estimatedTime,
                  ),
                ),
                
                // Distance
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: estimatedDistance,
                  ),
                ),
                
                // Fare (if available)
                if (actualFare != null)
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.currency_rupee,
                      label: 'Fare',
                      value: '₹${actualFare!.toStringAsFixed(2)}',
                    ),
                  ),
              ],
            ),
          ),
          
          // Trip timer (if started)
          if (tripStartedAt != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Trip started: ${_formatDuration(DateTime.now().difference(tripStartedAt!))}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancelRide,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Arrived/Complete button
                Expanded(
                  child: ElevatedButton(
                    onPressed: arrivedEnabled ? onArrived : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: arrivedEnabled ? AppColors.success : AppColors.textTertiary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          currentPhase == RidePhase.pickup ? Icons.check_circle : Icons.done_all,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentPhase == RidePhase.pickup ? 'Arrived' : 'Complete',
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
          
          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
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

  Color _getPhaseColor() {
    switch (currentPhase) {
      case RidePhase.pickup:
        return AppColors.success;
      case RidePhase.dropoff:
        return AppColors.error;
      case RidePhase.completed:
        return AppColors.info;
    }
  }

  IconData _getPhaseIcon() {
    switch (currentPhase) {
      case RidePhase.pickup:
        return Icons.location_on;
      case RidePhase.dropoff:
        return Icons.flag;
      case RidePhase.completed:
        return Icons.check_circle;
    }
  }

  String _getPhaseText() {
    switch (currentPhase) {
      case RidePhase.pickup:
        return 'En route to pickup';
      case RidePhase.dropoff:
        return 'En route to destination';
      case RidePhase.completed:
        return 'Trip completed';
    }
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length < 4) return phone;
    return '${phone.substring(0, 2)}****${phone.substring(phone.length - 2)}';
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

/// Ride phase enum
enum RidePhase {
  pickup,
  dropoff,
  completed,
}
