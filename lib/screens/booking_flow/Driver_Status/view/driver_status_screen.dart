import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trip_repo/trip_repo.dart';
import 'package:driver/locator.dart';
import 'package:driver/services/network/socket_service.dart';
import 'package:driver/services/realtime/realtime_service.dart';
import 'package:driver_status/driver_status.dart';

import 'package:driver/app/bloc/driver_status_bloc.dart';
import '../../Ride_Matching/bloc/ride_matching_bloc.dart';
import 'modern_driver_dashboard.dart';


/// Main ride screen that displays the map and driver status controls.
class RideScreen extends StatelessWidget {
  const RideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DriverStatusBloc(
            driverStatusRepo: sl<DriverStatusRepo>(),
            realtimeService: sl<RealtimeService>(),
          )..add(const DriverStatusInitialized()),
        ),
        BlocProvider(
          create: (context) => RideMatchingBloc(
            bookingRepo: sl<TripRepo>(),
          )..add(const RideMatchingInitialized()),
        ),
      ],
      child: const ModernDriverDashboard(),
    );
  }
}