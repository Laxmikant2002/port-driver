import 'package:flutter/material.dart';

class RatingField extends StatelessWidget {
  const RatingField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'James has rated your ride a 4 star.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Icon(
              index < 4 ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 28,
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
