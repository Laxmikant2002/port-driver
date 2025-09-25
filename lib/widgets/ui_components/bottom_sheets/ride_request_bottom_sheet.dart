import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/screens/booking_flow/Ride_Progress/bloc/booking_bloc.dart';

class RideRequestBottomSheet extends StatefulWidget {
  const RideRequestBottomSheet({super.key});

  @override
  State<RideRequestBottomSheet> createState() => _RideRequestBottomSheetState();
}

class _RideRequestBottomSheetState extends State<RideRequestBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _timerController;
  late Animation<Offset> _slideAnimation;
  
  int _remainingSeconds = 30; // 30 second timer
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _timerController = AnimationController(
      duration: Duration(seconds: _remainingSeconds),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _slideController.forward();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });
        
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _autoReject();
        }
      }
    });
    
    _timerController.forward();
  }

  void _autoReject() {
    context.read<BookingBloc>().add(
      const BookingSubmitted(BookingAction.reject, reason: 'Auto-rejected due to timeout'),
    );
    Navigator.pop(context);
  }

  void _acceptRide() {
    _timer?.cancel();
    context.read<BookingBloc>().add(
      const BookingSubmitted(BookingAction.accept),
    );
    Navigator.pop(context);
  }

  void _rejectRide() {
    _timer?.cancel();
    _showRejectDialog();
  }

  void _showRejectDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Reject Ride?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to reject this ride request?',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              context.read<BookingBloc>().add(
                const BookingSubmitted(BookingAction.reject, reason: 'Driver rejected'),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        final booking = state.currentBooking;
        if (booking == null) {
          return const SizedBox.shrink();
        }

        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
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
                
                // Timer progress bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: LinearProgressIndicator(
                    value: _remainingSeconds / 30,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _remainingSeconds <= 10 ? AppColors.error : AppColors.warning,
                    ),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_shipping,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Delivery Request',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${_remainingSeconds}s remaining',
                              style: TextStyle(
                                fontSize: 14,
                                color: _remainingSeconds <= 10 
                                    ? AppColors.error 
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Ride details
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      // Pickup location
                      _buildLocationRow(
                        icon: Icons.location_on,
                        title: 'Pickup',
                        address: booking.pickupLocation.address,
                        landmark: booking.pickupLocation.landmark,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Divider
                      Container(
                        height: 1,
                        color: AppColors.border,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Dropoff location
                      _buildLocationRow(
                        icon: Icons.location_on,
                        title: 'Delivery',
                        address: booking.dropoffLocation.address,
                        landmark: booking.dropoffLocation.landmark,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Trip info
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.straighten,
                          label: 'Distance',
                          value: '${booking.distance.toStringAsFixed(1)} km',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.border,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.access_time,
                          label: 'Duration',
                          value: '${booking.estimatedDuration} min',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.border,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.currency_rupee,
                          label: 'Fare',
                          value: '₹${booking.fare.toStringAsFixed(0)}',
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _rejectRide,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.error),
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _acceptRide,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String title,
    required String address,
    String? landmark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 16,
          ),
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
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (landmark != null) ...[
                const SizedBox(height: 2),
                Text(
                  landmark,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
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
          color: AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}