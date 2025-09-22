part of 'wallet_bloc.dart';

/// Base class for all Wallet events
sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when wallet is loaded
final class WalletLoaded extends WalletEvent {
  const WalletLoaded({
    this.transactionLimit,
    this.transactionOffset,
  });

  final int? transactionLimit;
  final int? transactionOffset;

  @override
  List<Object> get props => [transactionLimit ?? 0, transactionOffset ?? 0];

  @override
  String toString() => 'WalletLoaded(limit: $transactionLimit, offset: $transactionOffset)';
}

/// Event triggered when wallet is refreshed
final class WalletRefreshed extends WalletEvent {
  const WalletRefreshed();

  @override
  String toString() => 'WalletRefreshed()';
}

/// Event triggered when transactions are filtered
final class TransactionsFiltered extends WalletEvent {
  const TransactionsFiltered({
    this.type,
    this.status,
    this.startDate,
    this.endDate,
  });

  final TransactionType? type;
  final TransactionStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object> get props => [type ?? '', status ?? '', startDate ?? DateTime.now(), endDate ?? DateTime.now()];

  @override
  String toString() => 'TransactionsFiltered(type: $type, status: $status, startDate: $startDate, endDate: $endDate)';
}

/// Event triggered when withdrawal is requested
final class WithdrawalRequested extends WalletEvent {
  const WithdrawalRequested({
    required this.amount,
    required this.bankAccountId,
    this.notes,
  });

  final double amount;
  final String bankAccountId;
  final String? notes;

  @override
  List<Object> get props => [amount, bankAccountId, notes ?? ''];

  @override
  String toString() => 'WithdrawalRequested(amount: $amount, bankAccountId: $bankAccountId)';
}

/// Event triggered when withdrawal amount is changed
final class WithdrawalAmountChanged extends WalletEvent {
  const WithdrawalAmountChanged(this.amount);

  final double amount;

  @override
  List<Object> get props => [amount];

  @override
  String toString() => 'WithdrawalAmountChanged(amount: $amount)';
}

/// Event triggered when bank account is changed
final class BankAccountChanged extends WalletEvent {
  const BankAccountChanged(this.bankAccountId);

  final String bankAccountId;

  @override
  List<Object> get props => [bankAccountId];

  @override
  String toString() => 'BankAccountChanged(bankAccountId: $bankAccountId)';
}

/// Event triggered when withdrawal notes are changed
final class WithdrawalNotesChanged extends WalletEvent {
  const WithdrawalNotesChanged(this.notes);

  final String notes;

  @override
  List<Object> get props => [notes];

  @override
  String toString() => 'WithdrawalNotesChanged(notes: $notes)';
}
