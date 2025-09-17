part of 'language_bloc.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class LanguageChanged extends LanguageEvent {
  const LanguageChanged(this.language);

  final String language;

  @override
  List<Object> get props => [language];
}

class LanguageSubmitted extends LanguageEvent {
  const LanguageSubmitted();
}
