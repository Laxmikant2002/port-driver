import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:driver/locator.dart';
import 'package:driver/routes/main_routes.dart';
import 'package:driver/services/developer_mode_service.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver_status/driver_status.dart';

import '../bloc/driver_status_bloc.dart';
import '../constants/dashboard_constants.dart';

/// Main dashboard screen for driver status management.
/// 
/// This screen allows drivers to:
/// - Toggle their online/offline status
/// - View daily earnings and trip count
/// - Manage their work area
/// - Access developer mode (debug builds only)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverStatusBloc(
        driverStatusRepo: lc(),
        socketService: lc(),
      )..add(const DriverStatusInitialized()),
      child: const DashboardView(),
    );
  }
}

/// Main view widget that builds the dashboard UI.
/// 
/// Handles error display via [BlocListener] and organizes the main UI layout.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: DeveloperModeService.getDeveloperModeFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocListener<DriverStatusBloc, DriverStatusState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? DashboardConstants.defaultError),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          }
        },
        child: GestureDetector(
          onLongPress: () => DeveloperModeService.handleLongPress(context),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(DashboardConstants.defaultPadding),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const _HeaderSection(),
                  const SizedBox(height: 48),
                  const _StatusToggleCard(),
                  const SizedBox(height: 32),
                  const _EarningsCard(),
                  const SizedBox(height: 24),
                  const _WorkAreaCard(),
                  const Spacer(),
                  const _FooterSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Header section displaying app logo and welcome message.
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo/Icon
        Container(
          padding: const EdgeInsets.all(DashboardConstants.logoSize),
          decoration: BoxDecoration(
            color: AppColors.cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DashboardConstants.borderRadius),
          ),
          child: Icon(
            Icons.directions_car_rounded,
            size: DashboardConstants.iconSize,
            color: AppColors.cyan,
          ),
        ),
        const SizedBox(height: 24),
        // Welcome Text
        Text(
          DashboardConstants.appTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          DashboardConstants.appSubtitle,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Interactive card for toggling driver online/offline status.
/// 
/// Features:
/// - Visual status indicator with colored dot
/// - Large toggle switch for easy interaction
/// - Confirmation dialog for going offline
/// - Loading state during status changes
class _StatusToggleCard extends StatelessWidget {
  const _StatusToggleCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
      buildWhen: (previous, current) => 
          previous.driverStatus != current.driverStatus ||
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Status Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: state.isOnline ? AppColors.success : AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (state.isOnline ? AppColors.success : AppColors.error).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    state.statusDisplayText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: state.isOnline ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Toggle Switch
              Transform.scale(
                scale: 1.5,
                child: Switch(
                  value: state.isOnline,
                  onChanged: state.isSubmitting ? null : (value) {
                    if (!value) {
                      _showOfflineConfirmation(context);
                    } else {
                      _toggleStatus(context, value);
                    }
                  },
                  activeColor: AppColors.success,
                  inactiveThumbColor: AppColors.error,
                  inactiveTrackColor: AppColors.error.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                state.isOnline ? 'Tap to go offline' : 'Tap to go online',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (state.isSubmitting)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Toggles the driver's status between online and offline.
  /// 
  /// [value] - true for online, false for offline
  void _toggleStatus(BuildContext context, bool value) {
    final newStatus = value ? DriverStatus.online : DriverStatus.offline;
    context.read<DriverStatusBloc>().add(DriverStatusToggled(newStatus));
    context.read<DriverStatusBloc>().add(const DriverStatusSubmitted());
  }

  /// Shows confirmation dialog before going offline.
  /// 
  /// Prevents accidental offline status changes that could impact earnings.
  void _showOfflineConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          DashboardConstants.goOfflineTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          DashboardConstants.goOfflineMessage,
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              DashboardConstants.cancel,
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleStatus(context, false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DashboardConstants.buttonBorderRadius),
              ),
            ),
            child: const Text(DashboardConstants.goOffline),
          ),
        ],
      ),
    );
  }
}

/// Card displaying today's earnings and trip count.
/// 
/// Shows two metrics side by side:
/// - Today's earnings in currency format
/// - Number of trips completed today
class _EarningsCard extends StatelessWidget {
  const _EarningsCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
      buildWhen: (previous, current) => 
          previous.earningsToday != current.earningsToday ||
          previous.tripsToday != current.tripsToday,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Earnings
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DashboardConstants.todaysEarnings,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.earningsText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                height: 50,
                width: 1,
                color: AppColors.border,
              ),
              // Trips
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DashboardConstants.tripsToday,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.tripsText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Card for managing the driver's work area.
/// 
/// Displays the current work area and provides a button to change it.
/// Navigates to work area selection screen when tapped.
class _WorkAreaCard extends StatelessWidget {
  const _WorkAreaCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
      buildWhen: (previous, current) => 
          previous.hasWorkArea != current.hasWorkArea ||
          previous.workArea != current.workArea,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.cyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DashboardConstants.workArea,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.hasWorkArea ? state.workArea.value : DashboardConstants.notSet,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: state.hasWorkArea ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, MainRoutes.workAreaSelection);
                },
                child: Text(
                  state.hasWorkArea ? DashboardConstants.change : DashboardConstants.set,
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Footer section displaying app metadata.
/// 
/// Shows:
/// - Last active timestamp
/// - App version information
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          DashboardConstants.lastActive,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          DashboardConstants.version,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
