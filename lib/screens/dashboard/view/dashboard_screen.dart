import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/locator.dart';
import 'package:driver/services/location_service.dart';
import 'package:driver/services/socket_service.dart';
import 'package:driver_status/driver_status.dart';
import 'package:driver/screens/booking_flow/Driver_Status/bloc/driver_status_bloc.dart';
import 'package:driver/screens/dashboard/constants/dashboard_constants.dart';

/// Modern Uber-inspired dashboard screen for Electric Loading Gadi driver app
/// Features map-centric design with proper Google Maps integration
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverStatusBloc(
        driverStatusRepo: lc<DriverStatusRepo>(),
        socketService: lc<SocketService>(),
      )..add(const DriverStatusInitialized()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  bool _isMapReady = false;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLocation();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: DashboardConstants.pulseAnimationDuration,
      vsync: this,
    )..repeat();
    
    _slideController = AnimationController(
      duration: DashboardConstants.slideAnimationDuration,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _slideController.forward();
  }

  Future<void> _initializeLocation() async {
    try {
      final initialized = await _locationService.initialize();
      if (initialized && mounted) {
        setState(() {
          _currentLocation = _locationService.currentLocation ?? const LatLng(
            DashboardConstants.nandedLat,
            DashboardConstants.nandedLng,
          );
        });
        
        if (_currentLocation != null) {
          _updateDriverLocation(_currentLocation!);
        }
        
        // Listen to location updates
        _locationService.locationStream.listen((location) {
          if (mounted) {
            setState(() {
              _currentLocation = location;
            });
            _updateDriverLocation(location);
          }
        });
      } else {
        // Fallback to Nanded center if location initialization fails
        if (mounted) {
          setState(() {
            _currentLocation = const LatLng(
              DashboardConstants.nandedLat,
              DashboardConstants.nandedLng,
            );
          });
        }
      }
    } catch (e) {
      // Handle location initialization errors gracefully
      debugPrint('Location initialization error: $e');
      if (mounted) {
        setState(() {
          _currentLocation = const LatLng(
            DashboardConstants.nandedLat,
            DashboardConstants.nandedLng,
          );
        });
      }
    }
  }

  void _updateDriverLocation(LatLng location) {
    if (_mapController != null && _isMapReady) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(location),
      );
      
      // Update driver marker with custom EV icon
      _markers.removeWhere((marker) => marker.markerId.value == 'driver');
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Electric Loading Gadi',
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _isMapReady = true;
    
    // Apply dark mode style for better night driving
    controller.setMapStyle(DashboardConstants.darkMapStyle);
    
    if (_currentLocation != null) {
      _updateDriverLocation(_currentLocation!);
    }
  }

  void _toggleOnlineStatus(bool isOnline) {
    final newStatus = isOnline ? DriverStatus.online : DriverStatus.offline;
    context.read<DriverStatusBloc>().add(DriverStatusToggled(newStatus));
    context.read<DriverStatusBloc>().add(const DriverStatusSubmitted());
  }

  void _centerOnCurrentLocation() {
    if (_currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 16),
      );
    }
  }

  void _navigateToHotspot(Map<String, dynamic> hotspot) {
    // Show hotspot details and navigate
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHotspotDetailSheet(hotspot),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map (70% of screen)
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? const LatLng(
                DashboardConstants.nandedLat, 
                DashboardConstants.nandedLng
              ),
              zoom: DashboardConstants.defaultZoom,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false, // We'll use custom marker
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            trafficEnabled: true, // Important for Indian traffic
            buildingsEnabled: true,
            onTap: (LatLng position) {
              // Handle map taps for hotspot interactions
            },
          ),
          
          // Top Header (10% of screen)
          _buildTopHeader(),
          
          // Driver Status Indicator with Pulse Animation
          if (_currentLocation != null)
            _buildPulseIndicator(),
          
          // Bottom Status Bar (20% of screen)
          _buildBottomStatusBar(),
          
          // Floating Action Buttons
          _buildFloatingActionButtons(),
          
          // Online/Offline Mode Overlay
          _buildModeOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Profile Avatar
            GestureDetector(
              onTap: () {
                // Navigate to profile
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
            
            const Spacer(),
            
            // App Title
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DashboardConstants.appTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                Text(
                  DashboardConstants.dashboardSubtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Notifications
            GestureDetector(
              onTap: () {
                // Show notifications
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    // Notification badge
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseIndicator() {
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - (DashboardConstants.pulseIndicatorSize / 2),
      top: MediaQuery.of(context).size.height / 2 - (DashboardConstants.pulseIndicatorSize / 2),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: DashboardConstants.pulseIndicatorSize * _pulseAnimation.value,
            height: DashboardConstants.pulseIndicatorSize * _pulseAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomStatusBar() {
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
      builder: (context, state) {
        return SlideTransition(
          position: _slideAnimation,
          child: Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * DashboardConstants.bottomBarHeightRatio,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Status and Earnings
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: state.isOnline 
                          ? _buildOnlineStatusContent(state)
                          : _buildOfflineStatusContent(state),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOnlineStatusContent(DriverStatusState state) {
    return Column(
      children: [
        // Online Status Row
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DashboardConstants.onlineStatusText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '2h 15m active',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Earnings Row with modern design
        Row(
          children: [
            Expanded(
              child: _buildEarningsCard(DashboardConstants.todaysEarningsTitle, '₹450', Icons.currency_rupee),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEarningsCard(DashboardConstants.tripsCompletedTitle, '8', Icons.delivery_dining),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Go Offline Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _toggleOnlineStatus(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              DashboardConstants.goOfflineButtonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineStatusContent(DriverStatusState state) {
    return Column(
      children: [
        // Offline Status
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.border,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DashboardConstants.offlineStatusText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Text(
          DashboardConstants.goOnlinePrompt,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Hotspots Card with modern design
        GestureDetector(
          onTap: () {
            // Navigate to first hotspot
            final firstHotspot = DashboardConstants.hotspots.first;
            _navigateToHotspot(firstHotspot);
          },
          child: Container(
            padding: const EdgeInsets.all(DashboardConstants.compactPadding),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DashboardConstants.borderRadius),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DashboardConstants.highDemandAreaTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${DashboardConstants.hotspots.first['name']} - ${DashboardConstants.hotspots.first['earning']} potential',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Go Online Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _toggleOnlineStatus(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.power_settings_new, size: 20),
                const SizedBox(width: 8),
                Text(
                  DashboardConstants.goOnlineButtonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * (DashboardConstants.bottomBarHeightRatio + 0.05),
      right: DashboardConstants.defaultPadding,
      child: Column(
        children: [
          // Center on location
          FloatingActionButton(
            heroTag: 'center_location',
            mini: true,
            backgroundColor: AppColors.surface,
            onPressed: _centerOnCurrentLocation,
            child: Icon(
              Icons.my_location,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Zoom controls
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

  Widget _buildModeOverlay() {
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
      builder: (context, state) {
        if (state.isOnline) {
          return const SizedBox.shrink();
        }
        
        // Show hotspots overlay when offline
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Busy Areas Nearby',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Hotspot cards from constants
                ...DashboardConstants.hotspots.take(3).map((hotspot) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildHotspotCard(
                    hotspot['name'] as String,
                    hotspot['distance'] as String,
                    hotspot['earning'] as String,
                    hotspot,
                  ),
                )).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHotspotCard(String location, String distance, String earning, Map<String, dynamic> hotspot) {
    final demand = hotspot['demand'] as String;
    final surge = hotspot['surge'] as String;
    final evCharging = hotspot['evCharging'] as bool;
    final demandColor = Color(hotspot['color'] as int);
    
    return GestureDetector(
      onTap: () => _navigateToHotspot(hotspot),
      child: Container(
        padding: const EdgeInsets.all(DashboardConstants.compactPadding),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(DashboardConstants.borderRadius),
          border: Border.all(
            color: AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: demandColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Demand indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: demandColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (surge != '1.0x')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            surge,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '$distance away • $earning potential',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (evCharging) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.electric_bolt,
                          size: 12,
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: demandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: demandColor,
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotspotDetailSheet(Map<String, dynamic> hotspot) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(DashboardConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(hotspot['color'] as int),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotspot['name'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              hotspot['nameHindi'] as String,
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
                  
                  const SizedBox(height: 20),
                  
                  // Details
                  _buildDetailRow(Icons.timer, 'Distance', hotspot['distance'] as String),
                  _buildDetailRow(Icons.currency_rupee, 'Earning Potential', hotspot['earning'] as String),
                  _buildDetailRow(Icons.trending_up, 'Demand Level', (hotspot['demand'] as String).toUpperCase()),
                  if (hotspot['surge'] != '1.0x')
                    _buildDetailRow(Icons.local_fire_department, 'Surge Multiplier', hotspot['surge'] as String),
                  if (hotspot['evCharging'] as bool)
                    _buildDetailRow(Icons.electric_bolt, 'EV Charging', 'Available'),
                  
                  const Spacer(),
                  
                  // Navigate button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement navigation to hotspot
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(hotspot['color'] as int),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DashboardConstants.borderRadius),
                        ),
                      ),
                      child: const Text(
                        'Navigate to Area',
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
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _locationService.dispose();
    super.dispose();
  }
}
