part of 'rides_bloc.dart';

class RidesState extends Equatable {
  const RidesState({
    this.currentStatus = 'Idle',
    this.currentAddress,
    this.sourceAddress,
    this.destinationAddress,
    this.markers = const [],
    this.polylines = const {},
    this.controller,
    this.isDriverOnline = false,
    this.zoom = 14.0,
    this.currentLocation,
  });

  final String currentStatus;
  final Address? currentAddress;
  final Address? sourceAddress;
  final Address? destinationAddress;
  final List<Marker> markers;
  final Map<PolylineId, Polyline> polylines;
  final GoogleMapController? controller;
  final bool isDriverOnline;
  final double zoom;
  final LatLng? currentLocation;

  RidesState copyWith({
    String? currentStatus,
    Address? currentAddress,
    Address? sourceAddress,
    Address? destinationAddress,
    List<Marker>? markers,
    Map<PolylineId, Polyline>? polylines,
    GoogleMapController? controller,
    bool? isDriverOnline,
    double? zoom,
    LatLng? currentLocation,
  }) {
    return RidesState(
      currentStatus: currentStatus ?? this.currentStatus,
      currentAddress: currentAddress ?? this.currentAddress,
      sourceAddress: sourceAddress ?? this.sourceAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      controller: controller ?? this.controller,
      isDriverOnline: isDriverOnline ?? this.isDriverOnline,
      zoom: zoom ?? this.zoom,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  List<Object?> get props => [
        currentStatus,
        currentAddress,
        sourceAddress,
        destinationAddress,
        markers,
        polylines,
        controller,
        isDriverOnline,
        zoom,
        currentLocation,
      ];
}
