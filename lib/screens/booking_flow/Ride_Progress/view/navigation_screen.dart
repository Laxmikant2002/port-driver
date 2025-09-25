import 'package:driver/screens/booking_flow/Ride_Matching/bloc/ride_matching_bloc.dart';
import 'package:driver/services/google_map_services.dart';
import 'package:driver/widgets/ui_components/ui_components.dart';
import 'package:driver/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  final GoogleMapServices _mapServices = GoogleMapServices();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  bool _isNavigating = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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

        // Update map when booking changes
        if (state.hasActiveBooking && state.currentBooking != null) {
          _updateMapForBooking(state.currentBooking!);
        }
      },
      builder: (context, state) {
        if (!state.hasActiveBooking || state.currentBooking == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Trip',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waiting for ride requests...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final booking = state.currentBooking!;
        final isPickupPhase = state.currentPhase == RidePhase.pickup;
        final destination = isPickupPhase 
            ? booking.pickupLocation 
            : booking.dropoffLocation;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(destination.latitude, destination.longitude),
                  zoom: 15.0,
                ),
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) {
                  _mapController = controller;
                  _updateMapForBooking(booking);
                },
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                onTap: (latLng) {
                  // Handle map tap if needed
                },
              ),

              // Header with trip info
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.surface.withOpacity(0.95),
                        AppColors.surface.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Trip info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPickupPhase ? 'En route to pickup' : 'En route to destination',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              destination.address,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Navigation toggle
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isNavigating = !_isNavigating;
                          });
                        },
                        icon: Icon(
                          _isNavigating ? Icons.navigation : Icons.navigation_outlined,
                          color: _isNavigating ? AppColors.primary : AppColors.textTertiary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Driver location pulse animation
              if (_currentLocation != null)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: MediaQuery.of(context).size.width / 2 - 30 * _pulseAnimation.value / 2,
                      top: MediaQuery.of(context).size.height / 2 - 30 * _pulseAnimation.value / 2,
                      child: IgnorePointer(
                        child: Container(
                          width: 30 * _pulseAnimation.value,
                          height: 30 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.3),
                                AppColors.primary.withOpacity(0.01),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Bottom sheet with ride details
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: RideDetailsSheet(
                  riderName: booking.passengerName ?? 'Unknown',
                  pickupLocation: booking.pickupLocation.address,
                  dropoffLocation: booking.dropoffLocation.address,
                  estimatedTime: '${booking.estimatedDuration} min',
                  estimatedDistance: '${booking.distance.toStringAsFixed(1)} km',
                  onContactRider: () {
                    _showContactOptions(context, booking);
                  },
                  onCancelRide: () {
                    _showCancelConfirmation(context);
                  },
                  onArrived: () {
                    if (isPickupPhase) {
                      context.read<RideMatchingBloc>().add(
                        const DriverArrivedAtPickup(),
                      );
                    } else {
                      context.read<RideMatchingBloc>().add(
                        const TripCompleted(),
                      );
                    }
                  },
                  arrivedEnabled: true,
                  riderPhone: booking.passengerPhone,
                  currentPhase: state.currentPhase,
                  actualFare: booking.fare,
                  tripStartedAt: state.tripStartedAt,
                ),
              ),

              // Navigation instructions (if navigating)
              if (_isNavigating)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 80,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.navigation,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Turn right in 200m',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Then continue straight for 1.2km',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '2 min',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _updateMapForBooking(booking) async {
    if (_mapController == null) return;

    final markers = <Marker>{};
    final polylines = <Polyline>{};

    // Add pickup marker
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          booking.pickupLocation.latitude,
          booking.pickupLocation.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Pickup Location',
          snippet: booking.pickupLocation.address,
        ),
      ),
    );

    // Add dropoff marker
    markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(
          booking.dropoffLocation.latitude,
          booking.dropoffLocation.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Dropoff Location',
          snippet: booking.dropoffLocation.address,
        ),
      ),
    );

    // Add driver location marker (if available)
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current position',
          ),
        ),
      );
    }

    // Generate route polyline
    try {
      final routePoints = await _mapServices.getPolylineCoordinates(
        _currentLocation ?? LatLng(
          booking.pickupLocation.latitude,
          booking.pickupLocation.longitude,
        ),
        LatLng(
          booking.dropoffLocation.latitude,
          booking.dropoffLocation.longitude,
        ),
      );

      if (routePoints.isNotEmpty) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: routePoints,
            color: AppColors.primary,
            width: 4,
            patterns: const [],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating route: $e');
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });

    // Fit camera to show all markers
    if (markers.isNotEmpty) {
      _fitCameraToMarkers(markers);
    }
  }

  void _fitCameraToMarkers(Set<Marker> markers) {
    if (_mapController == null || markers.isEmpty) return;

    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (final marker in markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  void _showContactOptions(BuildContext context, booking) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Contact ${booking.passengerName ?? 'Passenger'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Implement call functionality
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Implement SMS functionality
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Trip?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this trip? This action cannot be undone.',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Trip',
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RideMatchingBloc>().add(
                const RideRequestRejected('Driver cancelled'),
              );
              Navigator.pop(context); // Go back to main screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel Trip'),
          ),
        ],
      ),
    );
  }
}
