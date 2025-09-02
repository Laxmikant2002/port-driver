part of 'account_bloc.dart';
abstract class AccountEvent extends Equatable {
    @override
    List<Object> get props => [];
}

class LoadAccountData extends AccountEvent {}

class UpdateProfileImage extends AccountEvent {
    final String imagePath;

    UpdateProfileImage(this.imagePath);

    @override
    List<Object> get props => [imagePath];
}

class LogoutRequested extends AccountEvent {}
