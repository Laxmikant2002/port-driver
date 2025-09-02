import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/screens/trips/bloc/trip_bloc.dart';
import 'package:driver/screens/trips/bloc/trip_event.dart';
import 'package:driver/screens/trips/bloc/trip_state.dart';

class ActionButtonsField extends StatelessWidget {
  final int tripId; 

  const ActionButtonsField({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
final isMarkedArrivedPressed = state.isMarkedArrivedPressed[tripId] ?? false;
        final isContactGuestPressed = state.isContactGuestPressed[tripId] ?? false;

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMarkedArrivedPressed ? Colors.blue : Colors.grey[300],
                    foregroundColor: isMarkedArrivedPressed ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    context.read<TripBloc>().add(MarkArrivedPressed(tripId: tripId));
                    // Simulate button press and revert after 1 second
                    Future.delayed(const Duration(seconds: 1), () {
                      context.read<TripBloc>().add(MarkArrivedReleased(tripId: tripId));
                    });
                  },
                  child: const Text('Marked Arrived'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isContactGuestPressed ? Colors.blue : Colors.grey[300],
                    foregroundColor: isContactGuestPressed ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    context.read<TripBloc>().add(ContactGuestPressed(tripId: tripId));
                    // Simulate button press and revert after 1 second
                    Future.delayed(const Duration(seconds: 1), () {
                      context.read<TripBloc>().add(ContactGuestReleased(tripId: tripId)); // Trigger the release event
                    });
                  },
                  child: const Text('Contact Guest'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
