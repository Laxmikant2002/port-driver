import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:trip_repo/trip_repo.dart';
import 'package:driver/services/realtime/realtime_service.dart';

part 'trip_event.dart';
part 'trip_state.dart';

/// Modern Trip BLoC for managing complete trip lifecycle
class TripBloc extends Bloc<TripEvent, TripState> {
  TripBloc({
    required this.tripRepo,
    required this.realtimeService,
  }) : super(const TripState.initial()) {
    on<TripInitialized>(_onInitialized);
    on<TripRequestReceived>(_onTripRequestReceived);
    on<TripAccepted>(_onTripAccepted);
    on<TripRejected>(_onTripRejected);
    on<TripStarted>(_onTripStarted);
    on<TripArrived>(_onTripArrived);
    on<TripCompleted>(_onTripCompleted);
    on<TripCancelled>(_onTripCancelled);
    on<TripLocationUpdated>(_onTripLocationUpdated);
    on<TripStatusUpdated>(_onTripStatusUpdated);
    on<TripRequestExpired>(_onTripRequestExpired);
    on<TripErrorOccurred>(_onTripErrorOccurred);
    
    _setupRealtimeListeners();
  }

  final TripRepo tripRepo;
  final RealtimeService realtimeService;
  StreamSubscription<TripRequest>? _tripRequestSubscription;
  StreamSubscription<TripUpdate>? _tripUpdateSubscription;

  /// Initialize trip management
  void _onInitialized(TripInitialized event, Emitter<TripState> emit) async {
    emit(state.copyWith(status: TripBlocStatus.initializing));
    
    try {
      // Check for active trip
      final activeTripResponse = await tripRepo.getActiveTrip();
      if (activeTripResponse.success && activeTripResponse.trip != null) {
        emit(state.copyWith(
          status: TripBlocStatus.onTrip,
          currentTrip: activeTripResponse.trip,
        ));
      } else {
        emit(state.copyWith(status: TripBlocStatus.idle));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: 'Failed to initialize trip management: $e',
      ));
    }
  }

  /// Handle incoming trip request
  void _onTripRequestReceived(TripRequestReceived event, Emitter<TripState> emit) {
    emit(state.copyWith(
      status: TripBlocStatus.incomingRequest,
      incomingTrip: event.tripRequest,
      requestExpiresAt: event.tripRequest.expiresAt,
    ));

    // Start countdown timer
    _startRequestTimer(event.tripRequest.expiresAt);
  }

  /// Accept trip request
  void _onTripAccepted(TripAccepted event, Emitter<TripState> emit) async {
    if (state.incomingTrip == null) {
      emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: 'No incoming trip to accept',
      ));
      return;
    }

    emit(state.copyWith(status: TripBlocStatus.accepting));

    try {
      final response = await tripRepo.acceptTrip(state.incomingTrip!.tripId);
      
      if (response.success) {
        // Emit WebSocket acceptance
        realtimeService.acceptTrip(state.incomingTrip!.tripId);
        
        emit(state.copyWith(
          status: TripBlocStatus.accepted,
          currentTrip: response.trip,
          incomingTrip: null,
          requestExpiresAt: null,
        ));
      } else {
        emit(state.copyWith(
          status: TripBlocStatus.error,
          errorMessage: response.message ?? 'Failed to accept trip',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: 'Network error while accepting trip: $e',
      ));
    }
  }

  /// Reject trip request
  void _onTripRejected(TripRejected event, Emitter<TripState> emit) async {
    if (state.incomingTrip == null) {
      emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: 'No incoming trip to reject',
      ));
      return;
    }

    try {
      final response = await tripRepo.rejectTrip(
        state.incomingTrip!.tripId,
        reason: event.reason,
      );
      
      // Emit WebSocket rejection
      realtimeService.rejectTrip(state.incomingTrip!.tripId, reason: event.reason);
      
      emit(state.copyWith(
        status: TripBlocStatus.idle,
        incomingTrip: null,
        requestExpiresAt: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: 'Failed to reject trip: $e',
      ));
    }
  }

  /// Start trip (pickup confirmed)
  void _onTripStarted(TripStarted event, Emitter<TripState> emit) async {
    if (state.currentTrip == null) return;

    emit(state.copyWith(status: TripBlocStatus.starting));

    try {
      final response = await tripRepo.updateTripStatus(
        state.currentTrip!.id,
        TripStatus.inProgress,
      );
      
      if (response.success) {
        realtimeService.updateTripStatus(
          state.currentTrip!.id,
          TripStatus.inProgress,
        );
        
        emit(state.copyWith(
          status: TripBlocStatus.onTrip,
          currentTrip: response.trip,
        ));
      } else {
        emit(state.copyWith(
          status: TripBlocStatus.error,
          errorMessage: response.message ?? 'Failed to start trip',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: 'Failed to start trip: $e',
      ));
    }
  }

  /// Arrive at pickup/drop location
  void _onTripArrived(TripArrived event, Emitter<TripState> emit) async {
    if (state.currentTrip == null) return;

    try {
      final response = await tripRepo.updateTripLocation(
        state.currentTrip!.id,
        event.latitude,
        event.longitude,
      );
      
      if (response.success) {
        emit(state.copyWith(currentTrip: response.trip));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: 'Failed to update location: $e',
      ));
    }
  }

  /// Complete trip
  void _onTripCompleted(TripCompleted event, Emitter<TripState> emit) async {
    if (state.currentTrip == null) return;

    emit(state.copyWith(status: TripBlocStatus.completing));

    try {
      final response = await tripRepo.completeTrip(state.currentTrip!.id);
      
      if (response.success) {
        realtimeService.updateTripStatus(
          state.currentTrip!.id,
          TripStatus.completed,
        );
        
        emit(state.copyWith(
          status: TripBlocStatus.completed,
          completedTrip: response.trip,
          currentTrip: null,
        ));
      } else {
        emit(state.copyWith(
          status: TripBlocStatus.error,
          errorMessage: response.message ?? 'Failed to complete trip',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: 'Failed to complete trip: $e',
      ));
    }
  }

  /// Cancel trip
  void _onTripCancelled(TripCancelled event, Emitter<TripState> emit) async {
    if (state.currentTrip == null) return;

    try {
      realtimeService.updateTripStatus(
        state.currentTrip!.id,
        TripStatus.cancelled,
        data: {'reason': event.reason},
      );
      
      emit(state.copyWith(
        status: TripBlocStatus.idle,
        currentTrip: null,
        incomingTrip: null,
        requestExpiresAt: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: 'Failed to cancel trip: $e',
      ));
    }
  }

  /// Update trip location
  void _onTripLocationUpdated(TripLocationUpdated event, Emitter<TripState> emit) async {
    if (state.currentTrip == null) return;

    try {
      realtimeService.updateLocation(
        latitude: event.latitude,
        longitude: event.longitude,
        accuracy: event.accuracy,
        speed: event.speed,
        bearing: event.bearing,
      );
      
      // Update current trip with new location
      final updatedTrip = state.currentTrip!.copyWith(
        currentLatitude: event.latitude,
        currentLongitude: event.longitude,
      );
      
      emit(state.copyWith(currentTrip: updatedTrip));
    } catch (e) {
      // Location updates are not critical, just log the error
      debugPrint('Failed to update trip location: $e');
    }
  }

  /// Handle trip status updates from server
  void _onTripStatusUpdated(TripStatusUpdated event, Emitter<TripState> emit) {
    if (state.currentTrip?.id != event.tripUpdate.tripId) return;

    final updatedTrip = state.currentTrip!.copyWith(
      status: event.tripUpdate.status,
    );

    emit(state.copyWith(currentTrip: updatedTrip));
  }

  /// Handle trip request expiration
  void _onTripRequestExpired(TripRequestExpired event, Emitter<TripState> emit) {
    if (state.status == TripBlocStatus.incomingRequest) {
      emit(state.copyWith(
        status: TripBlocStatus.idle,
        incomingTrip: null,
        requestExpiresAt: null,
      ));
    }
  }

  /// Handle trip errors
  void _onTripErrorOccurred(TripErrorOccurred event, Emitter<TripState> emit) {
    emit(state.copyWith(
      status: TripBlocStatus.error,
      errorMessage: event.errorMessage,
    ));
  }

  /// Setup real-time listeners
  void _setupRealtimeListeners() {
    _tripRequestSubscription = realtimeService.tripRequestStream.listen(
      (tripRequest) => add(TripRequestReceived(tripRequest)),
    );

    _tripUpdateSubscription = realtimeService.tripUpdateStream.listen(
      (tripUpdate) => add(TripStatusUpdated(tripUpdate)),
    );
  }

  /// Start request countdown timer
  void _startRequestTimer(DateTime expiresAt) {
    final now = DateTime.now();
    final duration = expiresAt.difference(now);
    
    if (duration.isNegative) {
      add(const TripRequestExpired());
      return;
    }

    Timer(duration, () {
      if (state.status == TripBlocStatus.incomingRequest) {
        add(const TripRequestExpired());
      }
    });
  }

  @override
  Future<void> close() {
    _tripRequestSubscription?.cancel();
    _tripUpdateSubscription?.cancel();
    return super.close();
  }
}

// ============ EVENTS ============

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class TripInitialized extends TripEvent {
  const TripInitialized();
}

class TripRequestReceived extends TripEvent {
  const TripRequestReceived(this.tripRequest);

  final TripRequest tripRequest;

  @override
  List<Object> get props => [tripRequest];
}

class TripAccepted extends TripEvent {
  const TripAccepted();
}

class TripRejected extends TripEvent {
  const TripRejected({this.reason});

  final String? reason;

  @override
  List<Object?> get props => [reason];
}

class TripStarted extends TripEvent {
  const TripStarted();
}

class TripArrived extends TripEvent {
  const TripArrived({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  List<Object> get props => [latitude, longitude];
}

class TripCompleted extends TripEvent {
  const TripCompleted();
}

class TripCancelled extends TripEvent {
  const TripCancelled({this.reason});

  final String? reason;

  @override
  List<Object?> get props => [reason];
}

class TripLocationUpdated extends TripEvent {
  const TripLocationUpdated({
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

class TripStatusUpdated extends TripEvent {
  const TripStatusUpdated(this.tripUpdate);

  final TripUpdate tripUpdate;

  @override
  List<Object> get props => [tripUpdate];
}

class TripRequestExpired extends TripEvent {
  const TripRequestExpired();
}

class TripErrorOccurred extends TripEvent {
  const TripErrorOccurred(this.errorMessage);

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

// ============ STATES ============

enum TripBlocStatus {
  initial,
  initializing,
  idle,
  incomingRequest,
  accepting,
  accepted,
  starting,
  onTrip,
  completing,
  completed,
  error,
}

class TripState extends Equatable {
  const TripState({
    required this.status,
    this.currentTrip,
    this.incomingTrip,
    this.completedTrip,
    this.requestExpiresAt,
    this.errorMessage,
  });

  final TripBlocStatus status;
  final Trip? currentTrip;
  final TripRequest? incomingTrip;
  final Trip? completedTrip;
  final DateTime? requestExpiresAt;
  final String? errorMessage;

  factory TripState.initial() => const TripState(status: TripBlocStatus.initial);

  bool get isIdle => status == TripBlocStatus.idle;
  bool get hasIncomingRequest => status == TripBlocStatus.incomingRequest;
  bool get isOnTrip => status == TripBlocStatus.onTrip;
  bool get isCompleted => status == TripBlocStatus.completed;
  bool get hasError => status == TripBlocStatus.error;
  
  /// Time remaining for incoming request (in seconds)
  int? get requestTimeRemaining {
    if (requestExpiresAt == null) return null;
    final now = DateTime.now();
    final remaining = requestExpiresAt!.difference(now);
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }

  TripState copyWith({
    TripBlocStatus? status,
    Trip? currentTrip,
    TripRequest? incomingTrip,
    Trip? completedTrip,
    DateTime? requestExpiresAt,
    String? errorMessage,
  }) {
    return TripState(
      status: status ?? this.status,
      currentTrip: currentTrip ?? this.currentTrip,
      incomingTrip: incomingTrip ?? this.incomingTrip,
      completedTrip: completedTrip ?? this.completedTrip,
      requestExpiresAt: requestExpiresAt ?? this.requestExpiresAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentTrip,
        incomingTrip,
        completedTrip,
        requestExpiresAt,
        errorMessage,
      ];
}
