import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

import 'package:auth_repo/auth_repo.dart';
import 'package:driver/screens/auth/login/bloc/login_bloc.dart';

// Mock classes
class MockAuthRepo extends Mock implements AuthRepo {}

class FakeLoginRequest extends Fake implements LoginRequest {}

void main() {
  group('LoginBloc', () {
    late AuthRepo mockAuthRepo;
    late LoginBloc loginBloc;

    setUp(() {
      mockAuthRepo = MockAuthRepo();
      loginBloc = LoginBloc(authRepo: mockAuthRepo);
      
      // Register fakes
      registerFallbackValue(FakeLoginRequest());
    });

    tearDown(() {
      loginBloc.close();
    });

    test('initial state is correct', () {
      expect(loginBloc.state, const LoginState());
    });

    group('LoginPhoneChanged', () {
      blocTest<LoginBloc, LoginState>(
        'emits updated phone input when phone is changed',
        build: () => loginBloc,
        act: (bloc) => bloc.add(const LoginPhoneChanged('9876543210')),
        expect: () => [
          const LoginState(
            phoneInput: PhoneInput.dirty('9876543210'),
            status: FormzSubmissionStatus.initial,
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits invalid state when invalid phone is entered',
        build: () => loginBloc,
        act: (bloc) => bloc.add(const LoginPhoneChanged('123')),
        expect: () => [
          const LoginState(
            phoneInput: PhoneInput.dirty('123'),
            status: FormzSubmissionStatus.initial,
          ),
        ],
        verify: (bloc) {
          expect(bloc.state.phoneInput.isValid, false);
        },
      );
    });

    group('LoginSubmitted', () {
      blocTest<LoginBloc, LoginState>(
        'emits failure when phone is invalid',
        build: () => loginBloc,
        seed: () => const LoginState(
          phoneInput: PhoneInput.dirty('123'),
        ),
        act: (bloc) => bloc.add(const LoginSubmitted()),
        expect: () => [
          const LoginState(
            phoneInput: PhoneInput.dirty('123'),
            status: FormzSubmissionStatus.failure,
            errorMessage: 'Please enter a complete 10-digit number',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits success when phone check and OTP send succeed',
        build: () => loginBloc,
        setUp: () {
          when(() => mockAuthRepo.checkPhone(any())).thenAnswer(
            (_) async => const AuthResponse(
              success: true,
              message: 'Phone exists',
            ),
          );
          when(() => mockAuthRepo.sendOtp(any())).thenAnswer(
            (_) async => const AuthResponse(
              success: true,
              message: 'OTP sent successfully',
            ),
          );
        },
        seed: () => const LoginState(
          phoneInput: PhoneInput.dirty('9876543210'),
        ),
        act: (bloc) => bloc.add(const LoginSubmitted()),
        expect: () => [
          const LoginState(
            phoneInput: PhoneInput.dirty('9876543210'),
            status: FormzSubmissionStatus.inProgress,
          ),
          const LoginState(
            phoneInput: PhoneInput.dirty('9876543210'),
            status: FormzSubmissionStatus.success,
            phoneExists: true,
          ),
        ],
        verify: (bloc) {
          verify(() => mockAuthRepo.checkPhone('9876543210')).called(1);
          verify(() => mockAuthRepo.sendOtp(any())).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits failure when phone check fails',
        build: () => loginBloc,
        setUp: () {
          when(() => mockAuthRepo.checkPhone(any())).thenAnswer(
            (_) async => const AuthResponse(
              success: false,
              message: 'Phone number not found',
            ),
          );
        },
        seed: () => const LoginState(
          phoneInput: PhoneInput.dirty('9876543210'),
        ),
        act: (bloc) => bloc.add(const LoginSubmitted()),
        expect: () => [
          const LoginState(
            phoneInput: PhoneInput.dirty('9876543210'),
            status: FormzSubmissionStatus.inProgress,
          ),
          const LoginState(
            phoneInput: PhoneInput.dirty('9876543210'),
            status: FormzSubmissionStatus.failure,
            errorMessage: 'Phone number not found',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits failure when OTP send fails',
        build: () => loginBloc,
        setUp: () {
          when(() => mockAuthRepo.checkPhone(any())).thenAnswer(
            (_) async => const AuthResponse(
              success: true,
              message: 'Phone exists',
            ),
          );
          when(() => mockAuthRepo.sendOtp(any())).thenAnswer(
            (_) async => const AuthResponse(
              success: false,
              message: 'Failed to send OTP',
            ),
          );
        },
        seed: () => const LoginState(
          phoneInput: PhoneInput.dirty('9876543210'),
        ),
        act: (bloc) => bloc.add(const LoginSubmitted()),
        expect: () => [
          const LoginState(
            phoneInput: PhoneInput.dirty('9876543210'),
            status: FormzSubmissionStatus.inProgress,
          ),
          const LoginState(
            phoneInput: PhoneInput.dirty('9876543210'),
            status: FormzSubmissionStatus.failure,
            errorMessage: 'Failed to send OTP',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits failure when network error occurs',
        build: () => loginBloc,
        setUp: () {
          when(() => mockAuthRepo.checkPhone(any())).thenThrow(
            Exception('Network error'),
          );
        },
        seed: () => const LoginState(
          phoneInput: PhoneInput.dirty('9876543210'),
        ),
        act: (bloc) => bloc.add(const LoginSubmitted()),
        expect: () => [
          const LoginState(
            phoneInput: PhoneInput.dirty('9876543210'),
            status: FormzSubmissionStatus.inProgress,
          ),
          const LoginState(
            phoneInput: PhoneInput.dirty('9876543210'),
            status: FormzSubmissionStatus.failure,
            errorMessage: 'Network error. Please try again.',
          ),
        ],
      );
    });
  });

  group('PhoneInput', () {
    group('constructor', () {
      test('pure creates correct instance', () {
        const phoneInput = PhoneInput.pure();
        expect(phoneInput.value, '');
        expect(phoneInput.isPure, true);
      });

      test('dirty creates correct instance', () {
        const phoneInput = PhoneInput.dirty('9876543210');
        expect(phoneInput.value, '9876543210');
        expect(phoneInput.isPure, false);
      });
    });

    group('validation', () {
      test('returns null for valid phone number', () {
        const phoneInput = PhoneInput.dirty('9876543210');
        expect(phoneInput.isValid, true);
        expect(phoneInput.error, null);
      });

      test('returns error for empty phone number', () {
        const phoneInput = PhoneInput.dirty('');
        expect(phoneInput.isValid, false);
        expect(phoneInput.error, 'empty');
      });

      test('returns error for incomplete phone number', () {
        const phoneInput = PhoneInput.dirty('98765');
        expect(phoneInput.isValid, false);
        expect(phoneInput.error, 'incomplete');
      });

      test('returns error for too long phone number', () {
        const phoneInput = PhoneInput.dirty('98765432100');
        expect(phoneInput.isValid, false);
        expect(phoneInput.error, 'too_long');
      });

      test('returns error for invalid start digit', () {
        const phoneInput = PhoneInput.dirty('1234567890');
        expect(phoneInput.isValid, false);
        expect(phoneInput.error, 'invalid_start');
      });

      test('handles phone number with spaces', () {
        const phoneInput = PhoneInput.dirty('98765 43210');
        expect(phoneInput.isValid, true);
        expect(phoneInput.cleanValue, '9876543210');
      });
    });

    group('displayError', () {
      test('returns correct error message for empty input', () {
        const phoneInput = PhoneInput.dirty('');
        expect(phoneInput.displayError, 'Mobile number is required');
      });

      test('returns correct error message for incomplete input', () {
        const phoneInput = PhoneInput.dirty('98765');
        expect(phoneInput.displayError, 'Please enter a complete 10-digit number');
      });

      test('returns null for valid input', () {
        const phoneInput = PhoneInput.dirty('9876543210');
        expect(phoneInput.displayError, null);
      });
    });

    group('helper properties', () {
      test('isComplete returns true for 10-digit number', () {
        const phoneInput = PhoneInput.dirty('9876543210');
        expect(phoneInput.isComplete, true);
      });

      test('isComplete returns false for incomplete number', () {
        const phoneInput = PhoneInput.dirty('98765');
        expect(phoneInput.isComplete, false);
      });

      test('cleanValue removes non-digit characters', () {
        const phoneInput = PhoneInput.dirty('98765-43210');
        expect(phoneInput.cleanValue, '9876543210');
      });
    });
  });

  group('LoginState', () {
    test('supports value equality', () {
      const state1 = LoginState();
      const state2 = LoginState();
      expect(state1, state2);
    });

    test('props are correct', () {
      const state = LoginState(
        phoneInput: PhoneInput.dirty('9876543210'),
        status: FormzSubmissionStatus.success,
        phoneExists: true,
        errorMessage: 'Error',
      );

      expect(
        state.props,
        [
          const PhoneInput.dirty('9876543210'),
          FormzSubmissionStatus.success,
          true,
          'Error',
        ],
      );
    });

    group('helper properties', () {
      test('isValid returns true when phone input is valid', () {
        const state = LoginState(
          phoneInput: PhoneInput.dirty('9876543210'),
        );
        expect(state.isValid, true);
      });

      test('isSubmitting returns true when status is inProgress', () {
        const state = LoginState(
          status: FormzSubmissionStatus.inProgress,
        );
        expect(state.isSubmitting, true);
      });

      test('isSuccess returns true when status is success', () {
        const state = LoginState(
          status: FormzSubmissionStatus.success,
        );
        expect(state.isSuccess, true);
      });

      test('isFailure returns true when status is failure', () {
        const state = LoginState(
          status: FormzSubmissionStatus.failure,
        );
        expect(state.isFailure, true);
      });

      test('hasError returns true when errorMessage is not null', () {
        const state = LoginState(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Error',
        );
        expect(state.hasError, true);
      });
    });

    group('copyWith', () {
      test('returns same object if no arguments provided', () {
        const state = LoginState();
        expect(state.copyWith(), state);
      });

      test('replaces non-null arguments', () {
        const state = LoginState();
        final newState = state.copyWith(
          phoneInput: const PhoneInput.dirty('9876543210'),
          status: FormzSubmissionStatus.success,
        );

        expect(newState.phoneInput, const PhoneInput.dirty('9876543210'));
        expect(newState.status, FormzSubmissionStatus.success);
        expect(newState.phoneExists, state.phoneExists);
      });

      test('updates errorMessage', () {
        const state = LoginState();
        final newState = state.copyWith(errorMessage: 'New error');

        expect(newState.errorMessage, 'New error');
      });
    });
  });
}