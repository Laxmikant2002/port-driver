import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:history_repo/history_repo.dart';
import '../../../../widgets/colors.dart';
import '../bloc/trip_history_bloc.dart';
import '../data/sample_trip_data.dart';

class TripHistoryScreen extends StatelessWidget {
  final HistoryRepo historyRepo;
  final String driverId;
  
  const TripHistoryScreen({
    Key? key,
    required this.historyRepo,
    required this.driverId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripHistoryBloc(
        historyRepo: historyRepo,
        driverId: driverId,
      )..add(const TripHistoryLoaded()),
      child: const TripHistoryView(),
    );
  }
}

class TripHistoryView extends StatefulWidget {
  const TripHistoryView({super.key});

  @override
  State<TripHistoryView> createState() => _TripHistoryViewState();
}

class _TripHistoryViewState extends State<TripHistoryView> {
  String _selectedDateFilter = 'Day';
  String _selectedStatusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<TripHistoryBloc, TripHistoryState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to load trip history'),
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
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterSection(),
              Expanded(
                child: _buildTripList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                BlocBuilder<TripHistoryBloc, TripHistoryState>(
                  builder: (context, state) {
                    return Text(
                      '${state.currentRides.length} trips',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              'Day',
              ['Day', 'Week', 'Month'],
              _selectedDateFilter,
              (value) {
                setState(() {
                  _selectedDateFilter = value!;
                });
                _applyFilters();
              },
              Icons.calendar_today_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterDropdown(
              'All',
              ['All', 'Cash', 'Online', 'Mixed', 'Completed', 'Cancelled'],
              _selectedStatusFilter,
              (value) {
                setState(() {
                  _selectedStatusFilter = value!;
                });
                _applyFilters();
              },
              Icons.filter_list_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    List<String> options,
    String selectedValue,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTripList() {
    return BlocBuilder<TripHistoryBloc, TripHistoryState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final trips = state.currentRides;
        
        if (trips.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            return _buildTripCard(trips[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            'No Trips Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your completed trips will appear here.',
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

  Widget _buildTripCard(Ride trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripHeader(trip),
            const SizedBox(height: 16),
            _buildRouteInfo(trip),
            const SizedBox(height: 16),
            _buildTripDetails(trip),
            const SizedBox(height: 16),
            _buildPaymentInfo(trip),
            const SizedBox(height: 16),
            _buildEarningsInfo(trip),
            const SizedBox(height: 16),
            _buildDetailsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHeader(Ride trip) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(trip.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getStatusText(trip.status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(trip.status),
            ),
          ),
        ),
        const Spacer(),
        Text(
          '₹${trip.fare.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(Ride trip) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: AppColors.border.withOpacity(0.3),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.startLocation.address,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                trip.endLocation.address,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripDetails(Ride trip) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          trip.tripDate ?? _formatDate(trip.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.access_time_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          trip.tripTime ?? _formatTime(trip.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Completed',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(Ride trip) {
    return Row(
      children: [
        Icon(
          Icons.directions_car_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${trip.distance.toStringAsFixed(1)} km',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.access_time_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${trip.duration} min',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPaymentMethodColor(trip.paymentMethod).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPaymentMethodIcon(trip.paymentMethod),
                size: 12,
                color: _getPaymentMethodColor(trip.paymentMethod),
              ),
              const SizedBox(width: 4),
              Text(
                _getPaymentMethodText(trip.paymentMethod),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getPaymentMethodColor(trip.paymentMethod),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsInfo(Ride trip) {
    final earnedAmount = trip.earnedAmount ?? (trip.fare * 0.85); // 85% of fare as earnings
    
    return Row(
      children: [
        Text(
          '₹${trip.fare.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          'Earned: ₹${earnedAmount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.success,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Navigate to trip details
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tap for full details',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.credit_card_rounded,
              size: 12,
              color: AppColors.textSecondary,
            ),
          ],
        ),
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
    }
  }

  Color _getPaymentMethodColor(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.cash:
        return AppColors.warning;
      case PaymentMethod.online:
        return AppColors.primary;
      case PaymentMethod.card:
        return AppColors.cyan;
      case PaymentMethod.wallet:
        return AppColors.success;
      case null:
        return AppColors.textSecondary;
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money_rounded;
      case PaymentMethod.online:
        return Icons.payment_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet_rounded;
      case null:
        return Icons.payment_rounded;
    }
  }

  String _getPaymentMethodText(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.online:
        return 'Online';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.wallet:
        return 'Wallet';
      case null:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _applyFilters() {
    // Apply date and status filters
    context.read<TripHistoryBloc>().add(
      RidesFiltered(
        status: _selectedStatusFilter == 'All' ? null : 
                _selectedStatusFilter == 'Completed' ? RideStatus.completed :
                _selectedStatusFilter == 'Cancelled' ? RideStatus.cancelled : null,
        startDate: _getDateRangeStart(),
        endDate: _getDateRangeEnd(),
      ),
    );
  }

  DateTime? _getDateRangeStart() {
    final now = DateTime.now();
    switch (_selectedDateFilter) {
      case 'Day':
        return DateTime(now.year, now.month, now.day);
      case 'Week':
        return now.subtract(const Duration(days: 7));
      case 'Month':
        return DateTime(now.year, now.month - 1, now.day);
      default:
        return null;
    }
  }

  DateTime? _getDateRangeEnd() {
    return DateTime.now();
  }
}
