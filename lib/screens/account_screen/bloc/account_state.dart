part of 'account_bloc.dart';

abstract class AccountState extends Equatable {
    const AccountState();

    @override
    List<Object> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
    final String? name;
    final String? vehicle;
    final String? profileImage;

    const AccountLoaded({
        this.name,
        this.vehicle,
        this.profileImage,
    });

    @override
    List<Object> get props => [name ?? '', vehicle ?? '', profileImage ?? ''];
}

class AccountError extends AccountState {
    final String message;

    const AccountError(this.message);

    @override
    List<Object> get props => [message];
}

class AccountLoggedOut extends AccountState {
    const AccountLoggedOut();

    @override
    List<Object> get props => [];
}
