import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver/screens/account/addvehicle/bloc/addvehicle_bloc.dart';
import 'package:driver/screens/account/addvehicle/widgets/vehicle_slotcardwidget.dart';

class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddVehicleBloc()..add(LoadVehicles()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Your Vehicles',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<AddVehicleBloc, AddVehicleState>(
          builder: (context, state) {
            if (state is AddVehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AddVehicleLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.vehicles.length + 1, // Add 1 for the "Add New Vehicle" button
                itemBuilder: (context, index) {
                  if (index < state.vehicles.length) {
                    final vehicle = state.vehicles[index];
                    return VehicleSlotCardWidget(
                      vehicleName: vehicle.name,
                      vehicleNumber: vehicle.number,
                      vehicleYear: vehicle.year,
                      vehicleType: vehicle.type,
                      photoPath: vehicle.photoPath,
                      onViewDetails: () {
                        
                      },
                    );
                  } else {
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Implement your logic for adding a new vehicle here
                            
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            'Add New Vehicle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            } else if (state is AddVehicleError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
