import 'package:driver/core/form/base_form_state.dart';
import 'package:driver/core/error/error_handler.dart';
import 'package:driver/core/extensions/extensions.dart';
import 'package:formz/formz.dart';

/// Example implementation showing how to use the new base classes
/// alongside existing FormzInput implementations without inheritance conflicts.
/// 
/// This demonstrates composition over inheritance approach.

/// Enhanced phone input using the base helper while maintaining FormzInput
class EnhancedPhoneInput extends FormzInput<String, String> {
  const EnhancedPhoneInput.pure() : super.pure('');
  const EnhancedPhoneInput.dirty([String value = '']) : super.dirty(value);

  // Use the helper from BaseValidationMixin for validation logic
  @override
  String? validator(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanValue.isEmpty) return 'empty';
    if (cleanValue.length < 10) return 'incomplete';
    if (cleanValue.length > 10) return 'too_long';
    if (!RegExp(r'^[6-9]').hasMatch(cleanValue)) return 'invalid_start';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanValue)) return 'invalid';
    
    return null;
  }

  @override
  String? get displayError {
    if (error == null) return null;
    
    switch (error) {
      case 'empty':
        return 'Mobile number is required';
      case 'incomplete':
        return 'Please enter a complete 10-digit number';
      case 'too_long':
        return 'Mobile number should be 10 digits only';
      case 'invalid_start':
        return 'Mobile number should start with 6, 7, 8, or 9';
      case 'invalid':
        return 'Please enter a valid mobile number';
      default:
        return 'Invalid mobile number';
    }
  }

  // Add specific helper methods
  bool get isComplete => value.replaceAll(RegExp(r'[^\d]'), '').length == 10;
  String get cleanValue => value.replaceAll(RegExp(r'[^\d]'), '');
}

/// Enhanced login state using composition with base state mixins
class EnhancedLoginState extends BaseAuthState {
  const EnhancedLoginState({
    this.phoneInput = const EnhancedPhoneInput.pure(),
    super.status = FormzSubmissionStatus.initial,
    super.errorMessage,
    this.phoneExists = false,
  });

  final EnhancedPhoneInput phoneInput;
  final bool phoneExists;

  bool get isValid => Formz.validate([phoneInput]);

  EnhancedLoginState copyWith({
    EnhancedPhoneInput? phoneInput,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool? phoneExists,
    bool clearError = false,
  }) {
    return EnhancedLoginState(
      phoneInput: phoneInput ?? this.phoneInput,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      phoneExists: phoneExists ?? this.phoneExists,
    );
  }

  @override
  List<Object?> get props => [phoneInput, status, errorMessage, phoneExists];
}

/// Service implementation example using error handling
class EnhancedAuthService {
  const EnhancedAuthService({
    required this.authRepo,
    required this.errorHandler,
  });

  final dynamic authRepo; // Replace with actual AuthRepo type
  final ErrorHandler errorHandler;

  /// Validate phone with proper error handling
  Future<Result<bool>> validatePhone(String phone) async {
    try {
      // Use validation extension
      if (!phone.isValidPhone) {
        return Failure(
          ValidationException('Invalid phone number format'),
        );
      }

      final response = await authRepo.checkPhone(phone);
      
      // Assume response has success property
      if (response?.success == true) {
        return Success(true);
      } else {
        return Failure(
          ServerException('Phone validation failed'),
        );
      }
    } catch (e) {
      return Failure(
        ErrorHandler.createException(e),
      );
    }
  }

  /// Send OTP with error handling
  Future<Result<void>> sendOtp(String phone) async {
    try {
      final response = await authRepo.sendOtp({'phone': phone});
      
      if (response?.success == true) {
        return Success(null);
      } else {
        return Failure(
          ServerException('Failed to send OTP'),
        );
      }
    } catch (e) {
      return Failure(
        ErrorHandler.createException(e),
      );
    }
  }
}

/// Bloc implementation example using the enhanced components
/// This shows how to integrate all the improvements without changing
/// the existing architecture
/*
class EnhancedLoginBloc extends Bloc<LoginEvent, EnhancedLoginState> {
  EnhancedLoginBloc({
    required this.authService,
    required this.errorHandler,
  }) : super(const EnhancedLoginState()) {
    on<LoginPhoneChanged>(_onPhoneChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  final EnhancedAuthService authService;
  final ErrorHandler errorHandler;

  void _onPhoneChanged(
    LoginPhoneChanged event,
    Emitter<EnhancedLoginState> emit,
  ) {
    final phoneInput = EnhancedPhoneInput.dirty(event.phone);
    emit(state.copyWith(
      phoneInput: phoneInput,
      clearError: true,
    ));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<EnhancedLoginState> emit,
  ) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: state.phoneInput.displayError,
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    // Use the enhanced service with proper error handling
    final phoneResult = await authService.validatePhone(
      state.phoneInput.cleanValue,
    );

    if (phoneResult.isFailure) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: errorHandler.getDisplayMessage(phoneResult.exception!),
      ));
      return;
    }

    final otpResult = await authService.sendOtp(
      state.phoneInput.cleanValue,
    );

    if (otpResult.isSuccess) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        phoneExists: true,
      ));
    } else {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: errorHandler.getDisplayMessage(otpResult.exception!),
      ));
    }
  }
}
*/

/// Widget implementation example using the new form components
/*
class EnhancedLoginForm extends StatelessWidget {
  const EnhancedLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnhancedLoginBloc, EnhancedLoginState>(
      builder: (context, state) {
        return Column(
          children: [
            // Use the reusable form component
            FormFieldWrapper(
              label: 'Mobile Number',
              child: CustomTextField(
                hintText: 'Enter your mobile number',
                inputFormatters: [PhoneInputFormatter()],
                keyboardType: TextInputType.phone,
                onChanged: (value) => context.read<EnhancedLoginBloc>()
                    .add(LoginPhoneChanged(value)),
                errorText: state.phoneInput.displayError,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Use the loading button component
            LoadingButton(
              onPressed: state.isValid && !state.isSubmitting
                  ? () => context.read<EnhancedLoginBloc>()
                      .add(const LoginSubmitted())
                  : null,
              isLoading: state.isSubmitting,
              text: 'Send OTP',
            ),
            
            // Error display using status extensions
            if (state.status.isFailure && state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  state.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
*/