import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:history_repo/history_repo.dart';
import '../../../../widgets/colors.dart';
import '../bloc/ride_history_bloc.dart';

class RideHistoryScreen extends StatelessWidget {
  final HistoryRepo historyRepo;
  
  const RideHistoryScreen({
    Key? key,
    required this.historyRepo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RideHistoryBloc(historyRepo: historyRepo)..add(const RideHistoryLoaded()),
      child: const RideHistoryView(),
    );
  }
}

class RideHistoryView extends StatelessWidget {
  const RideHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<RideHistoryBloc, RideHistoryState>(
        listener: (context, state) {
          if (state.isSuccess) {
            // Handle success
          } else if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to load ride history'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const _HeaderSection(),
                const SizedBox(height: 24),
                const _StatisticsCard(),
                const SizedBox(height: 24),
                const _RideHistoryListCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.cyan.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // History Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.history_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Header Text
          Text(
            'Ride History',
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
            'Track your completed rides and earnings',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideHistoryBloc, RideHistoryState>(
      builder: (context, state) {
        final totalRides = state.allRides.length;
        final completedRides = state.allRides.where((r) => r.status == RideStatus.completed).length;
        final totalEarnings = state.allRides
            .where((r) => r.status == RideStatus.completed)
            .fold(0.0, (sum, ride) => sum + (ride.fare ?? 0.0));
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
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
              BoxShadow(
                color: AppColors.border.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ride Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Your performance overview',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Statistics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Rides',
                        totalRides.toString(),
                        Icons.directions_car_rounded,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        'Completed',
                        completedRides.toString(),
                        Icons.check_circle_rounded,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Earnings',
                        '₹${totalEarnings.toStringAsFixed(0)}',
                        Icons.account_balance_wallet_rounded,
                        AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        'Success Rate',
                        totalRides > 0 ? '${((completedRides / totalRides) * 100).toStringAsFixed(0)}%' : '0%',
                        Icons.trending_up_rounded,
                        AppColors.cyan,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RideHistoryListCard extends StatelessWidget {
  const _RideHistoryListCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideHistoryBloc, RideHistoryState>(
      builder: (context, state) {
        final rides = state.currentRides;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
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
              BoxShadow(
                color: AppColors.border.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Rides',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            '${rides.length} total rides',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Rides List
                if (rides.isEmpty)
                  _buildEmptyState()
                else
                  ...rides.take(10).map((ride) => _buildRideItem(ride)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: 40,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Rides Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your completed rides will appear here.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRideItem(Ride ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and fare
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(ride.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(ride.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(ride.status),
                  ),
                ),
              ),
              const Spacer(),
              if (ride.fare != null)
                Text(
                  '₹${ride.fare!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Route information
          Row(
            children: [
              // Pickup
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ride.startLocation.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Dropoff
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ride.endLocation.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date and time
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(ride.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              if (ride.passengerName != null)
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ride.passengerName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.completed:
        return AppColors.success;
      case RideStatus.cancelled:
        return AppColors.error;
      case RideStatus.started:
        return AppColors.warning;
      case RideStatus.accepted:
        return AppColors.cyan;
      case RideStatus.requested:
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
      case RideStatus.started:
        return 'In Progress';
      case RideStatus.accepted:
        return 'Accepted';
      case RideStatus.requested:
        return 'Requested';
      default:
        return 'Unknown';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return 'Today ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
