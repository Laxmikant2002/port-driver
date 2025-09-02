part of 'rides_bloc.dart';

abstract class RidesEvent extends Equatable {
  const RidesEvent();

  @override
  List<Object?> get props => [];
}

class GetInitialCurrentLocation extends RidesEvent {}

class GetCurrentLocation extends RidesEvent {}

class UpdateController extends RidesEvent {
  const UpdateController(this.controller);

  final GoogleMapController controller;

  @override
  List<Object?> get props => [controller];
}

class DragMarker extends RidesEvent {
  const DragMarker(this.position, this.type);

  final LatLng position;
  final String type;

  @override
  List<Object?> get props => [position, type];
}

class AnimateCamera extends RidesEvent {
  const AnimateCamera(this.position, this.zoom);

  final LatLng position;
  final double zoom;

  @override
  List<Object?> get props => [position, zoom];
}

class GetPolylinePoints extends RidesEvent {
  const GetPolylinePoints(this.polylines);

  final List<LatLng> polylines;

  @override
  List<Object?> get props => [polylines];
}

class OnlineStatusChanged extends RidesEvent {
  const OnlineStatusChanged(this.isDriverOnline);

  final bool isDriverOnline;

  @override
  List<Object?> get props => [isDriverOnline];
}

class InitializeSocket extends RidesEvent {}
