import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_repo/finance_repo.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({required this.financeRepo}) : super(const WalletState()) {
    on<WalletLoaded>(_onWalletLoaded);
    on<WalletRefreshed>(_onWalletRefreshed);
    on<TransactionsFiltered>(_onTransactionsFiltered);
    on<WithdrawalRequested>(_onWithdrawalRequested);
    on<WithdrawalAmountChanged>(_onWithdrawalAmountChanged);
    on<BankAccountChanged>(_onBankAccountChanged);
    on<WithdrawalNotesChanged>(_onWithdrawalNotesChanged);
  }

  final FinanceRepo financeRepo;

  Future<void> _onWalletLoaded(
    WalletLoaded event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      final balanceResponse = await financeRepo.getWalletBalance();
      final transactionsResponse = await financeRepo.getTransactions(
        limit: event.transactionLimit,
        offset: event.transactionOffset,
      );
      
      if (balanceResponse.success && balanceResponse.balance != null) {
        await financeRepo.cacheBalance(balanceResponse.balance!);
        
        final transactions = transactionsResponse.success && transactionsResponse.transactions != null
            ? transactionsResponse.transactions!
            : await financeRepo.getCachedTransactions();
        
        await financeRepo.cacheTransactions(transactions);
        
        emit(state.copyWith(
          balance: balanceResponse.balance!,
          allTransactions: transactions,
          filteredTransactions: transactions,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        // Fallback to cached data
        final cachedBalance = await financeRepo.getCachedBalance();
        final cachedTransactions = await financeRepo.getCachedTransactions();
        
        emit(state.copyWith(
          balance: cachedBalance,
          allTransactions: cachedTransactions,
          filteredTransactions: cachedTransactions,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      }
    } catch (error) {
      // Fallback to cached data
      final cachedBalance = await financeRepo.getCachedBalance();
      final cachedTransactions = await financeRepo.getCachedTransactions();
      
      emit(state.copyWith(
        balance: cachedBalance,
        allTransactions: cachedTransactions,
        filteredTransactions: cachedTransactions,
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onWalletRefreshed(
    WalletRefreshed event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Refresh wallet data to get latest information
      add(const WalletLoaded());
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Refresh error: ${error.toString()}',
      ));
    }
  }

  void _onTransactionsFiltered(
    TransactionsFiltered event,
    Emitter<WalletState> emit,
  ) {
    List<Transaction> filteredTransactions = state.allTransactions;
    
    // Apply filters
    if (event.type != null) {
      filteredTransactions = filteredTransactions.where((t) => t.type == event.type).toList();
    }
    
    if (event.status != null) {
      filteredTransactions = filteredTransactions.where((t) => t.status == event.status).toList();
    }
    
    if (event.startDate != null) {
      filteredTransactions = filteredTransactions.where((t) => t.createdAt.isAfter(event.startDate!)).toList();
    }
    
    if (event.endDate != null) {
      filteredTransactions = filteredTransactions.where((t) => t.createdAt.isBefore(event.endDate!)).toList();
    }

    emit(state.copyWith(
      filteredTransactions: filteredTransactions,
      status: FormzSubmissionStatus.success,
      clearError: true,
    ));
  }

  Future<void> _onWithdrawalRequested(
    WithdrawalRequested event,
    Emitter<WalletState> emit,
  ) async {
    // Validate withdrawal amount
    final withdrawalAmount = WithdrawalAmount.dirty(event.amount);
    final bankAccount = BankAccount.dirty(event.bankAccountId);
    
    emit(state.copyWith(
      withdrawalAmount: withdrawalAmount,
      bankAccount: bankAccount,
    ));
    
    if (!Formz.validate([withdrawalAmount, bankAccount])) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please fix validation errors before submitting',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress, clearError: true));
    
    try {
      final request = WithdrawalRequest(
        amount: event.amount,
        bankAccountId: event.bankAccountId,
        notes: event.notes,
      );

      final response = await financeRepo.requestWithdrawal(request);
      
      if (response.success) {
        // Refresh wallet after successful withdrawal
        add(const WalletRefreshed());
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to request withdrawal',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Withdrawal error: ${error.toString()}',
      ));
    }
  }

  void _onWithdrawalAmountChanged(
    WithdrawalAmountChanged event,
    Emitter<WalletState> emit,
  ) {
    final withdrawalAmount = WithdrawalAmount.dirty(event.amount);
    emit(state.copyWith(
      withdrawalAmount: withdrawalAmount,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onBankAccountChanged(
    BankAccountChanged event,
    Emitter<WalletState> emit,
  ) {
    final bankAccount = BankAccount.dirty(event.bankAccountId);
    emit(state.copyWith(
      bankAccount: bankAccount,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onWithdrawalNotesChanged(
    WithdrawalNotesChanged event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(
      withdrawalNotes: event.notes,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }
}
