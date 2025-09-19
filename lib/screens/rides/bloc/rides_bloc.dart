import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:driver/models/address.dart';
import 'package:driver/services/google_map_services.dart';
import 'package:driver/services/socket_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:formz/formz.dart';

part 'rides_event.dart';
part 'rides_state.dart';

class RidesBloc extends Bloc<RidesEvent, RidesState> {
  RidesBloc(this.socket) : super(const RidesState()) {
    on<GetInitialCurrentLocation>(_getInitialCurrentLocation);
    on<GetCurrentLocation>(_getCurrentLocation);
    on<UpdateController>(_updateController);
    on<DragMarker>(_dragMarker);
    on<AnimateCamera>(_animateCamera);
    on<GetPolylinePoints>(_getPolylinePoints);
    on<OnlineStatusChanged>(_onOnlineStatusChanged);
    on<InitializeSocket>(_initializeSocket);
  }

  final SocketService socket;

  Future<void> _initializeSocket(
    InitializeSocket event,
    Emitter<RidesState> emit,
  ) async {
    // Initialize socket connection logic here
  }

  void _onOnlineStatusChanged(
    OnlineStatusChanged event,
    Emitter<RidesState> emit,
  ) {
    emit(state.copyWith(isDriverOnline: event.isDriverOnline));

    if (event.isDriverOnline) {
      socket.connect();
      add(GetInitialCurrentLocation());
    } else {
      socket.disconnect();
    }
  }

  void _dragMarker(DragMarker event, Emitter<RidesState> emit) {
    print(event.position);
    print(event.type);
  }

  Future<void> _animateCamera(
    AnimateCamera event,
    Emitter<RidesState> emit,
  ) async {
    await state.controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: event.position,
          zoom: event.zoom,
        ),
      ),
    );
  }

  void _updateController(UpdateController event, Emitter<RidesState> emit) {
    emit(
      state.copyWith(controller: event.controller),
    );
  }

  Future<void> _getCurrentLocation(
    GetCurrentLocation event,
    Emitter<RidesState> emit,
  ) async {
    emit(state.copyWith(currentStatus: 'Loading'));

    final hasPermission = await GoogleMapServices().requestAndCheckPermission();

    if (!hasPermission) {
      emit(state.copyWith(currentStatus: 'Permission Denied'));
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      final address = await GoogleMapServices().getAddressFromCoodinate(
        LatLng(position.latitude, position.longitude),
      );

      emit(
        state.copyWith(
          currentStatus: 'Loaded',
          currentAddress: address,
          sourceAddress: address,
        ),
      );

      // Clear existing markers before adding new one
      final marker = Marker(
        markerId: const MarkerId('SourceMarker'),
        draggable: true,
        onDragEnd: (v) {
          add(DragMarker(v, 'SourceMarker'));
        },
        position: address.latLng!,
        icon: await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(30, 30)),
          'assets/images/circle_pin.png',
        ),
      );

      emit(state.copyWith(markers: [marker]));

      if (socket.socket.connected) {
        socket.updateDriverLocation({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }

      add(AnimateCamera(address.latLng!, state.zoom));
    } catch (error) {
      emit(state.copyWith(currentStatus: 'Error'));
    }
  }

  Future<void> _getInitialCurrentLocation(
    GetInitialCurrentLocation event,
    Emitter<RidesState> emit,
  ) async {
    emit(state.copyWith(currentStatus: 'Loading'));

    final address = await GoogleMapServices().getCurrentPosition();

    emit(
      state.copyWith(
        currentStatus: 'Loaded',
        currentAddress: address,
        sourceAddress: address,
      ),
    );

    // Clear existing markers before adding new one
    final marker = Marker(
      markerId: const MarkerId('SourceMarker'),
      draggable: true,
      onDragEnd: (v) {
        add(DragMarker(v, 'SourceMarker'));
      },
      position: address!.latLng!,
      icon: await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(30, 30)),
        'assets/images/circle_pin.png',
      ),
    );

    emit(state.copyWith(markers: [marker]));

    if (socket.socket.connected) {
      socket.updateDriverLocation({
        'latitude': address.latLng?.latitude,
        'longitude': address.latLng?.longitude,
      });
    }

    add(AnimateCamera(address.latLng!, state.zoom));
  }

  void _getPolylinePoints(
    GetPolylinePoints event,
    Emitter<RidesState> emit,
  ) {
    final polylines = GoogleMapServices().addPolyLine(event.polylines);
    emit(state.copyWith(polylines: polylines));
  }
}

  // Future<void> _selectSearchedAddr(
  //   SelectSearchedAddr event,
  //   Emitter<RidesState> emit,
  // ) async {
  //   print('total markers ${state.markers.length}');
  //   print('total markers ${state.markers}');
  //   final position = await GoogleMapServices()
  //       .getDetailsfromPlaceId(event.prediction.placeId);

  //   if (state.searchType == 'src') {
  //     state.sourceInputControl.text = event.prediction.description;
  //     final updatedSourceAddress = state.sourceAddress
  //         ?.copyWith(latLng: position, street: event.prediction.description);

  //     emit(
  //       state.copyWith(
  //         sourceAddress: updatedSourceAddress,
  //         predictions: const [],
  //       ),
  //     );
  //     final updatedMarkers = state.markers.map((marker) {
  //       if (marker.markerId.value == 'SourceMarker') {
  //         // Recreate the marker with the new position
  //         return marker.copyWith(
  //           positionParam: position,
  //         );
  //       }
  //       return marker;
  //     }).toList();
  //     emit(state.copyWith(markers: updatedMarkers));
  //     add(AnimateCamera(position!));
  //   }

  //   if (state.searchType == 'dst') {
  //     state.dstInputControl.text = event.prediction.description;
  //     if (state.markers.length > 1) {
  //       //destination marker present
  //       final updatedSourceAddress = state.destinationAddress
  //           ?.copyWith(latLng: position, street: event.prediction.description);

  //       emit(
  //         state.copyWith(
  //           destinationAddress: updatedSourceAddress,
  //           predictions: const [],
  //         ),
  //       );
  //       final updatedMarkers = state.markers.map((marker) {
  //         if (marker.markerId.value == 'DestinationMarker') {
  //           // Recreate the marker with the new position
  //           return marker.copyWith(
  //             positionParam: position,
  //           );
  //         }
  //         return marker;
  //       }).toList();
  //       emit(state.copyWith(markers: updatedMarkers));

  //       add(AnimateCamera(position!));
  //     } else {
  //       final address = Address(
  //         street: event.prediction.description,
  //         latLng: position,
  //         polylines: [],
  //       );
  //       emit(
  //         state.copyWith(destinationAddress: address, predictions: const []),
  //       );

  //       const markerId = 'DestinationMarker';
  //       final marker = Marker(
  //         markerId: const MarkerId(markerId),
  //         draggable: true,
  //         onDragEnd: (v) {
  //           //call the event DragMarker(v, 'src)
  //           add(DragMarker(v, 'SourceMarker'));
  //           print('Dragged marker $v');
  //         },
  //         position: position!,
  //         icon: await BitmapDescriptor.asset(
  //           ImageConfiguration.empty,
  //           ImagesAsset.pin,
  //         ),
  //       );
  //       final updatedMarkers = List<Marker>.from(state.markers)..add(marker);

  //       emit(
  //         state.copyWith(
  //           currentStatus: 'Loaded',
  //           markers: updatedMarkers,
  //         ),
  //       );

  //       add(AnimateCamera(position));
  //     }
  //   }
  // }

  // Future<void> _changeDstInput(
  //   ChangeDstInput event,
  //   Emitter<RidesState> emit,
  // ) async {
  //   emit(
  //     state.copyWith(searchType: 'dst'),
  //   );
  //   //start the search

  //   if (state.dstInputControl.text.isNotEmpty) {
  //     try {
  //       emit(state.copyWith(searching: 'Loading'));
  //       // Generate API URL based on the input
  //       final url =
  //           GoogleMapServices().generateApiUrl(state.dstInputControl.text);
  //       print('Fetching Destination predictions from: $url');

  //       // Fetch results from API
  //       final res = await GoogleMapServices().sendRequestToAPI(url);

  //       // Decode response
  //       if (res != null && res.status == 'OK') {
  //         emit(
  //           state.copyWith(predictions: res.predictions, searching: 'Loaded'),
  //         );
  //       } else {
  //         emit(state.copyWith(searching: 'destination'));
  //       }

  //       // Update predictions in the state
  //       // print(state.predictions);
  //     } catch (e) {
  //       print('Error fetching predictions: $e');
  //       // Handle errors if needed
  //     }
  //   }
  // }

  // Future<void> _changeSourceInput(
  //   ChangeSourceInput event,
  //   Emitter<RidesState> emit,
  // ) async {
  //   emit(
  //     state.copyWith(searchType: 'src'),
  //   );
  //   //start the search

  //   if (state.sourceInputControl.text.isNotEmpty) {
  //     try {
  //       emit(state.copyWith(searching: 'Loading'));
  //       // Generate API URL based on the input
  //       final url =
  //           GoogleMapServices().generateApiUrl(state.sourceInputControl.text);
  //       print('Fetching predictions from: $url');

  //       // Fetch results from API
  //       final res = await GoogleMapServices().sendRequestToAPI(url);

  //       // Decode response
  //       if (res != null && res.status == 'OK') {
  //         emit(
  //           state.copyWith(predictions: res.predictions, searching: 'Loaded'),
  //         );
  //       } else {
  //         emit(state.copyWith(searching: 'initial'));
  //       }

  //       // Update predictions in the state
  //       // print(state.predictions);
  //     } catch (e) {
  //       print('Error fetching predictions: $e');
  //       // Handle errors if needed
  //     }
  //   }
  // }

  // void _clearSrc(ClearSrc event, Emitter<RidesState> emit) {
  //   state.sourceInputControl.clear();
  //   // state.dstInputControl.clear();
  //   // emit(
  //   //   state.copyWith(
  //   //     sourceInputControl: '',
  //   //   ),
  //   // );
  // }

  // void _clearDst(ClearDst event, Emitter<RidesState> emit) {
  //   state.dstInputControl.clear();
  //   // emit(
  //   //   state.copyWith(
  //   //     dstInputControl: '',
  //   //   ),
  //   // );
  // }
