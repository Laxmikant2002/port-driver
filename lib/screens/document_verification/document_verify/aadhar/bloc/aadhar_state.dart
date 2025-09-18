part of 'aadhar_bloc.dart';

enum AadharNumberValidationError { empty, invalid }

class AadharNumber extends FormzInput<String, AadharNumberValidationError> {
  const AadharNumber.pure() : super.pure('');
  const AadharNumber.dirty([super.value = '']) : super.dirty();

  @override
  AadharNumberValidationError? validator(String value) {
    if (value.isEmpty) return AadharNumberValidationError.empty;
    if (value.length != 12 || !RegExp(r'^\d{12}$').hasMatch(value)) {
      return AadharNumberValidationError.invalid;
    }
    return null;
  }
}

enum AadharImageValidationError { empty }

class AadharImage extends FormzInput<String, AadharImageValidationError> {
  const AadharImage.pure() : super.pure('');
  const AadharImage.dirty([super.value = '']) : super.dirty();

  @override
  AadharImageValidationError? validator(String value) {
    if (value.isEmpty) return AadharImageValidationError.empty;
    return null;
  }
}

enum AadharStatus { initial, loading, success, failure }

class AadharState extends Equatable {
  const AadharState({
    this.status = AadharStatus.initial,
    this.aadharNumber = const AadharNumber.pure(),
    this.aadharImage = const AadharImage.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final AadharStatus status;
  final AadharNumber aadharNumber;
  final AadharImage aadharImage;
  final bool isValid;
  final String? errorMessage;

  AadharState copyWith({
    AadharStatus? status,
    AadharNumber? aadharNumber,
    AadharImage? aadharImage,
    bool? isValid,
    String? errorMessage,
  }) {
    return AadharState(
      status: status ?? this.status,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      aadharImage: aadharImage ?? this.aadharImage,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        aadharNumber,
        aadharImage,
        isValid,
        errorMessage,
      ];
}
