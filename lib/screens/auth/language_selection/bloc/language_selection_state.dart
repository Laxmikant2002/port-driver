part of 'language_selection_bloc.dart';

/// Language selection state containing form data and submission status
final class LanguageSelectionState extends Equatable {
  const LanguageSelectionState({
    this.selectedLanguages = const [],
    this.status = FormzSubmissionStatus.initial,
    this.routeDecision,
    this.errorMessage,
  });

  final List<String> selectedLanguages;
  final FormzSubmissionStatus status;
  final RouteDecision? routeDecision;
  final String? errorMessage;

  /// Returns true if at least one language is selected
  bool get hasSelection => selectedLanguages.isNotEmpty;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  LanguageSelectionState copyWith({
    List<String>? selectedLanguages,
    FormzSubmissionStatus? status,
    RouteDecision? routeDecision,
    String? errorMessage,
  }) {
    return LanguageSelectionState(
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      status: status ?? this.status,
      routeDecision: routeDecision ?? this.routeDecision,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedLanguages,
        status,
        routeDecision,
        errorMessage,
      ];

  @override
  String toString() {
    return 'LanguageSelectionState('
        'selectedLanguages: $selectedLanguages, '
        'status: $status, '
        'routeDecision: $routeDecision, '
        'errorMessage: $errorMessage'
        ')';
  }
}
