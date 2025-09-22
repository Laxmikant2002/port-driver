part of 'account_bloc.dart';

/// Base class for all Account events
sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when account data is loaded
final class LoadAccountData extends AccountEvent {
  const LoadAccountData();

  @override
  String toString() => 'LoadAccountData()';
}


/// Event triggered when profile image is updated
final class UpdateProfileImage extends AccountEvent {
  const UpdateProfileImage(this.imagePath);

  final String imagePath;

  @override
  List<Object> get props => [imagePath];

  @override
  String toString() => 'UpdateProfileImage(imagePath: $imagePath)';
}


/// Event triggered when logout is requested
final class LogoutRequested extends AccountEvent {
  const LogoutRequested();

  @override
  String toString() => 'LogoutRequested()';
}
