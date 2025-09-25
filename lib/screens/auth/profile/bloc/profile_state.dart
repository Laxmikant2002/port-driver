part of 'profile_bloc.dart';

/// Form input for name validation using Formz
class NameInput extends FormzInput<String, String> {
  const NameInput.pure() : super.pure('');
  const NameInput.dirty([String value = '']) : super.dirty(value);

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'empty';
    if (value.length < 2) return 'too_short';
    if (value.length > 50) return 'too_long';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'invalid';
    
    return null;
  }

  /// Returns a user-friendly error message
  @override
  String? get displayError {
    if (error == null) return null;
    
    switch (error) {
      case 'empty':
        return 'Full name is required';
      case 'too_short':
        return 'Name must be at least 2 characters';
      case 'too_long':
        return 'Name must be less than 50 characters';
      case 'invalid':
        return 'Please enter a valid name (letters and spaces only)';
      default:
        return 'Invalid name';
    }
  }

  /// Returns true if the name is valid
  @override
  bool get isValid => error == null && value.isNotEmpty;
}

/// Profile state containing form data and submission status
final class ProfileState extends Equatable {
  const ProfileState({
    this.nameInput = const NameInput.pure(),
    this.dateOfBirth,
    this.gender,
    this.profilePhoto,
    this.status = FormzSubmissionStatus.initial,
    this.routeDecision,
    this.updatedProfile,
    this.errorMessage,
  });

  final NameInput nameInput;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? profilePhoto;
  final FormzSubmissionStatus status;
  final RouteDecision? routeDecision;
  final DriverProfile? updatedProfile;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([nameInput]) && 
                     dateOfBirth != null && 
                     gender != null && 
                     gender!.isNotEmpty;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns the age based on date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Returns true if the user is of legal driving age (18+)
  bool get isLegalDrivingAge => (age ?? 0) >= 18;

  ProfileState copyWith({
    NameInput? nameInput,
    DateTime? dateOfBirth,
    String? gender,
    String? profilePhoto,
    FormzSubmissionStatus? status,
    RouteDecision? routeDecision,
    DriverProfile? updatedProfile,
    String? errorMessage,
  }) {
    return ProfileState(
      nameInput: nameInput ?? this.nameInput,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      status: status ?? this.status,
      routeDecision: routeDecision ?? this.routeDecision,
      updatedProfile: updatedProfile ?? this.updatedProfile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        nameInput,
        dateOfBirth,
        gender,
        profilePhoto,
        status,
        routeDecision,
        updatedProfile,
        errorMessage,
      ];

  @override
  String toString() {
    return 'ProfileState('
        'nameInput: $nameInput, '
        'dateOfBirth: $dateOfBirth, '
        'gender: $gender, '
        'profilePhoto: $profilePhoto, '
        'status: $status, '
        'routeDecision: $routeDecision, '
        'updatedProfile: $updatedProfile, '
        'errorMessage: $errorMessage'
        ')';
  }
}