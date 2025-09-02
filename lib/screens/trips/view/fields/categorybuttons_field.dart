import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/screens/trips/bloc/trip_bloc.dart';
import 'package:driver/screens/trips/bloc/trip_event.dart';
import 'package:driver/screens/trips/bloc/trip_state.dart';

class CategoryButtonsField extends StatelessWidget {
  const CategoryButtonsField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: TripCategory.values.map((category) {
            final isSelected = state.selectedCategory == category;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                foregroundColor: isSelected ? Colors.white : Colors.black,
              ),
              onPressed: () {
                context.read<TripBloc>().add(TripCategorySelected(category));
              },
              child: Text(_categoryLabel(category)),
            );
          }).toList(),
        );
      },
    );
  }

  String _categoryLabel(TripCategory category) {
    switch (category) {
      case TripCategory.all:
        return 'All';
      case TripCategory.scheduled:
        return 'Scheduled';
      case TripCategory.waterSports:
        return 'Water Sports';
    }
  }
}
