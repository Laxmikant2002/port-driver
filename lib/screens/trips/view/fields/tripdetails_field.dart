import 'package:flutter/material.dart';
import 'package:driver/screens/trips/view/fields/actionbuttons_field.dart';

class TripDetailsField extends StatelessWidget {
  final String time;
  final String guestName;
  final String pickupLocation;
  final String dropLocation; // Added drop location
  final bool isPaid;
  final int tripId; 

  const TripDetailsField({
    super.key,
    required this.time,
    required this.guestName,
    required this.pickupLocation,
    required this.dropLocation, // Added drop location
    required this.isPaid,
    required this.tripId, 
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Row(
          children: [
            Expanded(
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPaid ? 'Paid' : 'Pending',
                style: TextStyle(
                  fontSize: 12,
                  color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Guest Name
        Text(
          guestName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        // Pickup Location
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.directions_car, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                pickupLocation,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Drop Location
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, size: 20, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dropLocation,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        ActionButtonsField(tripId: tripId),
      ],
    );
  }
}
