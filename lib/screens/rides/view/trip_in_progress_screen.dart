import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripInProgressScreen extends StatefulWidget {
  final String riderName;
  final String dropoffLocation;
  final LatLng driverLocation;
  final LatLng dropoffLatLng;
  final VoidCallback onContactRider;
  final VoidCallback onEndTrip;

  const TripInProgressScreen({
    super.key,
    required this.riderName,
    required this.dropoffLocation,
    required this.driverLocation,
    required this.dropoffLatLng,
    required this.onContactRider,
    required this.onEndTrip,
  });

  @override
  State<TripInProgressScreen> createState() => _TripInProgressScreenState();
}

class _TripInProgressScreenState extends State<TripInProgressScreen> {
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  String _eta = '8 min';
  String _distance = '3.2 km';
  bool _canEndTrip = true; // For demo, always enabled

  @override
  void initState() {
    super.initState();
    _setupRoute();
  }

  void _setupRoute() {
    // For demo, create a straight line polyline between driver and drop-off
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      width: 6,
      points: [widget.driverLocation, widget.dropoffLatLng],
    );
    final driverMarker = Marker(
      markerId: const MarkerId('driver'),
      position: widget.driverLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    final dropoffMarker = Marker(
      markerId: const MarkerId('dropoff'),
      position: widget.dropoffLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      _polylines = {polyline};
      _markers = {driverMarker, dropoffMarker};
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Optionally animate camera to fit both points
    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              (widget.driverLocation.latitude < widget.dropoffLatLng.latitude)
                  ? widget.driverLocation.latitude
                  : widget.dropoffLatLng.latitude,
              (widget.driverLocation.longitude < widget.dropoffLatLng.longitude)
                  ? widget.driverLocation.longitude
                  : widget.dropoffLatLng.longitude,
            ),
            northeast: LatLng(
              (widget.driverLocation.latitude > widget.dropoffLatLng.latitude)
                  ? widget.driverLocation.latitude
                  : widget.dropoffLatLng.latitude,
              (widget.driverLocation.longitude > widget.dropoffLatLng.longitude)
                  ? widget.driverLocation.longitude
                  : widget.dropoffLatLng.longitude,
            ),
          ),
          80,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.driverLocation,
              zoom: 14,
            ),
            polylines: _polylines,
            markers: _markers,
            onMapCreated: _onMapCreated,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
          ),
          // Overlay card
          Positioned(
            left: 0,
            right: 0,
            top: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer, color: Colors.blue[700], size: 22),
                          const SizedBox(width: 6),
                          Text(
                            _eta,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Icon(Icons.route, color: Colors.green[700], size: 22),
                          const SizedBox(width: 6),
                          Text(
                            _distance,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFE0E0E0),
                            child: Icon(Icons.person, color: Colors.black54, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.riderName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.blue, size: 24),
                            onPressed: widget.onContactRider,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.dropoffLocation,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // End Trip button
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _canEndTrip ? widget.onEndTrip : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'End Trip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Test End Trip button
                  TextButton(
                    onPressed: widget.onEndTrip,
                    child: const Text(
                      'Test End Trip',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
} 