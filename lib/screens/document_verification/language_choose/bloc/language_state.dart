import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

class LanguageDropdownInput extends FormzInput<String, String> {
  const LanguageDropdownInput.pure() : super.pure('English (English)');
  const LanguageDropdownInput.dirty([super.value = 'English (English)']) : super.dirty();
  @override
  String? validator(String value) => null;
}

class LanguageRadioInput extends FormzInput<String, String> {
  const LanguageRadioInput.pure() : super.pure('English');
  const LanguageRadioInput.dirty([super.value = 'English']) : super.dirty();
  @override
  String? validator(String value) => null;
}

enum LanguageStatus { initial, loading, success, failure }

class LanguageState extends Equatable {
  const LanguageState({
    this.status = LanguageStatus.initial,
    this.dropdown = const LanguageDropdownInput.pure(),
    this.radio = const LanguageRadioInput.pure(),
    this.isValid = true,
    this.errorMessage,
  });

  final LanguageStatus status;
  final LanguageDropdownInput dropdown;
  final LanguageRadioInput radio;
  final bool isValid;
  final String? errorMessage;

  LanguageState copyWith({
    LanguageStatus? status,
    LanguageDropdownInput? dropdown,
    LanguageRadioInput? radio,
    bool? isValid,
    String? errorMessage,
  }) {
    return LanguageState(
      status: status ?? this.status,
      dropdown: dropdown ?? this.dropdown,
      radio: radio ?? this.radio,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, dropdown, radio, isValid, errorMessage];
}
