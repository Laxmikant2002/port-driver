part of 'wallet_bloc.dart';

enum BalanceValidationError { empty, invalid }

class Balance extends FormzInput<double, BalanceValidationError> {
  const Balance.pure() : super.pure(0.0);
  const Balance.dirty([super.value = 0.0]) : super.dirty();

  @override
  BalanceValidationError? validator(double value) {
    if (value < 0) return BalanceValidationError.invalid;
    return null;
  }
}

enum WithdrawalAmountValidationError { empty, invalid, insufficient }

class WithdrawalAmount extends FormzInput<String, WithdrawalAmountValidationError> {
  const WithdrawalAmount.pure() : super.pure('');
  const WithdrawalAmount.dirty([super.value = '']) : super.dirty();

  @override
  WithdrawalAmountValidationError? validator(String value) {
    if (value.isEmpty) return WithdrawalAmountValidationError.empty;
    
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return WithdrawalAmountValidationError.invalid;
    }
    
    return null;
  }
}

enum BankAccountValidationError { empty }

class BankAccount extends FormzInput<String, BankAccountValidationError> {
  const BankAccount.pure() : super.pure('');
  const BankAccount.dirty([super.value = '']) : super.dirty();

  @override
  BankAccountValidationError? validator(String value) {
    if (value.isEmpty) return BankAccountValidationError.empty;
    return null;
  }
}

/// Wallet state containing form data and submission status
final class WalletState extends Equatable {
  const WalletState({
    this.status = FormzSubmissionStatus.initial,
    this.balance = const Balance.pure(),
    this.withdrawalAmount = const WithdrawalAmount.pure(),
    this.bankAccount = const BankAccount.pure(),
    this.transactions = const [],
    this.totalEarnings = 0.0,
    this.totalWithdrawals = 0.0,
    this.availableBalance = 0.0,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final Balance balance;
  final WithdrawalAmount withdrawalAmount;
  final BankAccount bankAccount;
  final List<Transaction> transactions;
  final double totalEarnings;
  final double totalWithdrawals;
  final double availableBalance;
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

  /// Returns true if wallet data is currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns total number of transactions
  int get totalTransactions => transactions.length;

  /// Returns recent transactions (last 10)
  List<Transaction> get recentTransactions {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(10).toList();
  }

  /// Returns earnings transactions
  List<Transaction> get earningsTransactions {
    return transactions.where((t) => t.type == TransactionType.earning).toList();
  }

  /// Returns withdrawal transactions
  List<Transaction> get withdrawalTransactions {
    return transactions.where((t) => t.type == TransactionType.withdrawal).toList();
  }

  /// Returns payment transactions
  List<Transaction> get paymentTransactions {
    return transactions.where((t) => t.type == TransactionType.adjustment).toList();
  }

  /// Returns transactions grouped by date
  Map<String, List<Transaction>> get transactionsByDate {
    final Map<String, List<Transaction>> grouped = {};
    
    for (final transaction in transactions) {
      final date = transaction.createdAt.toLocal().toString().split(' ')[0];
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }
    
    // Sort transactions within each date by creation time (newest first)
    for (final transactions in grouped.values) {
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return grouped;
  }

  /// Returns transaction type distribution
  Map<TransactionType, int> get typeDistribution {
    final distribution = <TransactionType, int>{};
    
    for (final type in TransactionType.values) {
      distribution[type] = transactions.where((t) => t.type == type).length;
    }
    
    return distribution;
  }

  /// Returns true if there are any transactions
  bool get hasTransactions => transactions.isNotEmpty;

  /// Returns true if withdrawal amount is valid
  bool get canWithdraw {
    if (!isValid) return false;
    final amount = double.tryParse(withdrawalAmount.value);
    return amount != null && amount <= availableBalance;
  }

  WalletState copyWith({
    FormzSubmissionStatus? status,
    Balance? balance,
    WithdrawalAmount? withdrawalAmount,
    BankAccount? bankAccount,
    List<Transaction>? transactions,
    double? totalEarnings,
    double? totalWithdrawals,
    double? availableBalance,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      withdrawalAmount: withdrawalAmount ?? this.withdrawalAmount,
      bankAccount: bankAccount ?? this.bankAccount,
      transactions: transactions ?? this.transactions,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      availableBalance: availableBalance ?? this.availableBalance,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        balance,
        withdrawalAmount,
        bankAccount,
        transactions,
        totalEarnings,
        totalWithdrawals,
        availableBalance,
        errorMessage,
      ];

  @override
  String toString() {
    return 'WalletState('
        'status: $status, '
        'balance: $balance, '
        'withdrawalAmount: $withdrawalAmount, '
        'bankAccount: $bankAccount, '
        'transactions: ${transactions.length}, '
        'totalEarnings: $totalEarnings, '
        'totalWithdrawals: $totalWithdrawals, '
        'availableBalance: $availableBalance, '
        'errorMessage: $errorMessage'
        ')';
  }
}