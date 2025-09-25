import 'package:driver/screens/booking_flow/Ride_Matching/bloc/ride_matching_bloc.dart';
import 'package:driver/widgets/ui_components/ui_components.dart';
import 'package:driver/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IncomingRideRequestSheetView extends StatefulWidget {
  const IncomingRideRequestSheetView({super.key});

  @override
  State<IncomingRideRequestSheetView> createState() => _IncomingRideRequestSheetViewState();
}

class _IncomingRideRequestSheetViewState extends State<IncomingRideRequestSheetView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _countdownController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _countdownAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for the request indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Countdown animation for timeout
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // 30 second timeout
    );
    
    _countdownAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.linear),
    );

    // Start countdown when request is received
    _countdownController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RideMatchingBloc, RideMatchingState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
        }

        // Handle request timeout
        if (state.requestTimeoutRemaining == 0 && state.hasIncomingRequest) {
          context.read<RideMatchingBloc>().add(const RideRequestTimeout());
        }
      },
      builder: (context, state) {
        if (!state.hasIncomingRequest || state.currentBooking == null) {
          return const SizedBox.shrink();
        }

        final booking = state.currentBooking!;
        final timeoutRemaining = state.requestTimeoutRemaining;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar with pulse animation
              Container(
                margin: const EdgeInsets.only(top: 12),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Header with countdown
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Incoming request indicator
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Request info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Ride Request',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to view details',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Countdown timer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: timeoutRemaining <= 10 
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: timeoutRemaining <= 10 
                              ? AppColors.error.withOpacity(0.3)
                              : AppColors.warning.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            color: timeoutRemaining <= 10 
                                ? AppColors.error
                                : AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${timeoutRemaining}s',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: timeoutRemaining <= 10 
                                  ? AppColors.error
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar for countdown
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: AnimatedBuilder(
                  animation: _countdownAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _countdownAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: timeoutRemaining <= 10 
                              ? AppColors.error
                              : AppColors.warning,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Ride details preview
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Pickup location
                    _buildLocationRow(
                      icon: Icons.location_on,
                      iconColor: AppColors.success,
                      title: 'Pickup',
                      address: booking.pickupLocation.address,
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
                    
                    // Dropoff location
                    _buildLocationRow(
                      icon: Icons.flag,
                      iconColor: AppColors.error,
                      title: 'Dropoff',
                      address: booking.dropoffLocation.address,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickInfo(
                        icon: Icons.access_time,
                        label: 'ETA',
                        value: '${booking.estimatedDuration} min',
                      ),
                    ),
                    Expanded(
                      child: _buildQuickInfo(
                        icon: Icons.straighten,
                        label: 'Distance',
                        value: '${booking.distance.toStringAsFixed(1)} km',
                      ),
                    ),
                    Expanded(
                      child: _buildQuickInfo(
                        icon: Icons.currency_rupee,
                        label: 'Fare',
                        value: '₹${booking.fare.toStringAsFixed(2)}',
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
                    // Reject button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<RideMatchingBloc>().add(
                            const RideRequestRejected('Driver rejected'),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.surface,
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
                              'Reject',
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
                    
                    // Accept button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<RideMatchingBloc>().add(
                            const RideRequestAccepted(),
                          );
                        },
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
                            const Icon(Icons.check, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Accept',
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
      },
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

  Widget _buildQuickInfo({
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
}