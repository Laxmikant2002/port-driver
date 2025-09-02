import 'package:equatable/equatable.dart';
import 'trip_event.dart';

class TripState extends Equatable {
  final TripCategory selectedCategory;
  final bool isPaid;
  final Map<int, bool> isMarkedArrivedPressed; 
  final Map<int, bool> isContactGuestPressed; 

  const TripState({
    required this.selectedCategory,
    required this.isPaid,
    required this.isMarkedArrivedPressed,
    required this.isContactGuestPressed,
  });

  TripState copyWith({
    TripCategory? selectedCategory,
    bool? isPaid,
    Map<int, bool>? isMarkedArrivedPressed,
    Map<int, bool>? isContactGuestPressed,
  }) {
    return TripState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isPaid: isPaid ?? this.isPaid,
      isMarkedArrivedPressed: isMarkedArrivedPressed ?? this.isMarkedArrivedPressed,
      isContactGuestPressed: isContactGuestPressed ?? this.isContactGuestPressed,
    );
  }

  @override
  List<Object?> get props => [
        selectedCategory,
        isPaid,
        isMarkedArrivedPressed,
        isContactGuestPressed,
      ];
}
