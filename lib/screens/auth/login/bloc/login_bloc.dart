import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<ChangePhone>(_onPhoneChanged);
    on<SubmitLogin>(_onLoginSubmitted);
  }

  void _onPhoneChanged(ChangePhone event, Emitter<LoginState> emit) {
    final phoneInput = PhoneInput.dirty(event.phone);
    // Only update the input and reset status to initial, do not set failure while typing
    emit(state.copyWith(
      phoneInput: phoneInput,
      status: FormzSubmissionStatus.initial,
      error: null,
    ));
  }

  Future<void> _onLoginSubmitted(
    SubmitLogin event,
    Emitter<LoginState> emit,
  ) async {
    if (!Formz.validate([state.phoneInput])) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Simulate API call for sending OTP
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        error: 'OTP sent to your phone number.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
