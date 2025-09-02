import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/locator.dart';
import 'package:driver/screens/rides/bloc/rides_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver/screens/rides/view/driver_status_bottom_sheet.dart';
import 'package:driver/screens/rides/view/ride_request_bottom_sheet.dart';
import 'package:driver/screens/rides/view/ride_details_bottom_sheet.dart';

class RideScreen extends StatelessWidget {
  const RideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RidesBloc(lc())..add(GetCurrentLocation()),
      child: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleOnlineStatus(bool value) {
    debugPrint('Toggling online status to: $value');
    try {
      context.read<RidesBloc>().add(OnlineStatusChanged(value));
    } catch (e, stackTrace) {
      debugPrint('Error in toggleOnlineStatus: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void recenterMap(BuildContext context, RidesState state) {
    try {
      if (state.controller != null && state.sourceAddress?.latLng != null) {
        state.controller!.animateCamera(
          CameraUpdate.newLatLng(state.sourceAddress!.latLng!),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error in recenterMap: $e\n$stackTrace');
    }
  }

  void _showRideDetailsBottomSheet(BuildContext context) async {
    if (!mounted) return;
    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => RideDetailsBottomSheet(
          riderName: 'John Doe',
          pickupLocation: '123 Main St, City',
          dropoffLocation: '456 Elm St, City',
          estimatedTime: '5 min',
          estimatedDistance: '2.5 km',
          onContactRider: () {
            debugPrint('Contact rider tapped');
          },
          onCancelRide: () {
            debugPrint('Cancel ride tapped');
            Navigator.pop(context);
          },
          onArrived: () {
            debugPrint('Arrived tapped');
            Navigator.pop(context);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip start confirmed!')),
              );
            }
          },
          arrivedEnabled: true,
        ),
      );
    } catch (e, stack) {
      debugPrint('Error showing RideDetailsBottomSheet: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RidesBloc, RidesState>(
      builder: (context, state) {
        final isOnline = state.isDriverOnline;
        final currentLatLng = state.sourceAddress?.latLng;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: Text(
                                isOnline ? 'Online' : 'Offline',
                                key: ValueKey(isOnline),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: isOnline ? 1 : 0,
                              duration: const Duration(milliseconds: 400),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  width: isOnline ? 14 : 0,
                                  height: isOnline ? 14 : 0,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent,
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Switch(
                        value: isOnline,
                        onChanged: toggleOnlineStatus,
                        activeColor: Colors.black,
                        inactiveThumbColor: Colors.grey[400],
                        inactiveTrackColor: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentLatLng ?? const LatLng(11.623377, 92.726486),
                  zoom: state.zoom,
                ),
                markers: (state.currentStatus == 'Loaded' && currentLatLng != null)
                    ? {
                        Marker(
                          markerId: const MarkerId('SourceMarker'),
                          position: currentLatLng,
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                        ),
                      }
                    : <Marker>{},
                polylines: state.polylines.isNotEmpty
                    ? Set<Polyline>.of(state.polylines.values)
                    : <Polyline>{},
                onMapCreated: (controller) {
                  try {
                    context.read<RidesBloc>().add(UpdateController(controller));
                  } catch (e, stack) {
                    debugPrint('Error in onMapCreated: $e\n$stack');
                  }
                },
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
              ),
              // Animated marker pulse
              if (state.currentStatus == 'Loaded' && currentLatLng != null)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final size = 60.0 * _pulseAnimation.value;
                    return Positioned(
                      left: MediaQuery.of(context).size.width / 2 - size / 2,
                      top: MediaQuery.of(context).size.height / 2 - size / 2 - 60,
                      child: IgnorePointer(
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.blue.withOpacity(0.2),
                                Colors.blue.withOpacity(0.01),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              // Floating action button for recenter
              if (currentLatLng != null)
                Positioned(
                  bottom: 32,
                  right: 24,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    elevation: 6,
                    onPressed: () => recenterMap(context, state),
                    child: const Icon(Icons.my_location, color: Colors.black),
                  ),
                ),
              // Animated glassy info card for offline
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                bottom: isOnline ? -350 : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: isOnline ? 0 : 1,
                  child: DriverStatusBottomSheet(
                    isOnline: false,
                    requiredActions: [
                      DriverActionItem(
                        title: 'Turn on overlay permissions',
                        subtitle: 'Go to device Settings',
                        icon: Icons.settings,
                        onTap: () {},
                      ),
                      DriverActionItem(
                        title: 'Turn on push notifications',
                        subtitle: 'Go to device Settings',
                        icon: Icons.notifications,
                        onTap: () {},
                      ),
                    ],
                    onMenuTap: () {},
                  ),
                ),
              ),
              // Test Ride Request Button (only when online)
              if (isOnline)
                Positioned(
                  bottom: 100,
                  right: 24,
                  child: FloatingActionButton.extended(
                    heroTag: 'test_ride_request',
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.directions_car),
                    label: const Text('Test Ride Request'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => RideRequestBottomSheet(
                          riderName: 'John Doe',
                          riderRating: 4.8,
                          pickupLocation: '123 Main St, City',
                          dropoffLocation: '456 Elm St, City',
                          estimatedTime: '5 min',
                          estimatedFare: '₹410.00',
                          onAccept: () {
                            debugPrint('Accept ride tapped');
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 300), () {
                              if (mounted) {
                                _showRideDetailsBottomSheet(context);
                              }
                            });
                          },
                          onReject: () {
                            debugPrint('Reject ride tapped');
                            Navigator.pop(context);
                            // Add reject logic here
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}