import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'language_event.dart';
part 'language_state.dart';

/// BLoC responsible for managing language selection state and business logic
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState()) {
    on<LanguageChanged>(_onLanguageChanged);
    on<LanguageSubmitted>(_onSubmitted);
  }

  /// Handles language selection changes
  void _onLanguageChanged(LanguageChanged event, Emitter<LanguageState> emit) {
    final language = LanguageInput.dirty(event.language);
    emit(state.copyWith(
      language: language,
      status: FormzSubmissionStatus.initial,
    ));
  }

  /// Handles language selection submission
  Future<void> _onSubmitted(LanguageSubmitted event, Emitter<LanguageState> emit) async {
    // Validate language before submission
    final language = LanguageInput.dirty(state.language.value);
    
    emit(state.copyWith(
      language: language,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: language.displayError?.toString() ?? 'Please select a language',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // TODO: Implement language selection to API
      await Future<void>.delayed(const Duration(seconds: 1)); // Simulate API call
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to set language. Please try again.',
      ));
    }
  }
}
