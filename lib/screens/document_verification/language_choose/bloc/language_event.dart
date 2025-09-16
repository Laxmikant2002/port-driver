import 'package:equatable/equatable.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();
  @override
  List<Object?> get props => [];
}

class LanguageDropdownChanged extends LanguageEvent {
  final String dropdownValue;
  const LanguageDropdownChanged(this.dropdownValue);
  @override
  List<Object?> get props => [dropdownValue];
}

class LanguageRadioChanged extends LanguageEvent {
  final String radioValue;
  const LanguageRadioChanged(this.radioValue);
  @override
  List<Object?> get props => [radioValue];
}

class LanguageSubmitted extends LanguageEvent {
  const LanguageSubmitted();
}
