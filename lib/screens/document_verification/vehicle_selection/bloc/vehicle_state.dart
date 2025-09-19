part of 'vehicle_bloc.dart';

enum VehicleSelectionValidationError { empty }

class VehicleSelectionInput extends FormzInput<Vehicle?, VehicleSelectionValidationError> {
  const VehicleSelectionInput.pure() : super.pure(null);
  const VehicleSelectionInput.dirty([super.value]) : super.dirty();
  
  @override
  VehicleSelectionValidationError? validator(Vehicle? value) {
    if (value == null) return VehicleSelectionValidationError.empty;
    return null;
  }

  @override
  VehicleSelectionValidationError? get displayError {
    return error;
  }
}

/// Vehicle selection state containing form data and submission status
final class VehicleState extends Equatable {
  const VehicleState({
    this.status = FormzSubmissionStatus.initial,
    this.loadingStatus = VehicleLoadingStatus.initial,
    this.vehicles = const [],
    this.selectedVehicle = const VehicleSelectionInput.pure(),
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final VehicleLoadingStatus loadingStatus;
  final List<Vehicle> vehicles;
  final VehicleSelectionInput selectedVehicle;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([selectedVehicle]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns true if vehicles are being loaded
  bool get isLoading => loadingStatus == VehicleLoadingStatus.loading;

  /// Returns true if vehicles have been loaded
  bool get isLoaded => loadingStatus == VehicleLoadingStatus.loaded;

  /// Returns true if vehicle loading failed
  bool get isLoadingFailure => loadingStatus == VehicleLoadingStatus.failure;

  VehicleState copyWith({
    FormzSubmissionStatus? status,
    VehicleLoadingStatus? loadingStatus,
    List<Vehicle>? vehicles,
    VehicleSelectionInput? selectedVehicle,
    String? errorMessage,
  }) {
    return VehicleState(
      status: status ?? this.status,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, loadingStatus, vehicles, selectedVehicle, errorMessage];

  @override
  String toString() {
    return 'VehicleState('
        'status: $status, '
        'loadingStatus: $loadingStatus, '
        'vehicles: ${vehicles.length}, '
        'selectedVehicle: $selectedVehicle, '
        'errorMessage: $errorMessage'
        ')';
  }
}

/// Enum for vehicle loading status (separate from form submission)
enum VehicleLoadingStatus { initial, loading, loaded, failure }
