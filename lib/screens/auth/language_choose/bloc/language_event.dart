part of 'language_bloc.dart';

/// Base class for all language events
sealed class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when language selection changes
final class LanguageChanged extends LanguageEvent {
  const LanguageChanged(this.language);

  final String language;

  @override
  List<Object> get props => [language];

  @override
  String toString() => 'LanguageChanged(language: $language)';
}

/// Event triggered when language selection is submitted
final class LanguageSubmitted extends LanguageEvent {
  const LanguageSubmitted();

  @override
  String toString() => 'LanguageSubmitted()';
}
