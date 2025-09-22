import 'package:equatable/equatable.dart';
import 'booking.dart';

/// Booking response model for API responses
class BookingResponse extends Equatable {
  const BookingResponse({
    required this.success,
    this.message,
    this.booking,
    this.bookings,
  });

  final bool success;
  final String? message;
  final Booking? booking;
  final List<Booking>? bookings;

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      booking: json['booking'] != null
          ? Booking.fromJson(json['booking'] as Map<String, dynamic>)
          : null,
      bookings: json['bookings'] != null
          ? (json['bookings'] as List<dynamic>)
              .map((e) => Booking.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'booking': booking?.toJson(),
      'bookings': bookings?.map((e) => e.toJson()).toList(),
    };
  }

  BookingResponse copyWith({
    bool? success,
    String? message,
    Booking? booking,
    List<Booking>? bookings,
  }) {
    return BookingResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      booking: booking ?? this.booking,
      bookings: bookings ?? this.bookings,
    );
  }

  @override
  List<Object?> get props => [success, message, booking, bookings];

  @override
  String toString() {
    return 'BookingResponse(success: $success, message: $message, booking: $booking, bookings: ${bookings?.length})';
  }
}
