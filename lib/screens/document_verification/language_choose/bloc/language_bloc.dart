import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState()) {
    on<LanguageDropdownChanged>(_onDropdownChanged);
    on<LanguageRadioChanged>(_onRadioChanged);
    on<LanguageSubmitted>(_onSubmitted);
  }

  void _onDropdownChanged(LanguageDropdownChanged event, Emitter<LanguageState> emit) {
    final dropdown = LanguageDropdownInput.dirty(event.dropdownValue);
    emit(state.copyWith(
      dropdown: dropdown,
      isValid: Formz.validate([
        dropdown,
        state.radio,
      ]),
    ));
  }

  void _onRadioChanged(LanguageRadioChanged event, Emitter<LanguageState> emit) {
    final radio = LanguageRadioInput.dirty(event.radioValue);
    emit(state.copyWith(
      radio: radio,
      isValid: Formz.validate([
        state.dropdown,
        radio,
      ]),
    ));
  }

  void _onSubmitted(LanguageSubmitted event, Emitter<LanguageState> emit) async {
    if (state.isValid) {
      emit(state.copyWith(status: LanguageStatus.loading));
      await Future<void>.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: LanguageStatus.success));
    }
  }
}
