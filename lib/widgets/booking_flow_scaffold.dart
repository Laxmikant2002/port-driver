import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/colors.dart';
import '../utils/result.dart';

/// Standardized scaffold for booking flow screens.
/// 
/// Provides consistent:
/// - Header styling and navigation
/// - Error handling with snackbars
/// - Loading states
/// - Bottom sheet integration
/// - Safe area handling
class BookingFlowScaffold extends StatelessWidget {
  const BookingFlowScaffold({
    super.key,
    required this.body,
    this.title,
    this.onBack,
    this.actions,
    this.bottomSheet,
    this.floatingActionButton,
    this.backgroundColor,
    this.showAppBar = true,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.errorStream,
    this.loadingStream,
    this.successMessageStream,
  });

  /// Main body content
  final Widget body;

  /// Screen title for app bar
  final String? title;

  /// Custom back button handler
  final VoidCallback? onBack;

  /// App bar actions
  final List<Widget>? actions;

  /// Bottom sheet widget
  final Widget? bottomSheet;

  /// Floating action button
  final Widget? floatingActionButton;

  /// Background color override
  final Color? backgroundColor;

  /// Whether to show the app bar
  final bool showAppBar;

  /// Whether body extends behind app bar
  final bool extendBodyBehindAppBar;

  /// Whether to resize for keyboard
  final bool resizeToAvoidBottomInset;

  /// Stream for error messages
  final Stream<AppError>? errorStream;

  /// Stream for loading states
  final Stream<bool>? loadingStream;

  /// Stream for success messages
  final Stream<String>? successMessageStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: showAppBar ? _buildAppBar(context) : null,
      body: Stack(
        children: [
          // Main body content
          body,

          // Bottom sheet overlay
          if (bottomSheet != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: bottomSheet!,
            ),

          // Loading overlay
          if (loadingStream != null)
            StreamBuilder<bool>(
              stream: loadingStream,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return _LoadingOverlay();
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      // Stream listeners for notifications
      // Note: These should be wrapped in a parent widget with access to streams
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: onBack != null || Navigator.canPop(context)
          ? IconButton(
              onPressed: onBack ?? () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            )
          : null,
      centerTitle: true,
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surface.withOpacity(0.9),
              AppColors.surface.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget that provides stream-based error and success notifications
class BookingFlowScaffoldWithStreams extends StatelessWidget {
  const BookingFlowScaffoldWithStreams({
    super.key,
    required this.child,
    this.errorStream,
    this.successMessageStream,
  });

  final BookingFlowScaffold child;
  final Stream<AppError>? errorStream;  
  final Stream<String>? successMessageStream;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Error notifications
        if (errorStream != null)
          BlocListener<StreamNotificationCubit<AppError>, AppError?>(
            bloc: StreamNotificationCubit(errorStream!),
            listener: (context, error) {
              if (error != null) {
                _showErrorSnackbar(context, error);
              }
            },
            child: Container(),
          ),

        // Success notifications  
        if (successMessageStream != null)
          BlocListener<StreamNotificationCubit<String>, String?>(
            bloc: StreamNotificationCubit(successMessageStream!),
            listener: (context, message) {
              if (message != null) {
                _showSuccessSnackbar(context, message);
              }
            },
            child: Container(),
          ),
      ],
      child: child,
    );
  }

  void _showErrorSnackbar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.surface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.message,
                  style: TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: AppColors.surface,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.surface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

/// Loading overlay widget
class _LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper cubit for converting streams to BLoC states for UI reactions
class StreamNotificationCubit<T> extends Cubit<T?> {
  StreamNotificationCubit(Stream<T> stream) : super(null) {
    _subscription = stream.listen((data) {
      emit(data);
    });
  }

  late final StreamSubscription<T> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}

/// Standard empty state widget for booking flow screens
class BookingFlowEmptyState extends StatelessWidget {
  const BookingFlowEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}