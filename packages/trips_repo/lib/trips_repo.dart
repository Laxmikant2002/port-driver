library trips_repo;

// Export your trips repository implementation here

class DeliveryRequest {
  final String? id;
  final String? pickupLocation;
  final String? dropoffLocation;
  final double? estimatedPay;
  final double? distance;
  final String? type;
  final DateTime? requestedTime;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final String? status;

  const DeliveryRequest({
    this.id,
    this.pickupLocation,
    this.dropoffLocation,
    this.estimatedPay,
    this.distance,
    this.type,
    this.requestedTime,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.status,
  });

  DeliveryRequest copyWith({
    String? id,
    String? pickupLocation,
    String? dropoffLocation,
    double? estimatedPay,
    double? distance,
    String? type,
    DateTime? requestedTime,
    String? customerName,
    String? customerPhone,
    String? notes,
    String? status,
  }) {
    return DeliveryRequest(
      id: id ?? this.id,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      estimatedPay: estimatedPay ?? this.estimatedPay,
      distance: distance ?? this.distance,
      type: type ?? this.type,
      requestedTime: requestedTime ?? this.requestedTime,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TripsRepo {
  // Add your trips repository methods and properties here
}
