import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver/locator.dart';
import 'package:driver/screens/booking_flow/Driver_Status/bloc/driver_status_bloc.dart';
import 'package:driver/services/location_service.dart';
import 'package:driver/services/google_map_services.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/widgets/ui_components/bottom_sheets/ride_request_bottom_sheet.dart';
import 'package:driver/widgets/ui_components/bottom_sheets/ride_details_bottom_sheet.dart';
import 'package:driver/widgets/ui_components/bottom_sheets/driver_status_bottom_sheet.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final GoogleMapServices _mapServices = GoogleMapServices();
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
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
      if (_currentLocation != null) {
        _updateMapLocation(_currentLocation!);
      }
      
      // Listen to location updates
      _locationService.locationStream.listen((location) {
        if (mounted) {
          setState(() {
            _currentLocation = location;
          });
          _updateMapLocation(location);
        }
      });
    }
  }

  void _updateMapLocation(LatLng location) {
    if (_mapController != null && _isMapReady) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(location),
      );
      
      // Update driver marker
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
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _isMapReady = true;
    
    if (_currentLocation != null) {
      _updateMapLocation(_currentLocation!);
    }
  }

  void _showRideRequestBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RideRequestBottomSheet(),
    );
  }

  void _showRideDetailsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RideDetailsBottomSheet(),
    );
  }

  void _showDriverStatusBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DriverStatusBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverStatusBloc(
        driverStatusRepo: lc(),
        socketService: lc(),
      )..add(const DriverStatusInitialized()),
      child: Scaffold(
        body: Stack(
          children: [
            // Google Map
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? const LatLng(19.7515, 75.7139), // Maharashtra center
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onTap: (LatLng location) {
                // Handle map tap if needed
              },
            ),
            
            // Top Status Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: BlocBuilder<DriverStatusBloc, DriverStatusState>(
                builder: (context, state) {
                  return Container(
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
                        // Status indicator
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: state.isOnline ? AppColors.success : AppColors.error,
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
                                state.statusDisplayText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: state.isOnline ? AppColors.success : AppColors.error,
                                ),
                              ),
                              if (state.hasWorkArea)
                                Text(
                                  'in ${state.workArea.value}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Settings button
                        IconButton(
                          onPressed: _showDriverStatusBottomSheet,
                          icon: Icon(
                            Icons.settings,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Action Buttons
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: Column(
                children: [
                  // My Location Button
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
                  
                  // Zoom In Button
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
                  
                  // Zoom Out Button
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
            ),
            
            // Bottom Status Sheet (when online)
            BlocBuilder<DriverStatusBloc, DriverStatusState>(
              builder: (context, state) {
                if (!state.isOnline) return const SizedBox.shrink();
                
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Status content
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                color: AppColors.success,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Looking for rides',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'You\'ll receive ride requests here',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${state.earningsToday.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
