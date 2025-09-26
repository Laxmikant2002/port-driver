import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/screens/booking_flow/Driver_Status/bloc/driver_status_bloc.dart';
import 'package:driver_status/driver_status.dart';
import 'package:driver/widgets/ui_components/bottom_sheets/incoming_delivery_request_sheet.dart';

/// Modern Driver Dashboard with sliding_up_panel implementation
class ModernDriverDashboard extends StatefulWidget {
  const ModernDriverDashboard({super.key});

  @override
  State<ModernDriverDashboard> createState() => _ModernDriverDashboardState();
}

class _ModernDriverDashboardState extends State<ModernDriverDashboard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Panel controller for sliding panel
  final PanelController _panelController = PanelController();
  
  // Sample data
  final List<DeliveryRequest> _activeRequests = [];
  final List<DeliveryHistory> _recentDeliveries = [
    DeliveryHistory(
      customerName: 'Rajesh Kumar',
      pickupLocation: 'Nanded City Center',
      dropLocation: 'Airport Road',
      fare: 180.0,
      distance: '8.5 km',
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    DeliveryHistory(
      customerName: 'Priya Sharma',
      pickupLocation: 'Mahur Road',
      dropLocation: 'Bus Stand',
      fare: 120.0,
      distance: '5.2 km',
      completedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
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

  void _toggleOnlineStatus(bool value) {
    final newStatus = value ? DriverStatus.online : DriverStatus.offline;
    context.read<DriverStatusBloc>().add(DriverStatusToggled(newStatus));
    context.read<DriverStatusBloc>().add(const DriverStatusSubmitted());
  }

  void _simulateIncomingRequest() {
    setState(() {
      _activeRequests.add(DeliveryRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        customerName: 'Amit Patel',
        pickupLocation: 'Nanded City Center',
        dropLocation: 'Airport Road',
        fare: 220.0,
        distance: '12.5 km',
        estimatedTime: '25 min',
      ));
    });
    
    // Show incoming request bottom sheet
    _showIncomingRequestSheet();
  }

  void _showIncomingRequestSheet() {
    if (_activeRequests.isNotEmpty) {
      final request = _activeRequests.last;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => IncomingDeliveryRequestSheet(
          customerName: request.customerName,
          pickupLocation: request.pickupLocation,
          dropLocation: request.dropLocation,
          fare: request.fare,
          distance: request.distance,
          estimatedTime: request.estimatedTime,
          onAccept: () {
            Navigator.pop(context);
            setState(() {
              // Move to active delivery
            });
          },
          onReject: () {
            Navigator.pop(context);
            setState(() {
              _activeRequests.removeWhere((req) => req.id == request.id);
            });
          },
          timeRemaining: 15,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SlidingUpPanel(
            controller: _panelController,
            minHeight: 120, // Collapsed height
            maxHeight: MediaQuery.of(context).size.height * 0.6, // Expanded height (60%)
            panel: _buildPanelContent(state),
            body: _buildMapBody(state),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            backdropEnabled: false,
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            onPanelSlide: (position) {
              // Optional: Handle panel slide events
            },
          ),
        );
      },
    );
  }

  /// Map Body (Background)
  Widget _buildMapBody(DriverStatusState state) {
    return Stack(
      children: [
        // 1. Map as Background (Full Screen)
        _buildMap(state),
        
        // 2. Top Status Bar
        _buildTopStatusBar(state),
        
        // 3. Floating Buttons
        _buildFloatingButtons(state),
      ],
    );
  }

  /// 1. Map as Background (Full Screen)
  Widget _buildMap(DriverStatusState state) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: state.currentLocation ?? const LatLng(19.1536, 77.3051),
        zoom: 15,
      ),
      markers: _buildMapMarkers(state),
      polylines: _buildPolylines(state),
      onMapCreated: (controller) {
        context.read<DriverStatusBloc>().add(MapControllerUpdated(controller));
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: false,
      trafficEnabled: state.isOnline,
    );
  }

  Set<Marker> _buildMapMarkers(DriverStatusState state) {
    Set<Marker> markers = {};
    
    // Driver location marker
    if (state.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: state.currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            state.isOnline ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue,
          ),
          infoWindow: InfoWindow(
            title: state.isOnline ? 'You\'re Online' : 'You\'re Offline',
          ),
        ),
      );
    }
    
    // Active delivery markers
    for (var request in _activeRequests) {
      markers.add(
        Marker(
          markerId: MarkerId('pickup_${request.id}'),
          position: const LatLng(19.1536, 77.3051),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'Pickup: ${request.pickupLocation}',
            snippet: 'Customer: ${request.customerName}',
          ),
        ),
      );
    }
    
    return markers;
  }

  Set<Polyline> _buildPolylines(DriverStatusState state) {
    // TODO: Implement route polylines for active deliveries
    return <Polyline>{};
  }

  /// 2. Top Status Bar
  Widget _buildTopStatusBar(DriverStatusState state) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status indicator with pulsing animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: state.isOnline ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: state.isOnline ? [
                      BoxShadow(
                        color: AppColors.success.withOpacity(_pulseAnimation.value * 0.5),
                        blurRadius: 8 * _pulseAnimation.value,
                        spreadRadius: 2 * _pulseAnimation.value,
                      ),
                    ] : null,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            
            // Status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.isOnline ? 'You\'re Online ✅' : 'You\'re Offline 🚫',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: state.isOnline ? AppColors.success : AppColors.error,
                    ),
                  ),
                  if (state.isOnline)
                    Text(
                      'Active for 15m • ${_activeRequests.length} active requests',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            
            // Notification bell
            IconButton(
              onPressed: () {
                // TODO: Show notifications
              },
              icon: Icon(
                Icons.notifications_active,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Floating Buttons
  Widget _buildFloatingButtons(DriverStatusState state) {
    return Positioned(
      bottom: 200, // Above the sliding panel
      right: 16,
      child: Column(
        children: [
          // SOS/Help button
          FloatingActionButton(
            heroTag: 'sos',
            backgroundColor: AppColors.error,
            onPressed: () => _showSOSDialog(),
            child: const Icon(
              Icons.sos,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          // Current location button
          FloatingActionButton(
            heroTag: 'my_location',
            backgroundColor: AppColors.surface,
            onPressed: () {
              if (state.mapController != null && state.currentLocation != null) {
                state.mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(state.currentLocation!, 15),
                );
              }
            },
            child: Icon(
              Icons.my_location,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Zoom in button
          FloatingActionButton(
            heroTag: 'zoom_in',
            backgroundColor: AppColors.surface,
            onPressed: () {
              state.mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            child: Icon(
              Icons.zoom_in,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Zoom out button
          FloatingActionButton(
            heroTag: 'zoom_out',
            backgroundColor: AppColors.surface,
            onPressed: () {
              state.mapController?.animateCamera(CameraUpdate.zoomOut());
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

  /// Panel Content (Collapsible/Expandable)
  Widget _buildPanelContent(DriverStatusState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Panel content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver Status & Toggle
                  _buildDriverStatusSection(state),
                  
                  const SizedBox(height: 20),
                  
                  // Today's Summary
                  _buildSummarySection(state),
                  
                  const SizedBox(height: 20),
                  
                  // Active Deliveries
                  if (_activeRequests.isNotEmpty) ...[
                    _buildActiveDeliveriesSection(),
                    const SizedBox(height: 20),
                  ],
                  
                  // Recent Deliveries
                  _buildRecentDeliveriesSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Test button for demo
                  if (state.isOnline)
                    _buildTestButton(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatusSection(DriverStatusState state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver Status',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                state.statusDisplayText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: state.isOnline ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: state.isOnline,
          onChanged: _toggleOnlineStatus,
          activeColor: AppColors.success,
          inactiveThumbColor: AppColors.error,
          inactiveTrackColor: AppColors.error.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildSummarySection(DriverStatusState state) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Today\'s Earnings',
            state.earningsText,
            AppColors.success,
            Icons.account_balance_wallet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Completed Deliveries',
            state.tripsText,
            AppColors.cyan,
            Icons.local_shipping,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Deliveries',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._activeRequests.map((request) => _buildActiveDeliveryCard(request)),
      ],
    );
  }

  Widget _buildActiveDeliveryCard(DeliveryRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Active Delivery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '₹${request.fare.toInt()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Customer: ${request.customerName}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pickup: ${request.pickupLocation}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Drop: ${request.dropLocation}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Call customer
                  },
                  icon: Icon(Icons.phone, size: 16),
                  label: Text('Call'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Open navigation
                  },
                  icon: Icon(Icons.navigation, size: 16),
                  label: Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDeliveriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Deliveries',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._recentDeliveries.map((delivery) => _buildDeliveryHistoryCard(delivery)),
      ],
    );
  }

  Widget _buildDeliveryHistoryCard(DeliveryHistory delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle,
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
                  delivery.customerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${delivery.pickupLocation} → ${delivery.dropLocation}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${delivery.fare.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              Text(
                delivery.distance,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _simulateIncomingRequest,
        icon: const Icon(Icons.add),
        label: const Text('Simulate Incoming Request'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showSOSDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.sos,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Emergency SOS',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'This will immediately alert emergency services and your emergency contact. Are you sure?',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('SOS alert sent! Emergency services notified.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }
}

/// Data models
class DeliveryRequest {
  final String id;
  final String customerName;
  final String pickupLocation;
  final String dropLocation;
  final double fare;
  final String distance;
  final String estimatedTime;

  DeliveryRequest({
    required this.id,
    required this.customerName,
    required this.pickupLocation,
    required this.dropLocation,
    required this.fare,
    required this.distance,
    required this.estimatedTime,
  });
}

class DeliveryHistory {
  final String customerName;
  final String pickupLocation;
  final String dropLocation;
  final double fare;
  final String distance;
  final DateTime completedAt;

  DeliveryHistory({
    required this.customerName,
    required this.pickupLocation,
    required this.dropLocation,
    required this.fare,
    required this.distance,
    required this.completedAt,
  });
}