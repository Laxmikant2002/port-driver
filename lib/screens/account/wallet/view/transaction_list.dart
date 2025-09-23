import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_repo/finance_repo.dart';

import '../bloc/wallet_bloc.dart';

class TransactionList extends StatelessWidget {
  final WalletState state;

  const TransactionList({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, h:mm a');

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final transaction = state.transactions[index];
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: _TransactionIcon(type: transaction.type),
                title: Text(
                  transaction.description ?? 'Transaction',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  dateFormat.format(transaction.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                trailing: Text(
                  NumberFormat.currency(symbol: '₹').format(transaction.amount),
                  style: TextStyle(
                    color: transaction.type == TransactionType.earning ? Colors.green : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Divider(color: Colors.grey[200]),
            ],
          );
        },
        childCount: state.transactions.length,
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  final TransactionType type;

  const _TransactionIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    Color backgroundColor;

    switch (type) {
      case TransactionType.earning:
        icon = Icons.arrow_upward;
        color = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
        break;
      case TransactionType.withdrawal:
        icon = Icons.arrow_downward;
        color = Colors.orange;
        backgroundColor = Colors.orange.withOpacity(0.1);
        break;
      default:
        icon = Icons.swap_horiz;
        color = Colors.blue;
        backgroundColor = Colors.blue.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}