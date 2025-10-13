import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/app/bloc/cubit/locale.dart';

part 'language_selection_event.dart';
part 'language_selection_state.dart';

class LanguageSelectionBloc extends Bloc<LanguageSelectionEvent, LanguageSelectionState> {
  LanguageSelectionBloc({
    required this.localeCubit,
  }) : super(const LanguageSelectionState()) {
    on<LanguageSelectionInitialized>(_onInitialized);
    on<LanguageSelected>(_onLanguageSelected);
    on<LanguageSelectionSubmitted>(_onSubmitted);
  }

  final LocaleCubit localeCubit;

  void _onInitialized(
    LanguageSelectionInitialized event,
    Emitter<LanguageSelectionState> emit,
  ) {
    final currentLocale = localeCubit.state;
    emit(state.copyWith(
      selectedLanguage: currentLocale.languageCode,
    ));
  }

  void _onLanguageSelected(
    LanguageSelected event,
    Emitter<LanguageSelectionState> emit,
  ) {
    emit(state.copyWith(
      selectedLanguage: event.languageCode,
    ));
  }

  void _onSubmitted(
    LanguageSelectionSubmitted event,
    Emitter<LanguageSelectionState> emit,
  ) {
    if (state.selectedLanguage != null) {
      localeCubit.selectLocale(state.selectedLanguage!);
      emit(state.copyWith(
        status: LanguageSelectionStatus.success,
      ));
    }
  }
}