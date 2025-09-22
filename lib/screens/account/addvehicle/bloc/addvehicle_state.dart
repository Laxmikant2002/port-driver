part of 'addvehicle_bloc.dart';

// Vehicle model
class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.name,
    required this.number,
    required this.year,
    required this.type,
    required this.photoPath,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String number;
  final String year;
  final String type;
  final String photoPath;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as String,
      year: json['year'] as String,
      type: json['type'] as String,
      photoPath: json['photoPath'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'year': year,
      'type': type,
      'photoPath': photoPath,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Vehicle copyWith({
    String? id,
    String? name,
    String? number,
    String? year,
    String? type,
    String? photoPath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      year: year ?? this.year,
      type: type ?? this.type,
      photoPath: photoPath ?? this.photoPath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, number, year, type, photoPath, isActive, createdAt, updatedAt];
}

// Validation error enums
enum VehicleNameValidationError { empty }

enum VehicleNumberValidationError { empty, invalid }

enum VehicleYearValidationError { empty, invalid }

enum VehicleTypeValidationError { empty }

// Formz input classes
class VehicleName extends FormzInput<String, VehicleNameValidationError> {
  const VehicleName.pure() : super.pure('');
  const VehicleName.dirty([super.value = '']) : super.dirty();

  @override
  VehicleNameValidationError? validator(String value) {
    if (value.isEmpty) return VehicleNameValidationError.empty;
    return null;
  }
}

class VehicleNumber extends FormzInput<String, VehicleNumberValidationError> {
  const VehicleNumber.pure() : super.pure('');
  const VehicleNumber.dirty([super.value = '']) : super.dirty();

  @override
  VehicleNumberValidationError? validator(String value) {
    if (value.isEmpty) return VehicleNumberValidationError.empty;
    if (value.length < 8) return VehicleNumberValidationError.invalid;
    return null;
  }
}

class VehicleYear extends FormzInput<String, VehicleYearValidationError> {
  const VehicleYear.pure() : super.pure('');
  const VehicleYear.dirty([super.value = '']) : super.dirty();

  @override
  VehicleYearValidationError? validator(String value) {
    if (value.isEmpty) return VehicleYearValidationError.empty;
    final year = int.tryParse(value);
    if (year == null || year < 1990 || year > DateTime.now().year + 1) {
      return VehicleYearValidationError.invalid;
    }
    return null;
  }
}

class VehicleTypeInput extends FormzInput<String, VehicleTypeValidationError> {
  const VehicleTypeInput.pure() : super.pure('');
  const VehicleTypeInput.dirty([super.value = '']) : super.dirty();

  @override
  VehicleTypeValidationError? validator(String value) {
    if (value.isEmpty) return VehicleTypeValidationError.empty;
    return null;
  }
}

// AddVehicle state class
final class AddVehicleState extends Equatable {
  const AddVehicleState({
    this.vehicles = const [],
    this.selectedVehicle,
    this.vehicleName = const VehicleName.pure(),
    this.vehicleNumber = const VehicleNumber.pure(),
    this.vehicleYear = const VehicleYear.pure(),
    this.vehicleType = const VehicleTypeInput.pure(),
    this.photoPath,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final VehicleName vehicleName;
  final VehicleNumber vehicleNumber;
  final VehicleYear vehicleYear;
  final VehicleTypeInput vehicleType;
  final String? photoPath;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([vehicleName, vehicleNumber, vehicleYear, vehicleType]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns the current error message if any
  String? get error => errorMessage;

  /// Returns true if documents are currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  AddVehicleState copyWith({
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    VehicleName? vehicleName,
    VehicleNumber? vehicleNumber,
    VehicleYear? vehicleYear,
    VehicleTypeInput? vehicleType,
    String? photoPath,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddVehicleState(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleType: vehicleType ?? this.vehicleType,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        vehicles,
        selectedVehicle,
        vehicleName,
        vehicleNumber,
        vehicleYear,
        vehicleType,
        photoPath,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'AddVehicleState('
        'vehicles: ${vehicles.length}, '
        'selectedVehicle: $selectedVehicle, '
        'vehicleName: $vehicleName, '
        'vehicleNumber: $vehicleNumber, '
        'vehicleYear: $vehicleYear, '
        'vehicleType: $vehicleType, '
        'photoPath: $photoPath, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}
