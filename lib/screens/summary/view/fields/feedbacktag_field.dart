import 'package:flutter/material.dart';

class FeedbackTagField extends StatelessWidget {
  const FeedbackTagField({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Fantastic Ride',
            style: TextStyle(color: Colors.white),
          ),
        ),
        _feedbackTag('Hygienic'),
        _feedbackTag('Unpleasant Experience'),
        _feedbackTag('Too Good'),
        _feedbackTag('Below Expectation'),
      ],
    );
  }

  Widget _feedbackTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
