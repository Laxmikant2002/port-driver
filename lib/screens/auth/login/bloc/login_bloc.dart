import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:auth_repo/auth_repo.dart';
import 'package:driver/screens/auth/login/view/phone_field.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';
part 'login_event.dart';

enum PhoneInputError { empty, invalid }

class PhoneInput extends FormzInput<String, PhoneInputError> {
  const PhoneInput.pure() : super.pure('');
  const PhoneInput.dirty([String value = '']) : super.dirty(value);

  @override
  PhoneInputError? validator(String value) {
    if (value.isEmpty) {
      return PhoneInputError.empty;
    }
    if (value.length != 10) {
      return PhoneInputError.invalid;
    }
    return null;
  }

  static String? getErrorMsg(PhoneInputError? err) {
    switch (err) {
      case PhoneInputError.empty:
        return 'Phone number cannot be empty';
      case PhoneInputError.invalid:
        return 'Please enter a valid 10-digit phone number';
      default:
        return null;
    }
  }
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this.authRepo) : super(const LoginState()) {
    on<ChangePhone>(_changePhone);
    on<Submit>(_submit);
  }

  final AuthRepo authRepo;

  void _changePhone(ChangePhone event, Emitter<LoginState> emit) {
    final phoneInput = PhoneInput.dirty(event.phone);
    emit(
      state.copyWith(
        phoneInput: phoneInput,
        status: FormzSubmissionStatus.initial,
        error: null,
      ),
    );
  }

  Future<void> _submit(Submit event, Emitter<LoginState> emit) async {
    // Validate phone
    final phoneInput = PhoneInput.dirty(state.phoneInput.value);
    final phoneError = phoneInput.error;

    // Update state with validation results
    emit(state.copyWith(
      phoneInput: phoneInput,
      status: FormzSubmissionStatus.failure,
    ));

    // Check for validation errors
    if (phoneError != null) {
      return;
    }

    // If validation passes, proceed with OTP request
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final response = await authRepo.login(LoginRequest(phone: state.phoneInput.value));
      
      if (response.otpSent) {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          error: response.message ?? 'Failed to send OTP. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: 'An unexpected error occurred. Please try again.',
      ));
    }
  }
}
