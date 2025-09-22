part of 'wallet_bloc.dart';

// Validation error enums
enum WithdrawalAmountValidationError { empty, invalid, insufficient }

enum BankAccountValidationError { empty }

// Formz input classes
class WithdrawalAmount extends FormzInput<double, WithdrawalAmountValidationError> {
  const WithdrawalAmount.pure() : super.pure(0.0);
  const WithdrawalAmount.dirty([super.value = 0.0]) : super.dirty();

  @override
  WithdrawalAmountValidationError? validator(double value) {
    if (value == 0.0) return WithdrawalAmountValidationError.empty;
    if (value < 10.0) return WithdrawalAmountValidationError.invalid;
    return null;
  }
}

class BankAccount extends FormzInput<String, BankAccountValidationError> {
  const BankAccount.pure() : super.pure('');
  const BankAccount.dirty([super.value = '']) : super.dirty();

  @override
  BankAccountValidationError? validator(String value) {
    if (value.isEmpty) return BankAccountValidationError.empty;
    return null;
  }
}

/// Wallet state containing wallet data and submission status
final class WalletState extends Equatable {
  const WalletState({
    this.balance,
    this.allTransactions = const [],
    this.filteredTransactions = const [],
    this.withdrawalAmount = const WithdrawalAmount.pure(),
    this.bankAccount = const BankAccount.pure(),
    this.withdrawalNotes = '',
    this.selectedTransactionType,
    this.selectedTransactionStatus,
    this.startDate,
    this.endDate,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final WalletBalance? balance;
  final List<Transaction> allTransactions;
  final List<Transaction> filteredTransactions;
  final WithdrawalAmount withdrawalAmount;
  final BankAccount bankAccount;
  final String withdrawalNotes;
  final TransactionType? selectedTransactionType;
  final TransactionStatus? selectedTransactionStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([withdrawalAmount, bankAccount]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns the current error message if any
  String? get error => errorMessage;

  /// Returns true if wallet data is currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns the available balance
  double get availableBalance => balance?.availableBalance ?? 0.0;

  /// Returns the pending balance
  double get pendingBalance => balance?.pendingBalance ?? 0.0;

  /// Returns total earnings
  double get totalEarnings => balance?.totalEarnings ?? 0.0;

  /// Returns total withdrawals
  double get totalWithdrawals => balance?.totalWithdrawals ?? 0.0;

  WalletState copyWith({
    WalletBalance? balance,
    List<Transaction>? allTransactions,
    List<Transaction>? filteredTransactions,
    WithdrawalAmount? withdrawalAmount,
    BankAccount? bankAccount,
    String? withdrawalNotes,
    TransactionType? selectedTransactionType,
    TransactionStatus? selectedTransactionStatus,
    DateTime? startDate,
    DateTime? endDate,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      withdrawalAmount: withdrawalAmount ?? this.withdrawalAmount,
      bankAccount: bankAccount ?? this.bankAccount,
      withdrawalNotes: withdrawalNotes ?? this.withdrawalNotes,
      selectedTransactionType: selectedTransactionType ?? this.selectedTransactionType,
      selectedTransactionStatus: selectedTransactionStatus ?? this.selectedTransactionStatus,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        balance,
        allTransactions,
        filteredTransactions,
        withdrawalAmount,
        bankAccount,
        withdrawalNotes,
        selectedTransactionType,
        selectedTransactionStatus,
        startDate,
        endDate,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'WalletState('
        'balance: $balance, '
        'allTransactions: ${allTransactions.length}, '
        'filteredTransactions: ${filteredTransactions.length}, '
        'withdrawalAmount: $withdrawalAmount, '
        'bankAccount: $bankAccount, '
        'withdrawalNotes: $withdrawalNotes, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}
