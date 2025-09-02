import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
    AccountBloc() : super(AccountInitial()) {
        on<LoadAccountData>(_onLoadAccountData);
        on<UpdateProfileImage>(_onUpdateProfileImage);
        on<LogoutRequested>(_onLogoutRequested);
    }

    Future<void> _onLoadAccountData(LoadAccountData event, Emitter<AccountState> emit) async {
        emit(AccountLoading());
        try {
            emit(AccountLoading());
            final userData = {
                'name': 'John Doe',
                'vehicle': 'Toyota Camry MH 34 1234',
                'profileImage': null,
            };

            emit(AccountLoaded(
              name: userData['name'],
              vehicle: userData['vehicle'],
              profileImage: userData['profileImage'] ?? '', 
            ));
        } catch (error) {
            emit(AccountError(error.toString()));
        }
    }

    Future<void> _onUpdateProfileImage(
        UpdateProfileImage event,
        Emitter<AccountState> emit,
    ) async {
        try {
            emit(AccountLoading());
            add(LoadAccountData());
        } catch (error) {
            emit(AccountError(error.toString()));
        }
    }

    Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AccountState> emit) async {
        try {
            emit(AccountLoading());
            emit(AccountLoggedOut());
        } catch (error) {
            emit(AccountError(error.toString()));
        }
    }

}
