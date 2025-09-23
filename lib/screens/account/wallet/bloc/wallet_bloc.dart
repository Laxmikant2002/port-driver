import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_repo/finance_repo.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({required this.financeRepo}) : super(const WalletState()) {
    on<WalletBalanceChanged>(_onBalanceChanged);
    on<WalletWithdrawalAmountChanged>(_onWithdrawalAmountChanged);
    on<WalletBankAccountChanged>(_onBankAccountChanged);
    on<WalletWithdrawalSubmitted>(_onWithdrawalSubmitted);
    on<WalletDataLoaded>(_onDataLoaded);
    on<WalletTransactionsLoaded>(_onTransactionsLoaded);
    on<WalletRefreshRequested>(_onRefreshRequested);
  }

  final FinanceRepo financeRepo;

  void _onBalanceChanged(
    WalletBalanceChanged event,
    Emitter<WalletState> emit,
  ) {
    final balance = Balance.dirty(event.balance);
    emit(
      state.copyWith(
        balance: balance,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onWithdrawalAmountChanged(
    WalletWithdrawalAmountChanged event,
    Emitter<WalletState> emit,
  ) {
    final withdrawalAmount = WithdrawalAmount.dirty(event.amount);
    emit(
      state.copyWith(
        withdrawalAmount: withdrawalAmount,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onBankAccountChanged(
    WalletBankAccountChanged event,
    Emitter<WalletState> emit,
  ) {
    final bankAccount = BankAccount.dirty(event.bankAccount);
    emit(
      state.copyWith(
        bankAccount: bankAccount,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  Future<void> _onWithdrawalSubmitted(
    WalletWithdrawalSubmitted event,
    Emitter<WalletState> emit,
  ) async {
    // Validate all fields before submission
    final withdrawalAmount = WithdrawalAmount.dirty(state.withdrawalAmount.value);
    final bankAccount = BankAccount.dirty(state.bankAccount.value);

    emit(state.copyWith(
      withdrawalAmount: withdrawalAmount,
      bankAccount: bankAccount,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please complete all required fields correctly',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Create withdrawal request
      final withdrawalRequest = WithdrawalRequest(
        amount: double.tryParse(withdrawalAmount.value) ?? 0.0,
        bankAccountId: bankAccount.value,
        notes: event.notes,
      );

      // Process withdrawal using finance repo
      final response = await financeRepo.requestWithdrawal(withdrawalRequest);
      
      if (response.success) {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
        // Reload data after successful withdrawal
        add(const WalletDataLoaded());
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to process withdrawal. Please try again.',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error. Please try again.',
      ));
    }
  }

  Future<void> _onDataLoaded(
    WalletDataLoaded event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Get wallet balance
      final balanceResponse = await financeRepo.getWalletBalance();
      
      if (balanceResponse.success && balanceResponse.balance != null) {
        final balance = Balance.dirty(balanceResponse.balance!.availableBalance);
        
        emit(state.copyWith(
          balance: balance,
          availableBalance: balanceResponse.balance!.availableBalance,
          totalEarnings: balanceResponse.balance!.totalEarnings,
          totalWithdrawals: balanceResponse.balance!.totalWithdrawals,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: balanceResponse.message ?? 'Failed to load wallet data',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onTransactionsLoaded(
    WalletTransactionsLoaded event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Get transactions
      final response = await financeRepo.getTransactions(
        limit: event.limit ?? 50,
        offset: event.offset ?? 0,
        type: event.type,
      );
      
      if (response.success && response.transactions != null) {
        emit(state.copyWith(
          transactions: response.transactions!,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to load transactions',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onRefreshRequested(
    WalletRefreshRequested event,
    Emitter<WalletState> emit,
  ) async {
    // Refresh both balance and transactions
    add(const WalletDataLoaded());
    add(const WalletTransactionsLoaded());
  }
}