part of 'rc_bloc.dart';

enum RcNumberValidationError { empty, invalid }

class RcNumber extends FormzInput<String, RcNumberValidationError> {
  const RcNumber.pure() : super.pure('');
  const RcNumber.dirty([super.value = '']) : super.dirty();

  @override
  RcNumberValidationError? validator(String value) {
    if (value.isEmpty) return RcNumberValidationError.empty;
    if (value.length < 6) return RcNumberValidationError.invalid;
    return null;
  }
}

enum RcImageValidationError { empty }

class RcImage extends FormzInput<String, RcImageValidationError> {
  const RcImage.pure() : super.pure('');
  const RcImage.dirty([super.value = '']) : super.dirty();

  @override
  RcImageValidationError? validator(String value) {
    if (value.isEmpty) return RcImageValidationError.empty;
    return null;
  }
}

enum VehicleNumberValidationError { empty, invalid }

class VehicleNumber extends FormzInput<String, VehicleNumberValidationError> {
  const VehicleNumber.pure() : super.pure('');
  const VehicleNumber.dirty([super.value = '']) : super.dirty();

  @override
  VehicleNumberValidationError? validator(String value) {
    if (value.isEmpty) return VehicleNumberValidationError.empty;
    // Indian vehicle number format validation
    final vehicleRegExp = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}$');
    if (!vehicleRegExp.hasMatch(value.toUpperCase())) {
      return VehicleNumberValidationError.invalid;
    }
    return null;
  }
}

enum RcStatus { initial, loading, success, failure }

class RcState extends Equatable {
  const RcState({
    this.status = RcStatus.initial,
    this.rcNumber = const RcNumber.pure(),
    this.rcImage = const RcImage.pure(),
    this.vehicleNumber = const VehicleNumber.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final RcStatus status;
  final RcNumber rcNumber;
  final RcImage rcImage;
  final VehicleNumber vehicleNumber;
  final bool isValid;
  final String? errorMessage;

  RcState copyWith({
    RcStatus? status,
    RcNumber? rcNumber,
    RcImage? rcImage,
    VehicleNumber? vehicleNumber,
    bool? isValid,
    String? errorMessage,
  }) {
    return RcState(
      status: status ?? this.status,
      rcNumber: rcNumber ?? this.rcNumber,
      rcImage: rcImage ?? this.rcImage,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        rcNumber,
        rcImage,
        vehicleNumber,
        isValid,
        errorMessage,
      ];
}
