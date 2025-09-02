import 'package:flutter/material.dart';

class CashField extends StatelessWidget {
  const CashField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,  
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        const SizedBox(height: 12),
        const Text(
          '\$25',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: const [
              Icon(Icons.attach_money, size: 20),
              SizedBox(width: 4),
              Text('Cash', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
