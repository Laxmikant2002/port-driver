import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

/// Base state for form screens
abstract class BaseFormState extends Equatable {
  const BaseFormState({
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });
  
  final FormzSubmissionStatus status;
  final String? errorMessage;
  
  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;
  
  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;
  
  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;
  
  /// Returns true if the form is in initial state
  bool get isInitial => status == FormzSubmissionStatus.initial;
  
  /// Returns true if there's an error
  bool get hasError => errorMessage != null;
  
  /// Returns true if form can be submitted (override in subclasses)
  bool get canSubmit => true;
  
  @override
  List<Object?> get props => [status, errorMessage];
}

/// Base authentication state
abstract class BaseAuthState extends BaseFormState {
  const BaseAuthState({
    super.status,
    super.errorMessage,
    this.user,
    this.routeDecision,
  });
  
  final dynamic user; // Can be AuthUser or similar
  final dynamic routeDecision; // RouteDecision or similar
  
  /// Returns true if user is authenticated
  bool get isAuthenticated => user != null;
  
  /// Returns true if navigation should occur
  bool get shouldNavigate => routeDecision != null;
  
  @override
  List<Object?> get props => [
    ...super.props,
    user,
    routeDecision,
  ];
}

/// Base onboarding state
abstract class BaseOnboardingState extends BaseFormState {
  const BaseOnboardingState({
    super.status,
    super.errorMessage,
    this.currentStep = 0,
    this.totalSteps = 1,
    this.completedSteps = const [],
    this.routeDecision,
  });
  
  final int currentStep;
  final int totalSteps;
  final List<String> completedSteps;
  final dynamic routeDecision;
  
  /// Returns progress as percentage (0.0 to 1.0)
  double get progress => totalSteps > 0 ? currentStep / totalSteps : 0.0;
  
  /// Returns true if this is the first step
  bool get isFirstStep => currentStep == 0;
  
  /// Returns true if this is the last step
  bool get isLastStep => currentStep >= totalSteps - 1;
  
  /// Returns true if can go to next step
  bool get canProceed => canSubmit && !isSubmitting;
  
  /// Returns true if navigation should occur
  bool get shouldNavigate => routeDecision != null;
  
  @override
  List<Object?> get props => [
    ...super.props,
    currentStep,
    totalSteps,
    completedSteps,
    routeDecision,
  ];
}

/// Base list state for screens with loading lists
abstract class BaseListState<T> extends Equatable {
  const BaseListState({
    this.status = BaseListStatus.initial,
    this.items = const [],
    this.selectedItem,
    this.errorMessage,
    this.hasReachedMax = false,
  });
  
  final BaseListStatus status;
  final List<T> items;
  final T? selectedItem;
  final String? errorMessage;
  final bool hasReachedMax;
  
  /// Returns true if currently loading
  bool get isLoading => status == BaseListStatus.loading;
  
  /// Returns true if loaded successfully
  bool get isLoaded => status == BaseListStatus.loaded;
  
  /// Returns true if loading failed
  bool get isFailure => status == BaseListStatus.failure;
  
  /// Returns true if list is empty
  bool get isEmpty => items.isEmpty;
  
  /// Returns true if an item is selected
  bool get hasSelection => selectedItem != null;
  
  /// Returns true if there's an error
  bool get hasError => errorMessage != null;
  
  @override
  List<Object?> get props => [
    status,
    items,
    selectedItem,
    errorMessage,
    hasReachedMax,
  ];
}

/// Status enum for list states
enum BaseListStatus {
  initial,
  loading,
  loaded,
  failure,
  refreshing,
}

/// Base validation mixin for common validation helpers
mixin BaseValidationMixin {
  /// Validates if a string is not empty
  bool isNotEmpty(String? value) => value != null && value.trim().isNotEmpty;
  
  /// Validates email format
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$')
        .hasMatch(email);
  }
  
  /// Validates phone number format
  bool isValidPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(clean);
  }
  
  /// Validates password strength
  bool isValidPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password);
  }
  
  /// Validates if two passwords match
  bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
  
  /// Validates if string contains only alphabets and spaces
  bool isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }
  
  /// Validates if string is numeric
  bool isNumeric(String value) {
    return RegExp(r'^\d+$').hasMatch(value);
  }
}