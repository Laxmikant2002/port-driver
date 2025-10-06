import 'package:driver/app/bloc/driver_status_bloc.dart';
import 'package:driver/widgets/colors.dart';
import 'package:driver_status/driver_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkAreaSelectionScreen extends StatefulWidget {
  const WorkAreaSelectionScreen({super.key});

  @override
  State<WorkAreaSelectionScreen> createState() => _WorkAreaSelectionScreenState();
}

class _WorkAreaSelectionScreenState extends State<WorkAreaSelectionScreen> {
  List<WorkArea> _availableWorkAreas = [];
  WorkArea? _selectedWorkArea;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkAreas();
  }

  Future<void> _loadWorkAreas() async {
    try {
      final bloc = context.read<DriverStatusBloc>();
      final repo = bloc.driverStatusRepo;
      final workAreas = await repo.getAvailableWorkAreas();
      
      setState(() {
        _availableWorkAreas = workAreas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load work areas: $e')),
        );
      }
    }
  }

  void _selectWorkArea(WorkArea workArea) {
    setState(() {
      _selectedWorkArea = workArea;
    });
  }

  void _confirmSelection() {
    if (_selectedWorkArea != null) {
      context.read<DriverStatusBloc>().add(WorkAreaChanged(_selectedWorkArea!));
      context.read<DriverStatusBloc>().add(const DriverStatusSubmitted());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Work Area'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _availableWorkAreas.isEmpty
              ? Center(
                  child: Text(
                    'No work areas available',
                    style: TextStyle(
                      fontSize: 16, 
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.cyan.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose your preferred work area',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select the area where you want to receive ride requests',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Work areas list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _availableWorkAreas.length,
                        itemBuilder: (context, index) {
                          final workArea = _availableWorkAreas[index];
                          final isSelected = _selectedWorkArea?.id == workArea.id;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: isSelected ? 4 : 1,
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected ? AppColors.cyan : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => _selectWorkArea(workArea),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Location icon
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? AppColors.cyan.withOpacity(0.1)
                                            : AppColors.border.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: isSelected ? AppColors.cyan : AppColors.textSecondary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Work area details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            workArea.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? AppColors.cyan : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Radius: ${workArea.radius.toStringAsFixed(1)} km',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Lat: ${workArea.latitude.toStringAsFixed(4)}, Lng: ${workArea.longitude.toStringAsFixed(4)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Selection indicator
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.cyan,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: AppColors.surface,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Confirm button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _selectedWorkArea != null ? _confirmSelection : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedWorkArea != null 
                                ? AppColors.cyan 
                                : AppColors.border,
                            foregroundColor: _selectedWorkArea != null 
                                ? AppColors.surface 
                                : AppColors.textTertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 20,
                                color: _selectedWorkArea != null 
                                    ? AppColors.surface 
                                    : AppColors.textTertiary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedWorkArea != null
                                    ? 'Set Work Area'
                                    : 'Select a work area',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedWorkArea != null 
                                      ? AppColors.surface 
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
