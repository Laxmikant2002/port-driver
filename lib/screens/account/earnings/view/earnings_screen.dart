import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver/models/driver_earnings.dart';
import 'package:driver/models/booking.dart';

import '../bloc/earnings_bloc.dart';
import 'earnings_summary_card.dart';
import 'cash_trips_section.dart';
import 'payout_section.dart';
import 'trip_breakdown_section.dart';

/// Driver Earnings Screen - shows comprehensive earnings breakdown
class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EarningsBloc(
        financeRepo: context.read(),
        bookingRepo: context.read(),
      )..add(const EarningsInitialized()),
      child: const EarningsView(),
    );
  }
}

class EarningsView extends StatelessWidget {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Earnings'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.read<EarningsBloc>().add(
              const EarningsRefreshed(),
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) {
          if (state.status == FormzSubmissionStatus.initial ||
              state.status == FormzSubmissionStatus.inProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == FormzSubmissionStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Failed to load earnings',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<EarningsBloc>().add(
                      const EarningsRefreshed(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<EarningsBloc>().add(const EarningsRefreshed());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter tabs
                  _buildFilterTabs(context, state),
                  const SizedBox(height: 16),
                  
                  // Earnings summary
                  if (state.currentEarnings != null)
                    EarningsSummaryCard(earnings: state.currentEarnings!),
                  const SizedBox(height: 16),
                  
                  // Cash trips section
                  if (state.cashTrips.isNotEmpty)
                    CashTripsSection(
                      cashTrips: state.cashTrips,
                      pendingAmount: state.pendingCashAmount,
                      collectedToday: state.cashCollectedToday,
                    ),
                  const SizedBox(height: 16),
                  
                  // Payout section
                  if (state.currentEarnings != null)
                    PayoutSection(earnings: state.currentEarnings!),
                  const SizedBox(height: 16),
                  
                  // Trip breakdown
                  if (state.recentTrips.isNotEmpty)
                    TripBreakdownSection(trips: state.recentTrips),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, EarningsState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: EarningsFilter.values.map((filter) {
          if (filter == EarningsFilter.custom) return const SizedBox.shrink();
          
          final isSelected = state.currentFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                // Handle filter change
                // For now, we'll just update the filter
                // In a real implementation, you'd dispatch appropriate events
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  filter.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}