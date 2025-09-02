import 'package:flutter/material.dart';
import 'package:driver/screens/summary/view/fields/cash_field.dart';
import 'package:driver/screens/summary/view/fields/feedbacktag_field.dart';
import 'package:driver/screens/summary/view/fields/rating_field.dart';
import 'package:driver/screens/summary/view/fields/tripdetails_field.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F2FF),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.check_circle, color: Colors.blue, size: 60),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your trip has ended',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.route, size: 20),
                      SizedBox(width: 4),
                      Text('8.2 km', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 16),
                      Icon(Icons.access_time, size: 20),
                      SizedBox(width: 4),
                      Text('20 minutes', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ), 
            const CashField(),
            const RatingField(),
            const FeedbackTagField(),
            const TripDetailsField(),
          ],
        ),
      ),
    );
  }
}
