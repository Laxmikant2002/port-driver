import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:driver_status/driver_status.dart';
import 'package:driver/services/realtime/realtime_service.dart';
import 'package:geolocator/geolocator.dart';

part 'driver_status_event.dart';
part 'driver_status_state.dart';

/// Modern Driver Status BLoC for managing driver availability and location
class DriverStatusBloc extends Bloc<DriverStatusEvent, DriverStatusState> {
  DriverStatusBloc({
    required this.driverStatusRepo,
    required this.realtimeService,
  }) : super(const DriverStatusState.initial()) {
    on<DriverStatusInitialized>(_onInitialized);
    on<DriverWentOnline>(_onWentOnline);
    on<DriverWentOffline>(_onWentOffline);
    on<DriverLocationUpdated>(_onLocationUpdated);
    on<DriverWorkAreaChanged>(_onWorkAreaChanged);
    on<DriverStatusErrorOccurred>(_onErrorOccurred);
    on<DriverLocationTrackingStarted>(_onLocationTrackingStarted);
    on<DriverLocationTrackingStopped>(_onLocationTrackingStopped);
  }

  final DriverStatusRepo driverStatusRepo;
  final RealtimeService realtimeService;
  
  Timer? _locationUpdateTimer;
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;

  /// Initialize driver status
  void _onInitialized(DriverStatusInitialized event, Emitter<DriverStatusState> emit) async {
    emit(state.copyWith(status: DriverStatusBlocStatus.initializing));

    try {
      final response = await driverStatusRepo.getDriverStatus();
      
      if (response.success) {
        emit(state.copyWith(
          status: DriverStatusBlocStatus.idle,
          driverStatus: response.status ?? DriverStatus.offline,
          workArea: response.workArea,
          lastActiveAt: response.lastActiveAt,
          earningsToday: response.earningsToday ?? 0.0,
          tripsToday: response.tripsToday ?? 0,
        ));
      } else {
        emit(state.copyWith(
          status: DriverStatusBlocStatus.error,
          errorMessage: response.message ?? 'Failed to fetch driver status',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DriverStatusBlocStatus.error,
        errorMessage: 'Network error: $e',
      ));
    }
  }

  /// Driver goes online
  void _onWentOnline(DriverWentOnline event, Emitter<DriverStatusState> emit) async {
    if (state.driverStatus == DriverStatus.online) return;

    emit(state.copyWith(status: DriverStatusBlocStatus.goingOnline));

    try {
      // Update status on server
      final response = await driverStatusRepo.updateDriverStatus(DriverStatus.online);
      
      if (response.success) {
        // Emit WebSocket status update
        realtimeService.updateDriverStatus(DriverStatus.online);
        
        // Start location tracking
        add(const DriverLocationTrackingStarted());
        
        emit(state.copyWith(
          status: DriverStatusBlocStatus.idle,
          driverStatus: DriverStatus.online,
          isLocationTracking: true,
        ));
      } else {
        emit(state.copyWith(
          status: DriverStatusBlocStatus.error,
          errorMessage: response.message ?? 'Failed to go online',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DriverStatusBlocStatus.error,
        errorMessage: 'Failed to go online: $e',
      ));
    }
  }

  /// Driver goes offline
  void _onWentOffline(DriverWentOffline event, Emitter<DriverStatusState> emit) async {
    if (state.driverStatus == DriverStatus.offline) return;

    emit(state.copyWith(status: DriverStatusBlocStatus.goingOffline));

    try {
      // Stop location tracking
      add(const DriverLocationTrackingStopped());
      
      // Update status on server
      final response = await driverStatusRepo.updateDriverStatus(DriverStatus.offline);
      
      if (response.success) {
        // Emit WebSocket status update
        realtimeService.updateDriverStatus(DriverStatus.offline);
        
        emit(state.copyWith(
          status: DriverStatusBlocStatus.idle,
          driverStatus: DriverStatus.offline,
          isLocationTracking: false,
        ));
      } else {
        emit(state.copyWith(
          status: DriverStatusBlocStatus.error,
          errorMessage: response.message ?? 'Failed to go offline',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DriverStatusBlocStatus.error,
        errorMessage: 'Failed to go offline: $e',
      ));
    }
  }

  /// Update driver location
  void _onLocationUpdated(DriverLocationUpdated event, Emitter<DriverStatusState> emit) async {
    if (state.driverStatus != DriverStatus.online) return;

    try {
      // Check if location has changed significantly (minimum 10 meters)
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          event.latitude,
          event.longitude,
        );
        
        if (distance < 10) return; // Don't update if movement is less than 10 meters
      }

      _lastPosition = Position(
        latitude: event.latitude,
        longitude: event.longitude,
        timestamp: DateTime.now(),
        accuracy: event.accuracy ?? 0.0,
        altitude: 0.0,
        heading: event.bearing ?? 0.0,
        speed: event.speed ?? 0.0,
        speedAccuracy: 0.0,
      );

      // Update location on server
      final response = await driverStatusRepo.updateLocation(
        latitude: event.latitude,
        longitude: event.longitude,
        accuracy: event.accuracy,
      );

      // Emit WebSocket location update
      realtimeService.updateLocation(
        latitude: event.latitude,
        longitude: event.longitude,
        accuracy: event.accuracy,
        speed: event.speed,
        bearing: event.bearing,
      );

      // Update state with new location
      emit(state.copyWith(
        currentLatitude: event.latitude,
        currentLongitude: event.longitude,
        lastLocationUpdate: DateTime.now(),
      ));

    } catch (e) {
      debugPrint('Failed to update driver location: $e');
      // Don't emit error for location updates as they're not critical
    }
  }

  /// Change work area
  void _onWorkAreaChanged(DriverWorkAreaChanged event, Emitter<DriverStatusState> emit) async {
    try {
      final response = await driverStatusRepo.setWorkArea(event.workArea);
      
      if (response.success) {
        emit(state.copyWith(workArea: event.workArea));
        
        // Join new work area via WebSocket
        realtimeService.joinWorkArea(
          event.workArea.id,
          latitude: event.workArea.latitude,
          longitude: event.workArea.longitude,
        );
      } else {
        emit(state.copyWith(
          status: DriverStatusBlocStatus.error,
          errorMessage: response.message ?? 'Failed to change work area',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DriverStatusBlocStatus.error,
        errorMessage: 'Failed to change work area: $e',
      ));
    }
  }

  /// Start location tracking
  void _onLocationTrackingStarted(DriverLocationTrackingStarted event, Emitter<DriverStatusState> emit) async {
    try {
      // Check location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(state.copyWith(
          status: DriverStatusBlocStatus.error,
          errorMessage: 'Location services are disabled',
        ));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(state.copyWith(
            status: DriverStatusBlocStatus.error,
            errorMessage: 'Location permissions are denied',
          ));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(state.copyWith(
          status: DriverStatusBlocStatus.error,
          errorMessage: 'Location permissions are permanently denied',
        ));
        return;
      }

      // Start listening to position updates
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen(
        (Position position) {
          add(DriverLocationUpdated(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            speed: position.speed,
            bearing: position.heading,
          ));
        },
        onError: (error) {
          debugPrint('Location stream error: $error');
        },
      );

      emit(state.copyWith(isLocationTracking: true));
    } catch (e) {
      emit(state.copyWith(
        status: DriverStatusBlocStatus.error,
        errorMessage: 'Failed to start location tracking: $e',
      ));
    }
  }

  /// Stop location tracking
  void _onLocationTrackingStopped(DriverLocationTrackingStopped event, Emitter<DriverStatusState> emit) {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    
    emit(state.copyWith(isLocationTracking: false));
  }

  /// Handle errors
  void _onErrorOccurred(DriverStatusErrorOccurred event, Emitter<DriverStatusState> emit) {
    emit(state.copyWith(
      status: DriverStatusBlocStatus.error,
      errorMessage: event.errorMessage,
    ));
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    return super.close();
  }
}

// ============ EVENTS ============

abstract class DriverStatusEvent extends Equatable {
  const DriverStatusEvent();

  @override
  List<Object?> get props => [];
}

class DriverStatusInitialized extends DriverStatusEvent {
  const DriverStatusInitialized();
}

class DriverWentOnline extends DriverStatusEvent {
  const DriverWentOnline();
}

class DriverWentOffline extends DriverStatusEvent {
  const DriverWentOffline();
}

class DriverLocationUpdated extends DriverStatusEvent {
  const DriverLocationUpdated({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.bearing,
  });

  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final double? bearing;

  @override
  List<Object?> get props => [latitude, longitude, accuracy, speed, bearing];
}

class DriverWorkAreaChanged extends DriverStatusEvent {
  const DriverWorkAreaChanged(this.workArea);

  final WorkArea workArea;

  @override
  List<Object> get props => [workArea];
}

class DriverStatusErrorOccurred extends DriverStatusEvent {
  const DriverStatusErrorOccurred(this.errorMessage);

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

class DriverLocationTrackingStarted extends DriverStatusEvent {
  const DriverLocationTrackingStarted();
}

class DriverLocationTrackingStopped extends DriverStatusEvent {
  const DriverLocationTrackingStopped();
}

// ============ STATES ============

enum DriverStatusBlocStatus {
  initial,
  initializing,
  idle,
  goingOnline,
  goingOffline,
  error,
}

class DriverStatusState extends Equatable {
  const DriverStatusState({
    required this.status,
    this.driverStatus = DriverStatus.offline,
    this.workArea,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationUpdate,
    this.lastActiveAt,
    this.earningsToday = 0.0,
    this.tripsToday = 0,
    this.isLocationTracking = false,
    this.errorMessage,
  });

  final DriverStatusBlocStatus status;
  final DriverStatus driverStatus;
  final WorkArea? workArea;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastLocationUpdate;
  final DateTime? lastActiveAt;
  final double earningsToday;
  final int tripsToday;
  final bool isLocationTracking;
  final String? errorMessage;

  factory DriverStatusState.initial() => const DriverStatusState(
        status: DriverStatusBlocStatus.initial,
      );

  bool get isOnline => driverStatus == DriverStatus.online;
  bool get isOffline => driverStatus == DriverStatus.offline;
  bool get isBusy => driverStatus == DriverStatus.busy;
  bool get hasError => status == DriverStatusBlocStatus.error;
  bool get isInitializing => status == DriverStatusBlocStatus.initializing;

  /// Check if driver is in work area
  bool get isInWorkArea {
    if (workArea == null || currentLatitude == null || currentLongitude == null) {
      return false;
    }

    final distance = Geolocator.distanceBetween(
      workArea!.latitude,
      workArea!.longitude,
      currentLatitude!,
      currentLongitude!,
    );

    return distance <= workArea!.radius * 1000; // Convert km to meters
  }

  /// Get distance from work area center
  double? get distanceFromWorkArea {
    if (workArea == null || currentLatitude == null || currentLongitude == null) {
      return null;
    }

    return Geolocator.distanceBetween(
      workArea!.latitude,
      workArea!.longitude,
      currentLatitude!,
      currentLongitude!,
    ) / 1000; // Convert to kilometers
  }

  DriverStatusState copyWith({
    DriverStatusBlocStatus? status,
    DriverStatus? driverStatus,
    WorkArea? workArea,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastLocationUpdate,
    DateTime? lastActiveAt,
    double? earningsToday,
    int? tripsToday,
    bool? isLocationTracking,
    String? errorMessage,
  }) {
    return DriverStatusState(
      status: status ?? this.status,
      driverStatus: driverStatus ?? this.driverStatus,
      workArea: workArea ?? this.workArea,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      earningsToday: earningsToday ?? this.earningsToday,
      tripsToday: tripsToday ?? this.tripsToday,
      isLocationTracking: isLocationTracking ?? this.isLocationTracking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        driverStatus,
        workArea,
        currentLatitude,
        currentLongitude,
        lastLocationUpdate,
        lastActiveAt,
        earningsToday,
        tripsToday,
        isLocationTracking,
        errorMessage,
      ];
}
