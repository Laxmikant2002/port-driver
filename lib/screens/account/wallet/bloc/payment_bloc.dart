import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:earning_repo/earning_repo.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final EarningService _earningService;

  PaymentBloc({required EarningService earningService}) 
      : _earningService = earningService,
        super(const PaymentState()) {
    on<LoadPaymentData>(_onLoadPaymentData);
    on<InitiateWithdrawal>(_onInitiateWithdrawal);
    on<FilterTransactions>(_onFilterTransactions);
  }

  Future<void> _onLoadPaymentData(
    LoadPaymentData event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final driverId = await _getDriverId(); // Fetch driverId dynamically
      if (driverId == null) {
        throw Exception('Driver ID is missing');
      }

      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      
      final earnings = await _earningService.getWeeklyEarnings(
        EarningRequest(
          driverId: driverId,
          startDate: startDate,
          endDate: now,
        ),
      );
      
      final withdrawals = await _earningService.getWithdrawalHistory(
        EarningRequest(
          driverId: driverId,
          startDate: startDate,
          endDate: now,
        ),
      );

      final totalEarnings = _earningService.calculateTotalEarnings(earnings);
      final totalWithdrawals = _earningService.calculateTotalWithdrawals(withdrawals);
      final availableBalance = totalEarnings - totalWithdrawals;

      // Convert earnings and withdrawals to transactions
      final transactions = [
        ...earnings.map((e) => Transaction(
              id: e.id,
              amount: e.amount,
              type: 'earnings',
              status: e.status,
              method: e.paymentMethod,
              date: e.date,
              note: 'Trip #${e.tripId}',
            )),
        ...withdrawals.map((w) => Transaction(
              id: w.id,
              amount: w.amount,
              type: 'withdrawals',
              status: w.status,
              method: w.paymentMethod,
              date: w.date,
              note: 'Withdrawal',
            )),
      ]..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending

      emit(state.copyWith(
        totalEarnings: totalEarnings,
        totalWithdrawals: totalWithdrawals,
        availableBalance: availableBalance,
        transactions: transactions,
        status: FormzSubmissionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: 'Failed to load payment data: $e',
      ));
    }
  }

  Future<String?> _getDriverId() async {
    // TODO: Replace with actual logic to fetch driver ID from authentication service
    return 'current_driver_id';
  }

  Future<void> _onInitiateWithdrawal(
    InitiateWithdrawal event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final driverId = await _getDriverId(); // Fetch driverId dynamically
      if (driverId == null) {
        throw Exception('Driver ID is missing');
      }

      await _earningService.requestWithdrawal(
        WithdrawalRequest(
          driverId: driverId,
          amount: event.amount,
          paymentMethod: event.paymentMethod,
          bankAccountId: event.bankAccountId,
        ),
      );
      add(const LoadPaymentData()); // Reload data after withdrawal
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        error: 'Withdrawal failed: $e',
      ));
    }
  }

  Future<void> _onFilterTransactions(
    FilterTransactions event,
    Emitter<PaymentState> emit,
  ) async {
    if (event.type == null) {
      add(const LoadPaymentData()); // Reload all transactions
      return;
    }

    final filteredTransactions = state.transactions
        .where((transaction) => transaction.type == event.type)
        .toList();

    emit(state.copyWith(transactions: filteredTransactions));
  }
}