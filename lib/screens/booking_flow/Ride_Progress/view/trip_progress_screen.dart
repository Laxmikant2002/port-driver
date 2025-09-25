import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver/locator.dart';
import 'package:driver/screens/booking_flow/Ride_Progress/bloc/booking_bloc.dart';
import 'package:driver/services/location_service.dart';
import 'package:driver/services/google_map_services.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/widgets/ui_components/ui_components.dart';
import 'package:booking_repo/booking_repo.dart';

class TripProgressScreen extends StatefulWidget {
  const TripProgressScreen({super.key});

  @override
  State<TripProgressScreen> createState() => _TripProgressScreenState();
}

class _TripProgressScreenState extends State<TripProgressScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final GoogleMapServices _mapServices = GoogleMapServices();
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  RouteInfo? _currentRoute;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final initialized = await _locationService.initialize();
    if (initialized) {
      _currentLocation = _locationService.currentLocation;
      
      // Listen to location updates
      _locationService.locationStream.listen((location) {
        if (mounted) {
          setState(() {
            _currentLocation = location;
          });
          _updateDriverMarker(location);
        }
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _isMapReady = true;
    _updateMapForCurrentBooking();
  }

  void _updateMapForCurrentBooking() {
    final state = context.read<BookingBloc>().state;
    final booking = state.currentBooking;
    
    if (booking == null || _currentLocation == null) return;

    _markers.clear();
    _polylines.clear();

    // Add driver marker
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    // Add pickup marker
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          booking.pickupLocation.latitude,
          booking.pickupLocation.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
    );

    // Add dropoff marker
    _markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(
          booking.dropoffLocation.latitude,
          booking.dropoffLocation.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Dropoff Location'),
      ),
    );

    // Update route based on booking status
    _updateRouteForStatus(booking.status);

    // Update camera position
    _updateCameraPosition();
  }

  void _updateRouteForStatus(BookingStatus status) {
    final booking = context.read<BookingBloc>().state.currentBooking;
    if (booking == null || _currentLocation == null) return;

    switch (status) {
      case BookingStatus.accepted:
        // Show route to pickup
        _showRouteToPickup();
        break;
      case BookingStatus.started:
        // Show route to dropoff
        _showRouteToDropoff();
        break;
      default:
        break;
    }
  }

  Future<void> _showRouteToPickup() async {
    final booking = context.read<BookingBloc>().state.currentBooking;
    if (booking == null || _currentLocation == null) return;

    final pickupLocation = LatLng(
      booking.pickupLocation.latitude,
      booking.pickupLocation.longitude,
    );

    final routeInfo = await _mapServices.getRouteInfo(_currentLocation!, pickupLocation);
    if (routeInfo != null) {
      setState(() {
        _currentRoute = routeInfo;
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: routeInfo.polylinePoints,
            color: AppColors.primary,
            width: 4,
          ),
        );
      });
    }
  }

  Future<void> _showRouteToDropoff() async {
    final booking = context.read<BookingBloc>().state.currentBooking;
    if (booking == null || _currentLocation == null) return;

    final dropoffLocation = LatLng(
      booking.dropoffLocation.latitude,
      booking.dropoffLocation.longitude,
    );

    final routeInfo = await _mapServices.getRouteInfo(_currentLocation!, dropoffLocation);
    if (routeInfo != null) {
      setState(() {
        _currentRoute = routeInfo;
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: routeInfo.polylinePoints,
            color: AppColors.success,
            width: 4,
          ),
        );
      });
    }
  }

  void _updateDriverMarker(LatLng location) {
    _markers.removeWhere((marker) => marker.markerId.value == 'driver');
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );
  }

  void _updateCameraPosition() {
    final booking = context.read<BookingBloc>().state.currentBooking;
    if (booking == null || _currentLocation == null || _mapController == null) return;

    final locations = [
      _currentLocation!,
      LatLng(booking.pickupLocation.latitude, booking.pickupLocation.longitude),
      LatLng(booking.dropoffLocation.latitude, booking.dropoffLocation.longitude),
    ];

    final cameraPosition = _mapServices.getCameraPositionForMarkers(locations);
    _mapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _showRideDetailsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RideDetailsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingBloc(
        bookingRepo: lc<BookingRepo>(),
      )..add(const BookingInitialized()),
      child: Scaffold(
        body: BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state.isSuccess && _isMapReady) {
              _updateMapForCurrentBooking();
            }
          },
          child: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              if (state.currentBooking == null) {
                return _buildNoActiveTripView();
              }

              return Stack(
                children: [
                  // Google Map
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation ?? const LatLng(19.7515, 75.7139),
                      zoom: 15,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                  
                  // Top status bar
                  _buildTopStatusBar(state),
                  
                  // Bottom action buttons
                  _buildBottomActionButtons(),
                  
                  // Trip details bottom sheet
                  if (state.hasActiveBooking)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showRideDetailsBottomSheet,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: state.tripStatusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getStatusIcon(state.currentBooking!.status),
                                  color: state.tripStatusColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      state.tripStatusText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: state.tripStatusColor,
                                      ),
                                    ),
                                    if (_currentRoute != null)
                                      Text(
                                        '${_currentRoute!.distanceText} • ${_currentRoute!.durationText}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                state.fareText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoActiveTripView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
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
              'You\'ll see trip details here when you accept a ride',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildTopStatusBar(BookingState state) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: state.tripStatusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.tripStatusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: state.tripStatusColor,
                    ),
                  ),
                  if (state.currentBooking != null)
                    Text(
                      'Trip ID: ${state.currentBooking!.id.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.close,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'my_location',
            mini: true,
            backgroundColor: AppColors.surface,
            onPressed: () {
              if (_currentLocation != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentLocation!, 15),
                );
              }
            },
            child: Icon(
              Icons.my_location,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            backgroundColor: AppColors.surface,
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            child: Icon(
              Icons.zoom_in,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            backgroundColor: AppColors.surface,
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomOut());
            },
            child: Icon(
              Icons.zoom_out,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.access_time;
      case BookingStatus.accepted:
        return Icons.directions_car;
      case BookingStatus.started:
        return Icons.local_shipping;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
