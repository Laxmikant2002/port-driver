part of 'auth_bloc.dart';

/// Authentication state representing the current authentication status
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];

  /// Initial state when app starts
  const factory AuthState.initial() = AuthInitial;

  /// Loading state during authentication operations
  const factory AuthState.loading() = AuthLoading;

  /// Authenticated state with user data
  const factory AuthState.authenticated(AuthUser user) = AuthAuthenticated;

  /// Unauthenticated state (user not logged in)
  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  /// Error state with error message
  const factory AuthState.error(String message) = AuthError;

  /// Check if user is authenticated
  bool get isAuthenticated => this is AuthAuthenticated;

  /// Check if authentication is loading
  bool get isLoading => this is AuthLoading;

  /// Check if there's an error
  bool get hasError => this is AuthError;

  /// Get current user (if authenticated)
  AuthUser? get user {
    if (this is AuthAuthenticated) {
      return (this as AuthAuthenticated).user;
    }
    return null;
  }

  /// Get error message (if error state)
  String? get errorMessage {
    if (this is AuthError) {
      return (this as AuthError).message;
    }
    return null;
  }
}

/// Initial authentication state
final class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  String toString() => 'AuthInitial()';
}

/// Loading authentication state
final class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  String toString() => 'AuthLoading()';
}

/// Authenticated state with user data
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AuthUser user;

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'AuthAuthenticated(user: $user)';
}

/// Unauthenticated state
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  String toString() => 'AuthUnauthenticated()';
}

/// Error authentication state
final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AuthError(message: $message)';
}
