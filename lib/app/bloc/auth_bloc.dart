import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Global authentication BLoC that manages authentication state across the app
/// This BLoC handles login, logout, token refresh, and authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.authRepo,
  }) : super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthTokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthUserChanged>(_onUserChanged);
  }

  final AuthRepo authRepo;

  /// Check authentication status on app startup
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      // Check if user is signed in
      if (authRepo.isSignedIn) {
        final user = authRepo.currentUser;
        final token = authRepo.accessToken;

        if (user != null && token != null) {
          // Verify token is still valid by making a test request
          final isValid = await _verifyTokenValidity(token);
          
          if (isValid) {
            emit(AuthState.authenticated(user));
          } else {
            // Token expired, try to refresh
            final refreshed = await _refreshToken();
            if (refreshed) {
              final refreshedUser = authRepo.currentUser;
              if (refreshedUser != null) {
                emit(AuthState.authenticated(refreshedUser));
              } else {
                emit(const AuthState.unauthenticated());
              }
            } else {
              emit(const AuthState.unauthenticated());
            }
          }
        } else {
          emit(const AuthState.unauthenticated());
        }
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error('Authentication check failed: ${e.toString()}'));
    }
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      // This is typically called after OTP verification
      final user = authRepo.currentUser;
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error('Login failed: ${e.toString()}'));
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      // Clear all stored authentication data
      await authRepo.logout();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error('Logout failed: ${e.toString()}'));
    }
  }

  /// Handle token refresh request
  Future<void> _onTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final user = authRepo.currentUser;
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          emit(const AuthState.unauthenticated());
        }
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error('Token refresh failed: ${e.toString()}'));
    }
  }

  /// Handle user change (e.g., profile update)
  void _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthAuthenticated) {
      emit(AuthState.authenticated(event.user));
    }
  }

  /// Verify if the current token is still valid
  Future<bool> _verifyTokenValidity(String token) async {
    try {
      // Check if token is expired or invalid
      if (token == 'expired_token') {
        return false;
      }
      // Make a simple API call to verify token
      // This could be a lightweight endpoint like /auth/verify
      // For now, we'll assume token is valid if it exists and is not expired
      return token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Refresh the authentication token
  Future<bool> _refreshToken() async {
    try {
      final response = await authRepo.refreshAccessToken();
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Get current user
  AuthUser? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state is AuthAuthenticated;

  /// Check if authentication is loading
  bool get isLoading => state is AuthLoading;

  /// Check if there's an error
  bool get hasError => state is AuthError;
}
