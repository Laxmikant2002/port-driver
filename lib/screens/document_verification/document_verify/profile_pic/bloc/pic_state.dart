part of 'pic_bloc.dart';

enum PicImageValidationError { empty }

class PicImage extends FormzInput<String, PicImageValidationError> {
  const PicImage.pure() : super.pure('');
  const PicImage.dirty([super.value = '']) : super.dirty();

  @override
  PicImageValidationError? validator(String value) {
    if (value.isEmpty) return PicImageValidationError.empty;
    return null;
  }
}

enum PicStatus { initial, loading, success, failure }

class PicState extends Equatable {
  const PicState({
    this.status = PicStatus.initial,
    this.picImage = const PicImage.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final PicStatus status;
  final PicImage picImage;
  final bool isValid;
  final String? errorMessage;

  PicState copyWith({
    PicStatus? status,
    PicImage? picImage,
    bool? isValid,
    String? errorMessage,
  }) {
    return PicState(
      status: status ?? this.status,
      picImage: picImage ?? this.picImage,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        picImage,
        isValid,
        errorMessage,
      ];
}
