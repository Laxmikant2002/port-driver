import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive offline service for managing offline operations and data synchronization
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  late Localstorage _localStorage;
  late Connectivity _connectivity;
  
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  final StreamController<List<OfflineOperation>> _syncController = StreamController<List<OfflineOperation>>.broadcast();
  
  Stream<bool> get connectivityStream => _connectivityController.stream;
  Stream<List<OfflineOperation>> get syncStream => _syncController.stream;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  // Use SharedPreferences for offline data storage instead of Hive
  late SharedPreferences _prefs;

  /// Initialize the offline service
  Future<void> initialize({
    required Localstorage localStorage,
    required Connectivity connectivity,
  }) async {
    _localStorage = localStorage;
    _connectivity = connectivity;
    _prefs = await SharedPreferences.getInstance();
    
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    
    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = !connectivityResult.contains(ConnectivityResult.none);
    _connectivityController.add(_isOnline);
    
    // Start periodic sync if online
    if (_isOnline) {
      _startPeriodicSync();
    }
    
    log('OfflineService initialized. Online: $_isOnline');
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = !results.contains(ConnectivityResult.none);
    
    if (wasOnline != _isOnline) {
      _connectivityController.add(_isOnline);
      
      if (_isOnline) {
        log('Connection restored. Starting sync...');
        _startPeriodicSync();
        _syncPendingOperations();
      } else {
        log('Connection lost. Stopping sync...');
        _stopPeriodicSync();
      }
    }
  }

  /// Start periodic synchronization
  void _startPeriodicSync() {
    _stopPeriodicSync(); // Stop any existing timer
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_isOnline && !_isSyncing) {
        _syncPendingOperations();
      }
    });
  }

  /// Stop periodic synchronization
  void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Store data for offline access
  Future<void> storeOfflineData(String key, Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      await _prefs.setString('offline_$key', jsonString);
      log('Stored offline data for key: $key');
    } catch (e) {
      log('Error storing offline data: $e');
    }
  }

  /// Retrieve offline data
  Map<String, dynamic>? getOfflineData(String key) {
    try {
      final jsonString = _prefs.getString('offline_$key');
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      log('Error retrieving offline data: $e');
    }
    return null;
  }

  /// Queue operation for later synchronization
  Future<void> queueOperation(OfflineOperation operation) async {
    try {
      final operationJson = jsonEncode(operation.toMap());
      await _prefs.setString('sync_${operation.id}', operationJson);
      log('Queued operation: ${operation.type} - ${operation.id}');
      
      // Try to sync immediately if online
      if (_isOnline) {
        _syncPendingOperations();
      }
    } catch (e) {
      log('Error queuing operation: $e');
    }
  }

  /// Sync pending operations
  Future<void> _syncPendingOperations() async {
    if (_isSyncing || !_isOnline) return;
    
    _isSyncing = true;
    
    try {
      final pendingOperations = <OfflineOperation>[];
      
      // Get all pending operations from SharedPreferences
      final keys = _prefs.getKeys().where((key) => key.startsWith('sync_')).toList();
      
      for (final key in keys) {
        try {
          final operationJson = _prefs.getString(key);
          if (operationJson != null) {
            final operationMap = jsonDecode(operationJson) as Map<String, dynamic>;
            final operation = OfflineOperation.fromMap(operationMap);
            pendingOperations.add(operation);
          }
        } catch (e) {
          log('Error parsing operation $key: $e');
          // Remove corrupted operation
          await _prefs.remove(key);
        }
      }
      
      if (pendingOperations.isNotEmpty) {
        log('Syncing ${pendingOperations.length} pending operations...');
        _syncController.add(pendingOperations);
        
        // Process operations in batches
        const batchSize = 10;
        for (int i = 0; i < pendingOperations.length; i += batchSize) {
          final batch = pendingOperations.skip(i).take(batchSize).toList();
          await _processOperationBatch(batch);
        }
      }
    } catch (e) {
      log('Error syncing operations: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a batch of operations
  Future<void> _processOperationBatch(List<OfflineOperation> operations) async {
    for (final operation in operations) {
      try {
        // Here you would implement the actual sync logic
        // For now, we'll just simulate successful sync
        await _simulateOperationSync(operation);
        
        // Remove from queue after successful sync
        await _prefs.remove('sync_${operation.id}');
        log('Successfully synced operation: ${operation.id}');
      } catch (e) {
        log('Failed to sync operation ${operation.id}: $e');
        // Keep operation in queue for retry
      }
    }
  }

  /// Simulate operation synchronization (replace with actual implementation)
  Future<void> _simulateOperationSync(OfflineOperation operation) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Simulate occasional failures
    if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
      throw Exception('Simulated sync failure');
    }
  }

  /// Get pending operations count
  int get pendingOperationsCount {
    final keys = _prefs.getKeys().where((key) => key.startsWith('sync_')).toList();
    return keys.length;
  }

  /// Get offline data count
  int get offlineDataCount {
    final keys = _prefs.getKeys().where((key) => key.startsWith('offline_')).toList();
    return keys.length;
  }

  /// Clear all offline data
  Future<void> clearOfflineData() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('offline_')).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
    log('Cleared all offline data');
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('sync_')).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
    log('Cleared sync queue');
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStatistics() {
    return {
      'isOnline': _isOnline,
      'pendingOperations': pendingOperationsCount,
      'offlineDataCount': offlineDataCount,
      'isSyncing': _isSyncing,
      'lastSyncTime': _localStorage.getString('last_sync_time'),
    };
  }

  /// Dispose resources
  void dispose() {
    _stopPeriodicSync();
    _connectivityController.close();
    _syncController.close();
  }
}

/// Represents an offline operation to be synchronized
class OfflineOperation {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final String? endpoint;
  final String? method;

  const OfflineOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.endpoint,
    this.method,
  });

  /// Create operation from map
  factory OfflineOperation.fromMap(Map<String, dynamic> map) {
    return OfflineOperation(
      id: map['id'] as String,
      type: map['type'] as String,
      data: map['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(map['createdAt'] as String),
      retryCount: map['retryCount'] as int? ?? 0,
      endpoint: map['endpoint'] as String?,
      method: map['method'] as String?,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'endpoint': endpoint,
      'method': method,
    };
  }

  /// Create operation for API call
  factory OfflineOperation.apiCall({
    required String id,
    required String endpoint,
    required String method,
    required Map<String, dynamic> data,
  }) {
    return OfflineOperation(
      id: id,
      type: 'api_call',
      data: data,
      createdAt: DateTime.now(),
      endpoint: endpoint,
      method: method,
    );
  }

  /// Create operation for data update
  factory OfflineOperation.dataUpdate({
    required String id,
    required String entityType,
    required Map<String, dynamic> data,
  }) {
    return OfflineOperation(
      id: id,
      type: 'data_update',
      data: {
        'entityType': entityType,
        'data': data,
      },
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'OfflineOperation(id: $id, type: $type, createdAt: $createdAt)';
  }
}
