import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountState()) {
    on<LoadAccountData>(_onLoadAccountData);
    on<UpdateProfileImage>(_onUpdateProfileImage);
    on<LogoutRequested>(_onLogoutRequested);
  }


  Future<void> _onLoadAccountData(LoadAccountData event, Emitter<AccountState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Simulate API call to load account data
      await Future.delayed(const Duration(seconds: 1));
      
      final userData = {
        'name': 'John Doe',
        'vehicle': 'Toyota Camry MH 34 1234',
        'profileImage': null,
      };

      final name = Name.dirty(userData['name'] ?? '');
      final vehicle = Vehicle.dirty(userData['vehicle'] ?? '');

      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        name: name,
        vehicle: vehicle,
        profileImage: userData['profileImage'] ?? '',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Simulate API call to update profile image
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        profileImage: event.imagePath,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }


  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AccountState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Simulate API call for logout
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }
}
