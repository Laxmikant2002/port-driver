import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
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
  final PanelController _panelController = PanelController();
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  bool _isMapReady = false;
  
  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _configureSystemUI();
    _initializeAnimations();
    _initializeLocation();
  }

  void _configureSystemUI() {
    // Configure system UI overlay style for better visibility over dark map
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons for dark background
        statusBarBrightness: Brightness.dark, // For iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: DashboardConstants.pulseAnimationDuration,
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    ));
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
    
  // Apply light mode style for white map background
  controller.setMapStyle(DashboardConstants.lightMapStyle);
    
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: SlidingUpPanel(
          controller: _panelController,
          minHeight: 120, // Collapsed height
          maxHeight: MediaQuery.of(context).size.height * 0.8, // 80% of screen when expanded
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          parallaxEnabled: true,
          parallaxOffset: 0.5,
          body: Stack(
          children: [
            // Google Map (Full Screen Background)
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
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              trafficEnabled: true,
              buildingsEnabled: true,
            ),
            
            // Top Header
            _buildTopHeader(),
            
            // Driver Status Indicator with Pulse Animation
            if (_currentLocation != null)
              _buildPulseIndicator(),
            
            // Floating Action Buttons
            _buildFloatingActionButtons(),
          ],
        ),
        panelBuilder: (scrollController) => _buildBottomPanel(scrollController),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).padding.top + 80,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 16,
          right: 16,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.85),
              Colors.black.withOpacity(0.65),
              Colors.black.withOpacity(0.35),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Online/Offline Toggle Button
            BlocBuilder<DriverStatusBloc, DriverStatusState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    _toggleOnlineStatus(!state.isOnline);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: state.isOnline ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.isOnline ? 'Online' : 'Offline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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

  Widget _buildBottomPanel(ScrollController scrollController) {
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
      builder: (context, state) {
        return Container(
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
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Collapsed content (always visible)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: state.isOnline 
                    ? _buildOnlineCollapsedContent(state)
                    : _buildOfflineCollapsedContent(state),
              ),
              
              // Expanded content (visible when panel is expanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: _buildExpandedContent(state),
              ),
            ],
          ),
        );
      },
    );
  }

  // Collapsed content (always visible at bottom)
  Widget _buildOnlineCollapsedContent(DriverStatusState state) {
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '2h 15m active',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Earnings Row (compact for collapsed state)
        Row(
          children: [
            Expanded(
              child: _buildCompactEarningsCard(DashboardConstants.todaysEarningsTitle, '₹450'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactEarningsCard(DashboardConstants.tripsCompletedTitle, '8'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOfflineCollapsedContent(DriverStatusState state) {
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Go Online Button (compact)
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => _toggleOnlineStatus(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              DashboardConstants.goOnlineButtonText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Expanded content (visible when panel is swiped up)
  Widget _buildExpandedContent(DriverStatusState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Delivery Section
        if (state.isOnline) ...[
          _buildSectionHeader('Active Delivery', Icons.local_shipping),
          const SizedBox(height: 12),
          _buildActiveDeliveryCard(),
          const SizedBox(height: 24),
        ],
        
        // Delivery History Section
        _buildSectionHeader('Recent Deliveries', Icons.history),
        const SizedBox(height: 12),
        _buildDeliveryHistoryList(),
        const SizedBox(height: 24),
        
        // Earnings Details Section
        _buildSectionHeader('Today\'s Earnings', Icons.account_balance_wallet),
        const SizedBox(height: 12),
        _buildDetailedEarningsCards(),
        const SizedBox(height: 24),
        
        // Action Buttons
        if (state.isOnline) 
          _buildOfflineButton()
        else 
          _buildOnlineButton(),
        
        const SizedBox(height: 20), // Bottom padding
      ],
    );
  }

  // Helper methods for the new panel design
  Widget _buildCompactEarningsCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Rajesh Kumar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'On Route',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Pickup: Nanded Railway Station',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.flag, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Drop: Aurangabad MIDC',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '₹180',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                '12.5 km • 25 min',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryHistoryList() {
    return Column(
      children: List.generate(3, (index) => _buildDeliveryHistoryItem(index)),
    );
  }

  Widget _buildDeliveryHistoryItem(int index) {
    final deliveries = [
      {'customer': 'Priya Sharma', 'amount': '₹120', 'location': 'Nanded City → Hadgaon'},
      {'customer': 'Amit Patil', 'amount': '₹95', 'location': 'SRTMU → Degloor'},
      {'customer': 'Sunita Devi', 'amount': '₹150', 'location': 'Nanded Fort → Kinwat'},
    ];
    
    final delivery = deliveries[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
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
                  delivery['customer']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  delivery['location']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            delivery['amount']!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedEarningsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildDetailedEarningsCard('Total Earnings', '₹450', Icons.account_balance_wallet),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailedEarningsCard('Completed', '8 trips', Icons.delivery_dining),
        ),
      ],
    );
  }

  Widget _buildDetailedEarningsCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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

  Widget _buildOfflineButton() {
    return SizedBox(
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
    );
  }

  Widget _buildOnlineButton() {
    return SizedBox(
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
    );
  }

  Widget _buildFloatingActionButtons() {
    return Positioned(
      bottom: 140, // Position above the collapsed panel (120px + 20px margin)
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







  @override
  void dispose() {
    // Reset system UI to default when leaving dashboard
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Default dark icons
        statusBarBrightness: Brightness.light, // For iOS
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    _pulseController.dispose();
    _locationService.dispose();
    super.dispose();
  }
}
