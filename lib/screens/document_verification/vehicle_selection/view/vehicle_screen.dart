import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/colors.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_state.dart';
import '../bloc/vehicle_event.dart';
import '../models/vehicle.dart';

class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VehicleBloc()..add(const VehicleLoadRequested()),
      child: const VehicleView(),
    );
  }
}

class VehicleView extends StatelessWidget {
  const VehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state.status == VehicleStatus.success) {
            // Navigate to work location screen
            Navigator.of(context).pushReplacementNamed('/work-location');
          } else if (state.status == VehicleStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to load vehicles'),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.05),
                AppColors.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _Header(),
                Expanded(
                  child: BlocBuilder<VehicleBloc, VehicleState>(
                    builder: (context, state) {
                      if (state.status == VehicleStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      
                      if (state.status == VehicleStatus.loaded || 
                          state.status == VehicleStatus.success) {
                        return _VehicleList(vehicles: state.vehicles);
                      }
                      
                      return const Center(
                        child: Text('Failed to load vehicles'),
                      );
                    },
                  ),
                ),
                _ContinueButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Choose how you want to earn',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _VehicleList extends StatelessWidget {
  final List<Vehicle> vehicles;
  const _VehicleList({required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _VehicleCard(vehicle: vehicles[index]),
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      buildWhen: (prev, curr) => prev.selectedVehicle != curr.selectedVehicle,
      builder: (context, state) {
        final isSelected = state.selectedVehicle.value?.id == vehicle.id;
        
        return GestureDetector(
          onTap: () {
            context.read<VehicleBloc>().add(VehicleSelected(vehicle));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Vehicle Image
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        vehicle.imageAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.local_shipping,
                            size: 40,
                            color: AppColors.primary,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Vehicle Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Delivery Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Delivery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Vehicle Name
                        Text(
                          vehicle.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Price Range
                        Text(
                          vehicle.priceRange,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Dimensions
                        Text(
                          vehicle.dimensions,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Capacity and Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Capacity
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.scale,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vehicle.capacityText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Selection Circle
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade400,
                            width: 2,
                          ),
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContinueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      buildWhen: (prev, curr) => prev.isValid != curr.isValid || prev.status != curr.status,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: state.isValid
                  ? () => context.read<VehicleBloc>().add(const VehicleSelectionSubmitted())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isValid ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: state.status == VehicleStatus.loading && state.isValid
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
