import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_repo/finance_repo.dart';

import '../../../../widgets/colors.dart';
import '../bloc/wallet_bloc.dart';

class WalletScreen extends StatelessWidget {
  final FinanceRepo financeRepo;
  
  const WalletScreen({
    Key? key,
    required this.financeRepo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletBloc(financeRepo: financeRepo)..add(const WalletDataLoaded()),
      child: const WalletView(),
    );
  }
}

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Withdrawal request submitted successfully'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          } else if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to process request'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const _HeaderSection(),
                const SizedBox(height: 24),
                const _BalanceSection(),
                const SizedBox(height: 24),
                const _WithdrawalSection(),
                const SizedBox(height: 24),
                const _TransactionsSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          // Wallet Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Header Text
          Text(
            'Wallet & Earnings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your earnings and withdrawals',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  const _BalanceSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (previous, current) => 
          previous.availableBalance != current.availableBalance ||
          previous.totalEarnings != current.totalEarnings ||
          previous.totalWithdrawals != current.totalWithdrawals,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.border.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Your current earnings and balance',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Balance Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildBalanceCard(
                        'Available Balance',
                        '₹${state.availableBalance.toStringAsFixed(2)}',
                        AppColors.success,
                        Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBalanceCard(
                        'Total Earnings',
                        '₹${state.totalEarnings.toStringAsFixed(2)}',
                        AppColors.primary,
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBalanceCard(
                  'Total Withdrawals',
                  '₹${state.totalWithdrawals.toStringAsFixed(2)}',
                  AppColors.warning,
                  Icons.trending_down,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WithdrawalSection extends StatelessWidget {
  const _WithdrawalSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.border.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.send_to_mobile,
                    color: AppColors.cyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Withdraw Funds',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Transfer money to your bank account',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Withdrawal Form
            const _WithdrawalAmountField(),
            const SizedBox(height: 24),
            const _BankAccountField(),
            const SizedBox(height: 32),
            const _WithdrawButton(),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalAmountField extends StatelessWidget {
  const _WithdrawalAmountField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (previous, current) => previous.withdrawalAmount != current.withdrawalAmount,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdrawal Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (amount) => context
                  .read<WalletBloc>()
                  .add(WalletWithdrawalAmountChanged(amount)),
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter amount to withdraw',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.currency_rupee,
                    color: AppColors.cyan,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.cyan,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorText: state.withdrawalAmount.displayError != null
                    ? _getWithdrawalAmountErrorText(state.withdrawalAmount.displayError!)
                    : null,
                errorStyle: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getWithdrawalAmountErrorText(WithdrawalAmountValidationError error) {
    switch (error) {
      case WithdrawalAmountValidationError.empty:
        return 'Amount is required';
      case WithdrawalAmountValidationError.invalid:
        return 'Enter a valid amount';
      case WithdrawalAmountValidationError.insufficient:
        return 'Insufficient balance';
    }
  }
}

class _BankAccountField extends StatelessWidget {
  const _BankAccountField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (previous, current) => previous.bankAccount != current.bankAccount,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              onChanged: (bankAccount) => context
                  .read<WalletBloc>()
                  .add(WalletBankAccountChanged(bankAccount)),
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Select bank account',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: AppColors.cyan,
                    size: 20,
                  ),
                ),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.cyan,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
                errorText: state.bankAccount.displayError != null
                    ? 'Bank account is required'
                    : null,
                errorStyle: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WithdrawButton extends StatelessWidget {
  const _WithdrawButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid ||
          previous.canWithdraw != current.canWithdraw,
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: state.canWithdraw
                ? LinearGradient(
                    colors: [AppColors.cyan, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: state.canWithdraw
                ? [
                    BoxShadow(
                      color: AppColors.cyan.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: state.canWithdraw
                ? () => context.read<WalletBloc>().add(const WalletWithdrawalSubmitted())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: state.canWithdraw ? Colors.transparent : AppColors.border,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: state.isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Processing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send,
                        size: 20,
                        color: state.canWithdraw ? Colors.white : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Withdraw Funds',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: state.canWithdraw ? Colors.white : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  const _TransactionsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (previous, current) => previous.transactions != current.transactions,
      builder: (context, state) {
        if (state.transactions.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Transactions Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your transaction history will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Your latest transaction history',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Transaction List
                ...state.recentTransactions.take(5).map((transaction) => 
                  _buildTransactionItem(transaction)
                ),
                if (state.transactions.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to full transaction history
                        },
                        child: Text(
                          'View All Transactions',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTransactionColor(transaction.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTransactionIcon(transaction.type),
              color: _getTransactionColor(transaction.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTitle(transaction.type),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.type == TransactionType.earning ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: transaction.type == TransactionType.earning 
                  ? AppColors.success 
                  : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.earning:
        return AppColors.success;
      case TransactionType.withdrawal:
        return AppColors.error;
      case TransactionType.adjustment:
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.earning:
        return Icons.trending_up;
      case TransactionType.withdrawal:
        return Icons.trending_down;
      case TransactionType.adjustment:
        return Icons.payment;
      default:
        return Icons.receipt;
    }
  }

  String _getTransactionTitle(TransactionType type) {
    switch (type) {
      case TransactionType.earning:
        return 'Earning';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.adjustment:
        return 'Payment';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
