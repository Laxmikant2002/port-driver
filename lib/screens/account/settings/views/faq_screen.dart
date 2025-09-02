import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<Map<String, String>> questionAnswer = [
    {
      'question': 'How do I start a ride?',
      'answer': 'To start a ride, simply open the app, tap "Start Ride" and follow the on-screen instructions.'
    },
    {
      'question': 'How do I update my profile?',
      'answer': 'Go to Account > Profile, then tap the edit icon to update your information.'
    },
    {
      'question': 'How do I contact support?',
      'answer': 'You can contact support through the Support section in the app or email us at support@smartdrive.tech'
    },
    {
      'question': 'How do payments work?',
      'answer': 'Payments are processed automatically after each ride through our secure payment system.'
    },
    {
      'question': 'What if I have an emergency during a ride?',
      'answer': 'Use the emergency button in the app to contact emergency services and our support team immediately.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FAQs',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ...questionAnswer.map((qa) => _buildFaqItem(qa)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, String> qa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          qa['question']!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        iconColor: Colors.black,
        collapsedIconColor: Colors.black,
        children: [
          Text(
            qa['answer']!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}