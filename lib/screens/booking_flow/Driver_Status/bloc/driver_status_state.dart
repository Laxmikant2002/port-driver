part of 'driver_status_bloc.dart';

enum DriverStatusValidationError { empty }

class DriverStatusField extends FormzInput<String, DriverStatusValidationError> {
  const DriverStatusField.pure() : super.pure('');
  const DriverStatusField.dirty([super.value = '']) : super.dirty();

  @override
  DriverStatusValidationError? validator(String value) {
    if (value.isEmpty) return DriverStatusValidationError.empty;
    return null;
  }
}

enum WorkAreaValidationError { empty }

class WorkAreaField extends FormzInput<String, WorkAreaValidationError> {
  const WorkAreaField.pure() : super.pure('');
  const WorkAreaField.dirty([super.value = '']) : super.dirty();

  @override
  WorkAreaValidationError? validator(String value) {
    if (value.isEmpty) return WorkAreaValidationError.empty;
    return null;
  }
}

/// Driver status state containing form data and submission status
final class DriverStatusState extends Equatable {
  const DriverStatusState({
    this.status = FormzSubmissionStatus.initial,
    this.driverStatus = const DriverStatusField.pure(),
    this.workArea = const WorkAreaField.pure(),
    this.earningsToday = 0.0,
    this.tripsToday = 0,
    this.lastActiveAt,
    this.selectedWorkArea,
    this.errorMessage,
    this.mapController,
    this.currentLocation,
    this.zoom = 15.0,
    this.polylines = const <String, Polyline>{},
    this.currentStatus = 'Initializing',
    this.isLocationLoaded = false,
  });

  final FormzSubmissionStatus status;
  final DriverStatusField driverStatus;
  final WorkAreaField workArea;
  final double earningsToday;
  final int tripsToday;
  final DateTime? lastActiveAt;
  final WorkArea? selectedWorkArea;
  final String? errorMessage;
  final GoogleMapController? mapController;
  final LatLng? currentLocation;
  final double zoom;
  final Map<String, Polyline> polylines;
  final String currentStatus;
  final bool isLocationLoaded;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([driverStatus]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns true if the driver is currently online
  bool get isOnline => driverStatus.value == 'online';

  /// Returns true if the driver is currently busy
  bool get isBusy => driverStatus.value == 'busy';

  /// Returns true if the driver is currently offline
  bool get isOffline => driverStatus.value == 'offline';

  /// Returns true if the driver is suspended
  bool get isSuspended => driverStatus.value == 'suspended';

  /// Returns true if the driver has a work area set
  bool get hasWorkArea => workArea.value.isNotEmpty;

  /// Returns the driver status display text
  String get statusDisplayText {
    switch (driverStatus.value) {
      case 'online':
        return 'Online';
      case 'busy':
        return 'Busy';
      case 'suspended':
        return 'Suspended';
      default:
        return 'Offline';
    }
  }

  /// Returns the earnings formatted as currency
  String get earningsText => '₹${earningsToday.toStringAsFixed(2)}';

  /// Returns the trips count text
  String get tripsText => '$tripsToday trip${tripsToday != 1 ? 's' : ''}';

  /// Returns the last active time formatted
  String get lastActiveText {
    if (lastActiveAt == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastActiveAt!);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  DriverStatusState copyWith({
    FormzSubmissionStatus? status,
    DriverStatusField? driverStatus,
    WorkAreaField? workArea,
    double? earningsToday,
    int? tripsToday,
    DateTime? lastActiveAt,
    WorkArea? selectedWorkArea,
    String? errorMessage,
    GoogleMapController? mapController,
    LatLng? currentLocation,
    double? zoom,
    Map<String, Polyline>? polylines,
    String? currentStatus,
    bool? isLocationLoaded,
  }) {
    return DriverStatusState(
      status: status ?? this.status,
      driverStatus: driverStatus ?? this.driverStatus,
      workArea: workArea ?? this.workArea,
      earningsToday: earningsToday ?? this.earningsToday,
      tripsToday: tripsToday ?? this.tripsToday,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      selectedWorkArea: selectedWorkArea ?? this.selectedWorkArea,
      errorMessage: errorMessage,
      mapController: mapController ?? this.mapController,
      currentLocation: currentLocation ?? this.currentLocation,
      zoom: zoom ?? this.zoom,
      polylines: polylines ?? this.polylines,
      currentStatus: currentStatus ?? this.currentStatus,
      isLocationLoaded: isLocationLoaded ?? this.isLocationLoaded,
    );
  }

  @override
  List<Object?> get props => [
        status,
        driverStatus,
        workArea,
        earningsToday,
        tripsToday,
        lastActiveAt,
        selectedWorkArea,
        errorMessage,
        mapController,
        currentLocation,
        zoom,
        polylines,
        currentStatus,
        isLocationLoaded,
      ];

  @override
  String toString() {
    return 'DriverStatusState('
        'status: $status, '
        'driverStatus: $driverStatus, '
        'workArea: $workArea, '
        'earningsToday: $earningsToday, '
        'tripsToday: $tripsToday, '
        'errorMessage: $errorMessage'
        ')';
  }
}