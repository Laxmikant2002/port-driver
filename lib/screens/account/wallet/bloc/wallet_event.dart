part of 'wallet_bloc.dart';

/// Base class for all Wallet events
sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when balance is changed
final class WalletBalanceChanged extends WalletEvent {
  const WalletBalanceChanged(this.balance);

  final double balance;

  @override
  List<Object> get props => [balance];

  @override
  String toString() => 'WalletBalanceChanged(balance: $balance)';
}

/// Event triggered when withdrawal amount is changed
final class WalletWithdrawalAmountChanged extends WalletEvent {
  const WalletWithdrawalAmountChanged(this.amount);

  final String amount;

  @override
  List<Object> get props => [amount];

  @override
  String toString() => 'WalletWithdrawalAmountChanged(amount: $amount)';
}

/// Event triggered when bank account is changed
final class WalletBankAccountChanged extends WalletEvent {
  const WalletBankAccountChanged(this.bankAccount);

  final String bankAccount;

  @override
  List<Object> get props => [bankAccount];

  @override
  String toString() => 'WalletBankAccountChanged(bankAccount: $bankAccount)';
}

/// Event triggered when withdrawal form is submitted
final class WalletWithdrawalSubmitted extends WalletEvent {
  const WalletWithdrawalSubmitted({this.notes});

  final String? notes;

  @override
  List<Object> get props => [notes ?? ''];

  @override
  String toString() => 'WalletWithdrawalSubmitted(notes: $notes)';
}

/// Event triggered when wallet data is loaded
final class WalletDataLoaded extends WalletEvent {
  const WalletDataLoaded();

  @override
  String toString() => 'WalletDataLoaded()';
}

/// Event triggered when transactions are loaded
final class WalletTransactionsLoaded extends WalletEvent {
  const WalletTransactionsLoaded({
    this.limit,
    this.offset,
    this.type,
  });

  final int? limit;
  final int? offset;
  final TransactionType? type;

  @override
  List<Object> get props => [limit ?? 0, offset ?? 0, type ?? ''];

  @override
  String toString() => 'WalletTransactionsLoaded(limit: $limit, offset: $offset, type: $type)';
}

/// Event triggered when wallet data is refreshed
final class WalletRefreshRequested extends WalletEvent {
  const WalletRefreshRequested();

  @override
  String toString() => 'WalletRefreshRequested()';
}