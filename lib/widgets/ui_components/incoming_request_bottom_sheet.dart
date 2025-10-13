import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver/app/bloc/trip_bloc.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/services/realtime/realtime_service.dart';

/// Modern bottom sheet for incoming trip requests
class IncomingRequestBottomSheet extends StatefulWidget {
  const IncomingRequestBottomSheet({
    super.key,
    required this.tripRequest,
  });

  final TripRequest tripRequest;

  @override
  State<IncomingRequestBottomSheet> createState() => _IncomingRequestBottomSheetState();
}

class _IncomingRequestBottomSheetState extends State<IncomingRequestBottomSheet>
    with TickerProviderStateMixin {
  Timer? _countdownTimer;
  int _timeRemaining = 30;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCountdown();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _startCountdown() {
    _timeRemaining = widget.tripRequest.expiresAt.difference(DateTime.now()).inSeconds;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
      });
      
      if (_timeRemaining <= 0) {
        timer.cancel();
        _onRequestExpired();
      }
    });
  }

  void _onRequestExpired() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onAccept() {
    context.read<TripBloc>().add(const TripAccepted());
    Navigator.of(context).pop();
  }

  void _onReject() {
    context.read<TripBloc>().add(const TripRejected());
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildTripDetails(),
            _buildMapPreview(),
            _buildActionButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Animated pulse icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_shipping_rounded,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          
          // Title and timer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Trip Request',
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
                      Icons.access_time_rounded,
                      size: 16,
                      color: _timeRemaining <= 10 
                          ? AppColors.error 
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_timeRemaining}s remaining',
                      style: TextStyle(
                        fontSize: 14,
                        color: _timeRemaining <= 10 
                            ? AppColors.error 
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Circular progress indicator
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: _timeRemaining / 30,
                  strokeWidth: 3,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeRemaining <= 10 
                        ? AppColors.error 
                        : AppColors.primary,
                  ),
                ),
                Center(
                  child: Text(
                    '$_timeRemaining',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _timeRemaining <= 10 
                          ? AppColors.error 
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildLocationRow(
            icon: Icons.my_location_rounded,
            iconColor: AppColors.success,
            title: 'Pickup',
            address: widget.tripRequest.pickup.address,
            lat: widget.tripRequest.pickup.latitude,
            lng: widget.tripRequest.pickup.longitude,
          ),
          const SizedBox(height: 12),
          _buildLocationRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.primary,
            title: 'Drop-off',
            address: widget.tripRequest.drop.address,
            lat: widget.tripRequest.drop.latitude,
            lng: widget.tripRequest.drop.longitude,
          ),
          const SizedBox(height: 16),
          
          // Trip summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildSummaryItem(
                  icon: Icons.route_rounded,
                  label: 'Distance',
                  value: '${widget.tripRequest.distanceKm.toStringAsFixed(1)} km',
                ),
                const SizedBox(width: 24),
                _buildSummaryItem(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Est. Fare',
                  value: '₹${widget.tripRequest.estimatedFare.toStringAsFixed(0)}',
                ),
                const SizedBox(width: 24),
                _buildSummaryItem(
                  icon: Icons.person_rounded,
                  label: 'Customer',
                  value: widget.tripRequest.customer.maskedName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
    required double lat,
    required double lng,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.tripRequest.pickup.latitude,
              widget.tripRequest.pickup.longitude,
            ),
            zoom: 14,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('pickup'),
              position: LatLng(
                widget.tripRequest.pickup.latitude,
                widget.tripRequest.pickup.longitude,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
            Marker(
              markerId: const MarkerId('dropoff'),
              position: LatLng(
                widget.tripRequest.drop.latitude,
                widget.tripRequest.drop.longitude,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          },
          onMapCreated: (GoogleMapController controller) {
            // Fit bounds to show both markers
            controller.animateCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: LatLng(
                    math.min(
                      widget.tripRequest.pickup.latitude,
                      widget.tripRequest.drop.latitude,
                    ),
                    math.min(
                      widget.tripRequest.pickup.longitude,
                      widget.tripRequest.drop.longitude,
                    ),
                  ),
                  northeast: LatLng(
                    math.max(
                      widget.tripRequest.pickup.latitude,
                      widget.tripRequest.drop.latitude,
                    ),
                    math.max(
                      widget.tripRequest.pickup.longitude,
                      widget.tripRequest.drop.longitude,
                    ),
                  ),
                ),
                50.0,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Reject button
          Expanded(
            child: ElevatedButton(
              onPressed: _onReject,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
              onPressed: _onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show incoming request bottom sheet
void showIncomingRequestBottomSheet(
  BuildContext context,
  TripRequest tripRequest,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => IncomingRequestBottomSheet(
      tripRequest: tripRequest,
    ),
  );
}
