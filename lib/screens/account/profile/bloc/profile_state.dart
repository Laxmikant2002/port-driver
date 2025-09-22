part of 'profile_bloc.dart';

// Driver status enum
enum DriverStatus {
  offline,
  online,
  busy,
  suspended,
}

// Validation error enums
enum FullNameValidationError { empty }

enum GenderValidationError { empty }

enum PreferredLocationValidationError { empty }

// Formz input classes
class FullNameInput extends FormzInput<String, FullNameValidationError> {
  const FullNameInput.pure() : super.pure('');
  const FullNameInput.dirty([super.value = '']) : super.dirty();

  @override
  FullNameValidationError? validator(String value) {
    if (value.isEmpty) return FullNameValidationError.empty;
    return null;
  }
}

class GenderInput extends FormzInput<String, GenderValidationError> {
  const GenderInput.pure() : super.pure('');
  const GenderInput.dirty([super.value = '']) : super.dirty();

  @override
  GenderValidationError? validator(String value) {
    // Gender is optional, so no validation needed
    return null;
  }
}

class PreferredLocationInput extends FormzInput<String, PreferredLocationValidationError> {
  const PreferredLocationInput.pure() : super.pure('');
  const PreferredLocationInput.dirty([super.value = '']) : super.dirty();

  @override
  PreferredLocationValidationError? validator(String value) {
    if (value.isEmpty) return PreferredLocationValidationError.empty;
    return null;
  }
}

// Profile state class
class ProfileState extends Equatable {
  const ProfileState({
    // Driver Info (input from driver during registration / editable later)
    this.fullName = const FullNameInput.pure(),
    this.profilePicture,
    this.dateOfBirth,
    this.gender = const GenderInput.pure(),
    this.phoneNumber = '',
    
    // Vehicle Info (assigned by admin or selected from allowed list)
    this.vehicleId,
    this.vehicleType,
    this.plateNumber,
    this.assignedByAdmin = false,
    
    // Work Info
    this.preferredLocation = const PreferredLocationInput.pure(),
    this.serviceArea,
    this.languagesSpoken = const [],
    this.driverStatus = DriverStatus.offline,
    
    // System Managed (not input, backend controls)
    this.driverId,
    this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.rating = 0.0,
    this.completedTrips = 0,
    this.earningsSummary = 0.0,
    
    // Form state
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  // Driver Info (input from driver during registration / editable later)
  final FullNameInput fullName;
  final String? profilePicture;
  final DateTime? dateOfBirth;
  final GenderInput gender;
  final String phoneNumber; // from auth → cannot edit by driver
  
  // Vehicle Info (assigned by admin or selected from allowed list)
  final String? vehicleId;
  final String? vehicleType;
  final String? plateNumber;
  final bool assignedByAdmin;
  
  // Work Info
  final PreferredLocationInput preferredLocation;
  final String? serviceArea;
  final List<String> languagesSpoken;
  final DriverStatus driverStatus;
  
  // System Managed (not input, backend controls)
  final String? driverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final double rating;
  final int completedTrips;
  final double earningsSummary;
  
  // Form state
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid {
    return Formz.validate([fullName, preferredLocation]);
  }

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

  ProfileState copyWith({
    // Driver Info
    FullNameInput? fullName,
    String? profilePicture,
    DateTime? dateOfBirth,
    GenderInput? gender,
    String? phoneNumber,
    
    // Vehicle Info
    String? vehicleId,
    String? vehicleType,
    String? plateNumber,
    bool? assignedByAdmin,
    
    // Work Info
    PreferredLocationInput? preferredLocation,
    String? serviceArea,
    List<String>? languagesSpoken,
    DriverStatus? driverStatus,
    
    // System Managed
    String? driverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    double? rating,
    int? completedTrips,
    double? earningsSummary,
    
    // Form state
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      assignedByAdmin: assignedByAdmin ?? this.assignedByAdmin,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      serviceArea: serviceArea ?? this.serviceArea,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      driverStatus: driverStatus ?? this.driverStatus,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      completedTrips: completedTrips ?? this.completedTrips,
      earningsSummary: earningsSummary ?? this.earningsSummary,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        profilePicture,
        dateOfBirth,
        gender,
        phoneNumber,
        vehicleId,
        vehicleType,
        plateNumber,
        assignedByAdmin,
        preferredLocation,
        serviceArea,
        languagesSpoken,
        driverStatus,
        driverId,
        createdAt,
        updatedAt,
        isVerified,
        rating,
        completedTrips,
        earningsSummary,
        status,
        errorMessage,
      ];
}
