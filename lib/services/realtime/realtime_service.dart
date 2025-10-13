import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:auth_repo/auth_repo.dart';
import 'package:trip_repo/trip_repo.dart';
import 'package:driver_status/driver_status.dart';

/// Modern real-time service for handling WebSocket connections and events
class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  IO.Socket? _socket;
  final StreamController<TripRequest> _tripRequestController = 
      StreamController<TripRequest>.broadcast();
  final StreamController<TripUpdate> _tripUpdateController = 
      StreamController<TripUpdate>.broadcast();
  final StreamController<DriverStatusUpdate> _statusUpdateController = 
      StreamController<DriverStatusUpdate>.broadcast();
  final StreamController<LocationUpdate> _locationUpdateController = 
      StreamController<LocationUpdate>.broadcast();

  // Streams for BLoCs to listen to
  Stream<TripRequest> get tripRequestStream => _tripRequestController.stream;
  Stream<TripUpdate> get tripUpdateStream => _tripUpdateController.stream;
  Stream<DriverStatusUpdate> get statusUpdateStream => _statusUpdateController.stream;
  Stream<LocationUpdate> get locationUpdateStream => _locationUpdateController.stream;

  bool get isConnected => _socket?.connected ?? false;
  String? get socketId => _socket?.id;

  /// Initialize WebSocket connection with authentication
  Future<void> initialize({
    required String baseUrl,
    required String authToken,
  }) async {
    try {
      await _disconnect();
      
      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({
              'Authorization': 'Bearer $authToken',
              'User-Agent': 'DriverApp/1.0',
            })
            .setTimeout(30000)
            .build(),
      );

      _setupEventListeners();
      await _connect();
      
      debugPrint('✅ WebSocket initialized and connected');
    } catch (e) {
      debugPrint('❌ WebSocket initialization failed: $e');
      rethrow;
    }
  }

  /// Setup all event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    _socket!
      ..onConnect((_) {
        debugPrint('🔌 WebSocket connected: ${_socket!.id}');
        _emit('driver:connected', {'timestamp': DateTime.now().toIso8601String()});
      })
      ..onDisconnect((_) {
        debugPrint('🔌 WebSocket disconnected');
      })
      ..onError((error) {
        debugPrint('❌ WebSocket error: $error');
      })
      ..onConnectError((error) {
        debugPrint('❌ WebSocket connection error: $error');
      })
      // Trip request events
      ..on('trip:request', _handleTripRequest)
      ..on('trip:assigned', _handleTripAssigned)
      ..on('trip:cancelled', _handleTripCancelled)
      ..on('trip:update', _handleTripUpdate)
      // Driver status events
      ..on('driver:status_update', _handleDriverStatusUpdate)
      // Location events
      ..on('location:update', _handleLocationUpdate)
      // System events
      ..on('system:maintenance', _handleSystemMaintenance)
      ..on('system:notification', _handleSystemNotification);
  }

  /// Connect to WebSocket
  Future<void> _connect() async {
    if (_socket != null && !_socket!.connected) {
      _socket!.connect();
      await Future.delayed(const Duration(seconds: 2)); // Wait for connection
    }
  }

  /// Disconnect from WebSocket
  Future<void> _disconnect() async {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
  }

  /// Emit event to server
  void _emit(String event, dynamic data) {
    if (_socket?.connected == true) {
      debugPrint('📤 Emitting $event: ${jsonEncode(data)}');
      _socket!.emit(event, data);
    } else {
      debugPrint('⚠️ Cannot emit $event - socket not connected');
    }
  }

  // ============ TRIP EVENTS ============

  void _handleTripRequest(dynamic data) {
    try {
      final tripRequest = TripRequest.fromJson(data as Map<String, dynamic>);
      debugPrint('🚗 Received trip request: ${tripRequest.tripId}');
      _tripRequestController.add(tripRequest);
    } catch (e) {
      debugPrint('❌ Error handling trip request: $e');
    }
  }

  void _handleTripAssigned(dynamic data) {
    try {
      final tripUpdate = TripUpdate.fromJson(data as Map<String, dynamic>);
      debugPrint('✅ Trip assigned: ${tripUpdate.tripId}');
      _tripUpdateController.add(tripUpdate);
    } catch (e) {
      debugPrint('❌ Error handling trip assigned: $e');
    }
  }

  void _handleTripCancelled(dynamic data) {
    try {
      final tripUpdate = TripUpdate.fromJson(data as Map<String, dynamic>);
      debugPrint('❌ Trip cancelled: ${tripUpdate.tripId}');
      _tripUpdateController.add(tripUpdate);
    } catch (e) {
      debugPrint('❌ Error handling trip cancelled: $e');
    }
  }

  void _handleTripUpdate(dynamic data) {
    try {
      final tripUpdate = TripUpdate.fromJson(data as Map<String, dynamic>);
      debugPrint('🔄 Trip updated: ${tripUpdate.tripId}');
      _tripUpdateController.add(tripUpdate);
    } catch (e) {
      debugPrint('❌ Error handling trip update: $e');
    }
  }

  // ============ DRIVER EVENTS ============

  void _handleDriverStatusUpdate(dynamic data) {
    try {
      final statusUpdate = DriverStatusUpdate.fromJson(data as Map<String, dynamic>);
      debugPrint('👤 Driver status updated: ${statusUpdate.status}');
      _statusUpdateController.add(statusUpdate);
    } catch (e) {
      debugPrint('❌ Error handling driver status update: $e');
    }
  }

  // ============ LOCATION EVENTS ============

  void _handleLocationUpdate(dynamic data) {
    try {
      final locationUpdate = LocationUpdate.fromJson(data as Map<String, dynamic>);
      _locationUpdateController.add(locationUpdate);
    } catch (e) {
      debugPrint('❌ Error handling location update: $e');
    }
  }

  // ============ SYSTEM EVENTS ============

  void _handleSystemMaintenance(dynamic data) {
    debugPrint('🔧 System maintenance: $data');
    // Handle system maintenance notifications
  }

  void _handleSystemNotification(dynamic data) {
    debugPrint('📢 System notification: $data');
    // Handle system notifications
  }

  // ============ OUTGOING EVENTS ============

  /// Update driver status (online/offline/busy)
  void updateDriverStatus(DriverStatus status) {
    _emit('driver:status', {
      'status': status.value,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send location updates
  void updateLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? bearing,
  }) {
    _emit('driver:location', {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'bearing': bearing,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Accept trip request
  void acceptTrip(String tripId) {
    _emit('trip:accept', {
      'tripId': tripId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Reject trip request
  void rejectTrip(String tripId, {String? reason}) {
    _emit('trip:reject', {
      'tripId': tripId,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Update trip status
  void updateTripStatus(String tripId, TripStatus status, {Map<String, dynamic>? data}) {
    _emit('trip:status_update', {
      'tripId': tripId,
      'status': status.value,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Join work area
  void joinWorkArea(String areaId, {required double latitude, required double longitude}) {
    _emit('driver:join_area', {
      'areaId': areaId,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Leave work area
  void leaveWorkArea(String areaId) {
    _emit('driver:leave_area', {
      'areaId': areaId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Dispose resources
  void dispose() {
    _tripRequestController.close();
    _tripUpdateController.close();
    _statusUpdateController.close();
    _locationUpdateController.close();
    _disconnect();
  }
}

// ============ DATA MODELS ============

class TripRequest {
  final String tripId;
  final TripLocation pickup;
  final TripLocation drop;
  final double estimatedFare;
  final double distanceKm;
  final DateTime expiresAt;
  final CustomerInfo customer;

  const TripRequest({
    required this.tripId,
    required this.pickup,
    required this.drop,
    required this.estimatedFare,
    required this.distanceKm,
    required this.expiresAt,
    required this.customer,
  });

  factory TripRequest.fromJson(Map<String, dynamic> json) {
    return TripRequest(
      tripId: json['tripId'] as String,
      pickup: TripLocation.fromJson(json['pickup'] as Map<String, dynamic>),
      drop: TripLocation.fromJson(json['drop'] as Map<String, dynamic>),
      estimatedFare: (json['estFare'] as num).toDouble(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      customer: CustomerInfo.fromJson(json['customer'] as Map<String, dynamic>),
    );
  }
}

class TripLocation {
  final double latitude;
  final double longitude;
  final String address;

  const TripLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory TripLocation.fromJson(Map<String, dynamic> json) {
    return TripLocation(
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
    );
  }
}

class CustomerInfo {
  final String maskedName;
  final String maskedPhone;

  const CustomerInfo({
    required this.maskedName,
    required this.maskedPhone,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      maskedName: json['nameMasked'] as String,
      maskedPhone: json['phoneMasked'] as String,
    );
  }
}

class TripUpdate {
  final String tripId;
  final TripStatus status;
  final String? message;
  final Map<String, dynamic>? data;

  const TripUpdate({
    required this.tripId,
    required this.status,
    this.message,
    this.data,
  });

  factory TripUpdate.fromJson(Map<String, dynamic> json) {
    return TripUpdate(
      tripId: json['tripId'] as String,
      status: TripStatus.fromString(json['status'] as String),
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class DriverStatusUpdate {
  final DriverStatus status;
  final String? message;
  final Map<String, dynamic>? data;

  const DriverStatusUpdate({
    required this.status,
    this.message,
    this.data,
  });

  factory DriverStatusUpdate.fromJson(Map<String, dynamic> json) {
    return DriverStatusUpdate(
      status: DriverStatus.fromString(json['status'] as String),
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class LocationUpdate {
  final String driverId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LocationUpdate({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      driverId: json['driverId'] as String,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
