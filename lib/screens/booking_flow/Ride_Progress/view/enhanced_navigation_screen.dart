import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:formz/formz.dart';

import 'package:driver/screens/booking_flow/Ride_Matching/bloc/ride_matching_bloc.dart';
import 'package:driver/services/location/google_map_services.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/widgets/ui_components/ui_components.dart';
import 'package:driver/widgets/booking_flow_scaffold.dart';
import 'package:driver/utils/booking_flow_coordinator.dart';
import 'package:driver/utils/result.dart';

/// Enhanced navigation screen with improved error handling and consistent UI patterns.
/// 
/// Uses the new BookingFlowScaffold for consistent UI and the Result type
/// for better error handling throughout the navigation flow.
class EnhancedNavigationScreen extends StatefulWidget {
  const EnhancedNavigationScreen({super.key});

  @override
  State<EnhancedNavigationScreen> createState() => _EnhancedNavigationScreenState();
}

class _EnhancedNavigationScreenState extends State<EnhancedNavigationScreen>
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
        // Handle state changes with improved error handling
        _handleStateChange(context, state);
      },
      builder: (context, state) {
        return BookingFlowScaffold(
          showAppBar: false,
          extendBodyBehindAppBar: true,
          body: _buildBody(context, state),
          errorStream: _getErrorStream(state),
          loadingStream: _getLoadingStream(state),
        );
      },
    );
  }

  /// Handle state changes with proper error handling using Result pattern
  void _handleStateChange(BuildContext context, RideMatchingState state) {
    if (state.hasError) {
      final error = AppError.server(state.errorMessage ?? 'An error occurred');
      _showErrorWithRetry(context, error);
    }

    // Update map when booking changes
    if (state.hasActiveBooking && state.currentBooking != null) {
      _updateMapForBooking(state.currentBooking!).then((result) {
        result.fold(
          onSuccess: (_) => debugPrint('Map updated successfully'),
          onFailure: (AppError error) => debugPrint('Failed to update map: ${error.message}'),
        );
      });
    }
  }

  /// Get error stream for BookingFlowScaffold
  Stream<AppError>? _getErrorStream(RideMatchingState state) {
    if (state.hasError) {
      return Stream.value(
        AppError.server(state.errorMessage ?? 'An error occurred'),
      );
    }
    return null;
  }

  /// Get loading stream for BookingFlowScaffold
  Stream<bool>? _getLoadingStream(RideMatchingState state) {
    return Stream.value(state.status == FormzSubmissionStatus.inProgress);
  }

  /// Build main body content
  Widget _buildBody(BuildContext context, RideMatchingState state) {
    if (!state.hasActiveBooking || state.currentBooking == null) {
      return BookingFlowEmptyState(
        icon: Icons.directions_car,
        title: 'No Active Trip',
        message: 'Waiting for ride requests...',
        actionText: 'Go to Dashboard',
        onAction: () => BookingFlowCoordinator.showDashboard(context),
      );
    }

    final booking = state.currentBooking!;
    final isPickupPhase = state.currentPhase == RidePhase.pickup;
    final destination = isPickupPhase 
        ? booking.pickupLocation 
        : booking.dropoffLocation;

    return Stack(
      children: [
        // Google Map
        _buildMap(destination),
        
        // Header with trip info
        _buildHeader(context, booking, isPickupPhase, destination),
        
        // Driver location pulse animation
        if (_currentLocation != null) _buildLocationPulse(),
        
        // Bottom sheet with ride details
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: const RideDetailsBottomSheet(),
        ),
        
        // Navigation instructions (if navigating)
        if (_isNavigating) _buildNavigationInstructions(),
      ],
    );
  }

  /// Build Google Map widget
  Widget _buildMap(dynamic destination) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          (destination.latitude as num).toDouble(),
          (destination.longitude as num).toDouble(),
        ),
        zoom: 15.0,
      ),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  /// Build header with trip information
  Widget _buildHeader(
    BuildContext context,
    dynamic booking,
    bool isPickupPhase,
    dynamic destination,
  ) {
    return Positioned(
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
            // Back button using BookingFlowCoordinator
            IconButton(
              onPressed: () => BookingFlowCoordinator.goBackToMap(context),
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
                    destination.address?.toString() ?? 'Unknown address',
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
            
            // External navigation button
            IconButton(
              onPressed: () => _openExternalNavigation(context, destination),
              icon: Icon(
                Icons.navigation,
                color: AppColors.primary,
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
    );
  }

  /// Build location pulse animation
  Widget _buildLocationPulse() {
    return AnimatedBuilder(
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
    );
  }

  /// Build navigation instructions overlay
  Widget _buildNavigationInstructions() {
    return Positioned(
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
    );
  }

  /// Update map for booking using Result pattern
  Future<Result<void>> _updateMapForBooking(dynamic booking) async {
    try {
      if (_mapController == null) {
        return Result.failure(
          AppError.validation('Map controller not initialized'),
        );
      }

      final markers = <Marker>{};
      final polylines = <Polyline>{};

      // Add pickup marker
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(
            (booking.pickupLocation.latitude as num).toDouble(),
            (booking.pickupLocation.longitude as num).toDouble(),
          ),
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: booking.pickupLocation.address?.toString(),
          ),
        ),
      );

      // Add dropoff marker
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(
            (booking.dropoffLocation.latitude as num).toDouble(),
            (booking.dropoffLocation.longitude as num).toDouble(),
          ),
          infoWindow: InfoWindow(
            title: 'Dropoff Location',
            snippet: booking.dropoffLocation.address?.toString(),
          ),
        ),
      );

      // Add current location marker if available
      if (_currentLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
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
      final routeResult = await _generateRoute(booking);
      await routeResult.fold(
        onSuccess: (routePolylines) async {
          polylines.addAll(routePolylines);
        },
        onFailure: (error) async {
          debugPrint('Route generation error: ${error.message}');
        },
      );

      setState(() {
        _markers = markers;
        _polylines = polylines;
      });

      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(
        AppError.unknown(
          'Failed to update map: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Generate route polyline using Result pattern
  Future<Result<Set<Polyline>>> _generateRoute(dynamic booking) async {
    try {
      final routePoints = await _mapServices.getPolylineCoordinates(
        _currentLocation ?? LatLng(
          (booking.pickupLocation.latitude as num).toDouble(),
          (booking.pickupLocation.longitude as num).toDouble(),
        ),
        LatLng(
          (booking.dropoffLocation.latitude as num).toDouble(),
          (booking.dropoffLocation.longitude as num).toDouble(),
        ),
      );

      if (routePoints.isNotEmpty) {
        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: AppColors.primary,
          width: 4,
          patterns: const [],
        );

        return Result.success({polyline});
      } else {
        return Result.failure(
          AppError.server('No route found'),
        );
      }
    } catch (e) {
      return Result.failure(
        AppError.network(
          'Failed to generate route: $e',
        ),
      );
    }
  }

  /// Open external navigation using BookingFlowCoordinator
  Future<void> _openExternalNavigation(BuildContext context, dynamic destination) async {
    // TODO: Convert dynamic destination to BookingLocation
    // For now, show a placeholder message
    _showErrorWithRetry(
      context,
      AppError.unknown('External navigation not yet implemented'),
    );
  }

  /// Show error with retry option using enhanced error handling
  void _showErrorWithRetry(BuildContext context, AppError error) {
    BookingFlowCoordinator.showErrorDialog(
      context,
      error,
      showRetry: true,
    ).then((shouldRetry) {
      if (shouldRetry) {
        // Implement retry logic
        context.read<RideMatchingBloc>().add(const RideMatchingInitialized());
      }
    });
  }
}