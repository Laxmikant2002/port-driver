import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  factory SocketService() => _instance;

  SocketService._internal();
  static final SocketService _instance = SocketService._internal();

  IO.Socket? _socket;
  final StreamController<Map<String, dynamic>> _rideRequestController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _rideUpdateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _locationUpdateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get rideRequestStream => _rideRequestController.stream;
  Stream<Map<String, dynamic>> get rideUpdateStream => _rideUpdateController.stream;
  Stream<Map<String, dynamic>> get locationUpdateStream => _locationUpdateController.stream;
  
  bool get isConnected => _socket?.connected ?? false;

  Future<void> initSocket({String? authToken}) async {
    if (_socket != null) {
      _socket!.disconnect();
    }
    
    _socket = IO.io(
      'http://localhost:3002/',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders(authToken != null ? {'Authorization': 'Bearer $authToken'} : {})
          .build(),
    );

    _socket!
      ..onConnect((_) {
        debugPrint('Socket Connected: ${_socket!.id}');
        _setupEventListeners();
      })
      ..onDisconnect((_) {
        debugPrint('Socket Disconnected');
      })
      ..onError((error) {
        debugPrint('Socket Error: $error');
      })
      ..connect();
  }

  void _setupEventListeners() {
    // Listen for ride requests
    _socket!.on('ride_request', (data) {
      debugPrint('Received ride request: $data');
      if (data is Map) {
        _rideRequestController.add(Map<String, dynamic>.from(data));
      }
    });

    // Listen for ride updates
    _socket!.on('ride_update', (data) {
      debugPrint('Received ride update: $data');
      if (data is Map) {
        _rideUpdateController.add(Map<String, dynamic>.from(data));
      }
    });

    // Listen for location updates from other drivers
    _socket!.on('driver_location_update', (data) {
      debugPrint('Received location update: $data');
      if (data is Map) {
        _locationUpdateController.add(Map<String, dynamic>.from(data));
      }
    });

    // Listen for driver status updates
    _socket!.on('driver_status_update', (data) {
      debugPrint('Received driver status update: $data');
      // Handle driver status updates
    });
  }

  void connect({String? authToken}) {
    initSocket(authToken: authToken);
  }

  void emit(String event, dynamic data) {
    if (_socket?.connected == true) {
      debugPrint('Emitting $event: $data');
      _socket!.emit(event, data);
    } else {
      debugPrint('Socket not connected, cannot emit $event');
    }
  }

  // Send driver location updates
  void updateDriverLocation(Map<String, dynamic> driverData) {
    emit('update_driver_location', driverData);
  }

  // Send ride response (accept/reject)
  void respondToRideRequest(String rideId, String response, {String? reason}) {
    emit('ride_response', {
      'rideId': rideId,
      'response': response, // 'accept' or 'reject'
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Send ride status updates
  void updateRideStatus(String rideId, String status, {Map<String, dynamic>? additionalData}) {
    emit('ride_status_update', {
      'rideId': rideId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
      ...?additionalData,
    });
  }

  // Send driver status updates
  void updateDriverStatus(String status, {Map<String, dynamic>? additionalData}) {
    emit('driver_status_update', {
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
      ...?additionalData,
    });
  }

  // Join driver to a specific city/area
  void joinDriverToArea(String areaId, Map<String, dynamic> location) {
    emit('join_area', {
      'areaId': areaId,
      'location': location,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Leave driver from area
  void leaveDriverFromArea(String areaId) {
    emit('leave_area', {
      'areaId': areaId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Close the socket connection
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  IO.Socket? get socket => _socket;

  // Dispose resources
  void dispose() {
    _rideRequestController.close();
    _rideUpdateController.close();
    _locationUpdateController.close();
    disconnect();
  }
}
