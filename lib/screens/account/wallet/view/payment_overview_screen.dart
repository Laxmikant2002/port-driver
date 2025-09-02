import 'package:api_client/api_client.dart';
import 'package:earning_repo/earning_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:driver/screens/account/wallet/bloc/payment_bloc.dart';
import 'package:driver/screens/account/wallet/view/balance_section.dart';
import 'package:earning_repo/src/models/earning_service.dart';
import 'package:driver/screens/account/wallet/view/transaction_list.dart';

class PaymentOverviewScreen extends StatelessWidget {
  const PaymentOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentBloc(
        earningService: EarningService(
          EarningRepo(ApiClient(baseUrl: BasePaths.baseUrl)), // Pass baseUrl from BasePaths
        ),
      )..add(const LoadPaymentData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state.status == FormzSubmissionStatus.inProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                BalanceSection(state: state),
                _buildTransactionFilters(context),
                if (state.transactions.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  TransactionList(state: state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      elevation: 0,
      pinned: true,
      backgroundColor: Colors.white,
      leading: const BackButton(color: Colors.black),
      title: const Text(
        'Earnings',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String? type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: false, // TODO: Add selected state
        onSelected: (selected) {
          if (type != null) {
            context.read<PaymentBloc>().add(FilterTransactions(type: type));
          }
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.black,
        labelStyle: const TextStyle(color: Colors.black87),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildTransactionFilters(BuildContext context) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Ensure Row takes minimum space
          children: [
            _buildFilterChip(context, 'All', null),
            _buildFilterChip(context, 'Earnings', 'earnings'),
            _buildFilterChip(context, 'Withdrawals', 'withdrawals'),
            _buildFilterChip(context, 'Payments', 'payments'),
          ],
        ),
      ),
    );
  }
}