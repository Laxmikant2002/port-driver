import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/screens/account/wallet/bloc/payment_bloc.dart';

class TransactionFilters extends StatelessWidget {
  const TransactionFilters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
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
}