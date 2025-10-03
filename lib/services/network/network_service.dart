import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver/services/core/service_interface.dart';

// Re-export types from other files for convenience
export 'socket_service.dart';
export 'offline_service.dart';

/// {@template socket_service_interface}
/// Interface for socket communication operations.
/// {@endtemplate}
abstract class SocketServiceInterface extends ServiceInterface {
  /// {@macro socket_service_interface}
  const SocketServiceInterface();

  /// Initialize socket connection
  Future<ServiceResult<void>> initSocket({String? authToken});

  /// Connect to socket
  Future<ServiceResult<void>> connect();

  /// Disconnect from socket
  Future<ServiceResult<void>> disconnect();

  /// Emit event to server
  Future<ServiceResult<void>> emit(String event, dynamic data);

  /// Listen to event from server
  void on(String event, Function(dynamic) callback);

  /// Remove event listener
  void off(String event);

  /// Check if connected
  bool get isConnected;

  /// Get connection status stream
  Stream<bool> get connectionStream;

  /// Get ride request stream
  Stream<Map<String, dynamic>> get rideRequestStream;

  /// Get ride update stream
  Stream<Map<String, dynamic>> get rideUpdateStream;

  /// Get location update stream
  Stream<Map<String, dynamic>> get locationUpdateStream;
}

/// {@template connectivity_service_interface}
/// Interface for network connectivity operations.
/// {@endtemplate}
abstract class ConnectivityServiceInterface extends ServiceInterface {
  /// {@macro connectivity_service_interface}
  const ConnectivityServiceInterface();

  /// Check current connectivity status
  Future<ServiceResult<ConnectivityResult>> checkConnectivity();

  /// Get connectivity stream
  Stream<ConnectivityResult> get connectivityStream;

  /// Check if device is online
  bool get isOnline;

  /// Get connection type
  ConnectivityResult get connectionType;

  /// Wait for connectivity
  Future<ServiceResult<void>> waitForConnectivity({
    Duration timeout = const Duration(seconds: 30),
  });
}

/// {@template offline_service_interface}
/// Interface for offline operations and data synchronization.
/// {@endtemplate}
abstract class OfflineServiceInterface extends ServiceInterface {
  /// {@macro offline_service_interface}
  const OfflineServiceInterface();

  /// Initialize offline service
  Future<ServiceResult<void>> initialize();

  /// Queue operation for offline execution
  Future<ServiceResult<void>> queueOperation({
    required String operation,
    required Map<String, dynamic> data,
  });

  /// Process queued operations
  Future<ServiceResult<void>> processQueuedOperations();

  /// Clear queued operations
  Future<ServiceResult<void>> clearQueuedOperations();

  /// Get queued operations count
  int get queuedOperationsCount;

  /// Check if operations are queued
  bool get hasQueuedOperations;

  /// Get queued operations stream
  Stream<int> get queuedOperationsStream;
}

/// {@template network_service_module}
/// Main network service module that coordinates all network operations.
/// {@endtemplate}
class NetworkServiceModule {
  /// {@macro network_service_module}
  const NetworkServiceModule({
    required this.socketService,
    required this.connectivityService,
    required this.offlineService,
  });

  final SocketServiceInterface socketService;
  final ConnectivityServiceInterface connectivityService;
  final OfflineServiceInterface offlineService;

  /// Initialize all network services
  Future<void> initialize() async {
    await socketService.initialize();
    await connectivityService.initialize();
    await offlineService.initialize();
  }

  /// Dispose all network services
  Future<void> dispose() async {
    await socketService.dispose();
    await connectivityService.dispose();
    await offlineService.dispose();
  }

  /// Get service health status
  Map<String, bool> get healthStatus => {
    'socket': socketService.isInitialized,
    'connectivity': connectivityService.isInitialized,
    'offline': offlineService.isInitialized,
  };

  /// Get network status
  NetworkStatus get networkStatus {
    if (!connectivityService.isOnline) {
      return NetworkStatus.offline;
    }
    
    if (socketService.isConnected) {
      return NetworkStatus.connected;
    }
    
    return NetworkStatus.online;
  }

  /// Smart emit that handles offline scenarios
  Future<ServiceResult<void>> smartEmit(String event, dynamic data) async {
    try {
      if (connectivityService.isOnline && socketService.isConnected) {
        return await socketService.emit(event, data);
      } else {
        // Queue for offline processing
        return await offlineService.queueOperation(
          operation: event,
          data: data as Map<String, dynamic>,
        );
      }
    } catch (e) {
      return ServiceResult.failure(NetworkServiceError(
        message: 'Failed to emit event: $e',
      ));
    }
  }

  /// Process offline operations when back online
  Future<void> handleConnectivityChange(ConnectivityResult result) async {
    if (result != ConnectivityResult.none && offlineService.hasQueuedOperations) {
      await offlineService.processQueuedOperations();
    }
  }
}

/// {@template network_status}
/// Network connection status.
/// {@endtemplate}
enum NetworkStatus {
  offline('offline'),
  online('online'),
  connected('connected');

  const NetworkStatus(this.value);
  final String value;
}

/// {@template network_service_error}
/// Error specific to network services.
/// {@endtemplate}
class NetworkServiceError extends ServiceError {
  /// {@macro network_service_error}
  const NetworkServiceError({
    required super.message,
    super.code,
    super.details,
  });
}
