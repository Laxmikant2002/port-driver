part of 'language_selection_bloc.dart';

/// Base class for all language selection events
sealed class LanguageSelectionEvent extends Equatable {
  const LanguageSelectionEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when a language is toggled
final class LanguageToggled extends LanguageSelectionEvent {
  const LanguageToggled(this.languageCode);

  final String languageCode;

  @override
  List<Object> get props => [languageCode];

  @override
  String toString() => 'LanguageToggled(languageCode: $languageCode)';
}

/// Event triggered when language selection is submitted
final class LanguageSelectionSubmitted extends LanguageSelectionEvent {
  const LanguageSelectionSubmitted();

  @override
  String toString() => 'LanguageSelectionSubmitted()';
}
