part of 'language_selection_bloc.dart';

abstract class LanguageSelectionEvent extends Equatable {
  const LanguageSelectionEvent();

  @override
  List<Object?> get props => [];
}

class LanguageSelectionInitialized extends LanguageSelectionEvent {
  const LanguageSelectionInitialized();
}

class LanguageSelected extends LanguageSelectionEvent {
  const LanguageSelected(this.languageCode);

  final String languageCode;

  @override
  List<Object> get props => [languageCode];
}

class LanguageSelectionSubmitted extends LanguageSelectionEvent {
  const LanguageSelectionSubmitted();
}