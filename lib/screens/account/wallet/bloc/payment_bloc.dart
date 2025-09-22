import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:finance_repo/finance_repo.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final FinanceRepo _financeRepo;

  PaymentBloc({required FinanceRepo financeRepo}) 
      : _financeRepo = financeRepo,
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
      // Get wallet balance
      final balanceResponse = await _financeRepo.getWalletBalance();
      
      // Get transactions
      final transactionsResponse = await _financeRepo.getTransactions(
        limit: 50,
        offset: 0,
      );

      if (balanceResponse.success && balanceResponse.balance != null) {
        final balance = balanceResponse.balance!;
        final transactions = transactionsResponse.success && transactionsResponse.transactions != null
            ? transactionsResponse.transactions!
            : [];

        // Calculate totals from transactions
        double totalEarnings = 0.0;
        double totalWithdrawals = 0.0;
        
        for (final transaction in transactions) {
          if (transaction.type == TransactionType.earning) {
            totalEarnings += transaction.amount as double;
          } else if (transaction.type == TransactionType.withdrawal) {
            totalWithdrawals += transaction.amount as double;
          }
        }

        // Convert finance_repo Transaction to PaymentState Transaction
        final paymentTransactions = transactions.map((transaction) => Transaction(
          id: transaction.id.toString(),
          amount: transaction.amount as double,
          type: transaction.type.value.toString(),
          status: transaction.status.value.toString(),
          method: (transaction.description is String ? transaction.description as String : 'Unknown'),
          date: transaction.createdAt as DateTime,
          note: (transaction.description is String ? transaction.description as String : transaction.description?.toString() ?? ''),
        )).toList();

        emit(state.copyWith(
          totalEarnings: totalEarnings,
          totalWithdrawals: totalWithdrawals,
          availableBalance: balance.availableBalance,
          transactions: paymentTransactions,
          status: FormzSubmissionStatus.success,
        ));
      } else {
        // Fallback to cached data
        final cachedBalance = await _financeRepo.getCachedBalance();
        final cachedTransactions = await _financeRepo.getCachedTransactions();
        
        double totalEarnings = 0.0;
        double totalWithdrawals = 0.0;
        
        for (final transaction in cachedTransactions) {
          if (transaction.type == TransactionType.earning) {
            totalEarnings += transaction.amount;
          } else if (transaction.type == TransactionType.withdrawal) {
            totalWithdrawals += transaction.amount;
          }
        }

        // Convert finance_repo Transaction to PaymentState Transaction
        final paymentTransactions = cachedTransactions.map((transaction) => Transaction(
          id: transaction.id,
          amount: transaction.amount,
          type: transaction.type.value,
          status: transaction.status.value,
          method: transaction.description ?? 'Unknown',
          date: transaction.createdAt,
          note: transaction.description ?? '',
        )).toList();

        emit(state.copyWith(
          totalEarnings: totalEarnings,
          totalWithdrawals: totalWithdrawals,
          availableBalance: cachedBalance?.availableBalance ?? 0.0,
          transactions: paymentTransactions,
          status: FormzSubmissionStatus.success,
        ));
      }
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
      final withdrawalRequest = WithdrawalRequest(
        amount: event.amount,
        bankAccountId: event.bankAccountId,
        notes: event.notes,
      );

      final response = await _financeRepo.requestWithdrawal(withdrawalRequest);
      
      if (response.success) {
        add(const LoadPaymentData()); // Reload data after withdrawal
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          error: response.message ?? 'Withdrawal failed',
        ));
      }
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