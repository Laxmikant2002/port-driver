part of 'language_selection_bloc.dart';

enum LanguageSelectionStatus {
  initial,
  success,
}

class LanguageSelectionState extends Equatable {
  const LanguageSelectionState({
    this.status = LanguageSelectionStatus.initial,
    this.selectedLanguage,
  });

  final LanguageSelectionStatus status;
  final String? selectedLanguage;

  bool get isSuccess => status == LanguageSelectionStatus.success;
  bool get hasSelectedLanguage => selectedLanguage != null;

  LanguageSelectionState copyWith({
    LanguageSelectionStatus? status,
    String? selectedLanguage,
  }) {
    return LanguageSelectionState(
      status: status ?? this.status,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }

  @override
  List<Object?> get props => [status, selectedLanguage];
}