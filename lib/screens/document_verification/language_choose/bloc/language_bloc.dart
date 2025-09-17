import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState()) {
    on<LanguageChanged>(_onLanguageChanged);
    on<LanguageSubmitted>(_onSubmitted);
  }

  void _onLanguageChanged(LanguageChanged event, Emitter<LanguageState> emit) {
    final language = LanguageInput.dirty(event.language);
    emit(state.copyWith(
      language: language,
      isValid: Formz.validate([language]),
    ));
  }

  void _onSubmitted(LanguageSubmitted event, Emitter<LanguageState> emit) async {
    if (state.isValid) {
      emit(state.copyWith(status: LanguageStatus.loading));
      try {
        // TODO: Implement language selection to API
        await Future<void>.delayed(const Duration(seconds: 1)); // Simulate API call
        emit(state.copyWith(status: LanguageStatus.success));
      } catch (error) {
        emit(
          state.copyWith(
            status: LanguageStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }
}
