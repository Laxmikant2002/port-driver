part of 'auth_bloc.dart';

/// Base class for all authentication events
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when authentication status needs to be checked
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();

  @override
  String toString() => 'AuthCheckRequested()';
}

/// Event triggered when user successfully logs in
final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested();

  @override
  String toString() => 'AuthLoginRequested()';
}

/// Event triggered when user logs out
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();

  @override
  String toString() => 'AuthLogoutRequested()';
}

/// Event triggered when token needs to be refreshed
final class AuthTokenRefreshRequested extends AuthEvent {
  const AuthTokenRefreshRequested();

  @override
  String toString() => 'AuthTokenRefreshRequested()';
}

/// Event triggered when user data changes
final class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final AuthUser user;

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'AuthUserChanged(user: $user)';
}
