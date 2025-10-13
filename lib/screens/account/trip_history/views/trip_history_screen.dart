import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trip_repo/trip_repo.dart' as trip_repo;
import 'package:driver/models/booking.dart' as local_models;
import '../../../../widgets/colors.dart';
import '../bloc/trip_history_bloc.dart';
import 'package:driver/services/trip_history/trip_history_service.dart';
import 'package:driver/locator.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripHistoryBloc(
        tripHistoryService: sl<TripHistoryService>(),
      )..add(const TripHistoryInitialized()),
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
  String _selectedDateFilter = 'All';
  String _selectedStatusFilter = 'All';
  String _selectedPaymentFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      context.read<TripHistoryBloc>().add(const TripHistoryRefreshed());
                    },
                  ),
                ),
              );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
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
                      '${state.filteredTrips.length} trips',
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
          IconButton(
            onPressed: () {
              context.read<TripHistoryBloc>().add(const TripHistoryRefreshed());
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search trips...',
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<TripHistoryBloc>().add(
                      const TripHistorySearchPerformed(''),
                    );
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          context.read<TripHistoryBloc>().add(
            TripHistorySearchPerformed(value),
          );
        },
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
              'Period',
              ['All', 'Today', 'Week', 'Month'],
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
              'Status',
              ['All', 'Completed', 'Cancelled', 'Pending'],
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
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterDropdown(
              'Payment',
              ['All', 'Cash', 'Online', 'Card'],
              _selectedPaymentFilter,
              (value) {
                setState(() {
                  _selectedPaymentFilter = value!;
                });
                _applyFilters();
              },
              Icons.payment_rounded,
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
                      fontSize: 12,
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

        final trips = state.filteredTrips;
        
        if (trips.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<TripHistoryBloc>().add(const TripHistoryRefreshed());
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: trips.length + (state.hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index == trips.length) {
                // Load more indicator
                if (state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          context.read<TripHistoryBloc>().add(const TripHistoryLoadMore());
                        },
                        child: const Text('Load More'),
                      ),
                    ),
                  );
                }
              }
              
              return _buildTripCard(trips[index]);
            },
          ),
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
            'No Trips Found',
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

  Widget _buildTripCard(local_models.Booking trip) {
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
            _buildActionButtons(trip),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHeader(local_models.Booking trip) {
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
          '₹${trip.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(local_models.Booking trip) {
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
                trip.pickupAddress,
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
                trip.dropoffAddress,
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

  Widget _buildTripDetails(local_models.Booking trip) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(trip.createdAt),
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
          _formatTime(trip.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(trip.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(trip.status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(trip.status),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(local_models.Booking trip) {
    return Row(
      children: [
        Icon(
          Icons.directions_car_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${trip.distanceKm.toStringAsFixed(1)} km',
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
          '${trip.durationMinutes} min',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPaymentMethodColor(trip.paymentMode).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPaymentMethodIcon(trip.paymentMode),
                size: 12,
                color: _getPaymentMethodColor(trip.paymentMode),
              ),
              const SizedBox(width: 4),
              Text(
                _getPaymentMethodText(trip.paymentMode),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getPaymentMethodColor(trip.paymentMode),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsInfo(local_models.Booking trip) {
    return Row(
      children: [
        Text(
          '₹${trip.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          'Earned: ₹${trip.netEarnings.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.success,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(local_models.Booking trip) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<TripHistoryBloc>().add(
                TripDetailsRequested(trip.id),
              );
            },
            icon: const Icon(Icons.info_outline_rounded, size: 16),
            label: const Text('Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (trip.paymentMode == local_models.PaymentMode.cash &&
            trip.paymentStatus == local_models.PaymentStatus.pending)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<TripHistoryBloc>().add(
                  TripCashCollected(trip.id, trip.amount),
                );
              },
              icon: const Icon(Icons.money_rounded, size: 16),
              label: const Text('Mark Collected'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(local_models.BookingStatus status) {
    switch (status) {
      case local_models.BookingStatus.completed:
        return AppColors.success;
      case local_models.BookingStatus.cancelled:
        return AppColors.error;
      case local_models.BookingStatus.started:
        return AppColors.warning;
      case local_models.BookingStatus.accepted:
        return AppColors.cyan;
      case local_models.BookingStatus.pending:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(local_models.BookingStatus status) {
    switch (status) {
      case local_models.BookingStatus.completed:
        return 'Completed';
      case local_models.BookingStatus.cancelled:
        return 'Cancelled';
      case local_models.BookingStatus.started:
        return 'In Progress';
      case local_models.BookingStatus.accepted:
        return 'Accepted';
      case local_models.BookingStatus.pending:
        return 'Pending';
    }
  }

  Color _getPaymentMethodColor(local_models.PaymentMode method) {
    switch (method) {
      case local_models.PaymentMode.cash:
        return AppColors.warning;
      case local_models.PaymentMode.online:
        return AppColors.primary;
      case local_models.PaymentMode.card:
        return AppColors.cyan;
      case local_models.PaymentMode.wallet:
        return AppColors.success;
    }
  }

  IconData _getPaymentMethodIcon(local_models.PaymentMode method) {
    switch (method) {
      case local_models.PaymentMode.cash:
        return Icons.money_rounded;
      case local_models.PaymentMode.online:
        return Icons.payment_rounded;
      case local_models.PaymentMode.card:
        return Icons.credit_card_rounded;
      case local_models.PaymentMode.wallet:
        return Icons.account_balance_wallet_rounded;
    }
  }

  String _getPaymentMethodText(local_models.PaymentMode method) {
    switch (method) {
      case local_models.PaymentMode.cash:
        return 'Cash';
      case local_models.PaymentMode.online:
        return 'Online';
      case local_models.PaymentMode.card:
        return 'Card';
      case local_models.PaymentMode.wallet:
        return 'Wallet';
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
    trip_repo.BookingStatus? status;
    local_models.PaymentMode? paymentMode;
    DateTime? startDate;
    DateTime? endDate;

    // Convert status filter
    switch (_selectedStatusFilter) {
      case 'Completed':
        status = trip_repo.BookingStatus.completed;
        break;
      case 'Cancelled':
        status = trip_repo.BookingStatus.cancelled;
        break;
      case 'Pending':
        status = trip_repo.BookingStatus.pending;
        break;
    }

    // Convert payment filter
    switch (_selectedPaymentFilter) {
      case 'Cash':
        paymentMode = local_models.PaymentMode.cash;
        break;
      case 'Online':
        paymentMode = local_models.PaymentMode.online;
        break;
      case 'Card':
        paymentMode = local_models.PaymentMode.card;
        break;
      case 'Wallet':
        paymentMode = local_models.PaymentMode.wallet;
        break;
    }

    // Convert date filter
    final now = DateTime.now();
    switch (_selectedDateFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = now;
        break;
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        endDate = now;
        break;
    }

    context.read<TripHistoryBloc>().add(
      TripHistoryFilterChanged(
        status: status,
        startDate: startDate,
        endDate: endDate,
        paymentMode: paymentMode,
      ),
    );
  }
}
