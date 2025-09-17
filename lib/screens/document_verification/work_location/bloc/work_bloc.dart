import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../models/work_location.dart';

part 'work_event.dart';
part 'work_state.dart';

enum ReferralCodeValidationError { 
  invalid 
}

class ReferralCode extends FormzInput<String, ReferralCodeValidationError> {
  /// Pure referral code input.
  const ReferralCode.pure() : super.pure('');
  
  /// Dirty referral code input.
  const ReferralCode.dirty([super.value = '']) : super.dirty();

  static final RegExp _referralCodeRegExp = RegExp(r'^[a-zA-Z0-9]*$');

  @override
  ReferralCodeValidationError? validator(String value) {
    if (value.isNotEmpty && !_referralCodeRegExp.hasMatch(value)) {
      return ReferralCodeValidationError.invalid;
    }
    return null;
  }
}

/// {@template work_location_input}
/// A Formz input for work location selection validation.
/// {@endtemplate}
class WorkLocationInput extends FormzInput<WorkLocation?, String> {
  /// Pure work location input.
  const WorkLocationInput.pure() : super.pure(null);
  
  /// Dirty work location input.
  const WorkLocationInput.dirty([super.value]) : super.dirty();

  @override
  String? validator(WorkLocation? value) {
    if (value == null) return 'Please select a work location';
    return null;
  }
}

/// {@template work_bloc}
/// BLoC responsible for managing work location selection and referral code.
/// {@endtemplate}
class WorkBloc extends Bloc<WorkEvent, WorkState> {
  /// {@macro work_bloc}
  WorkBloc() : super(const WorkState()) {
    on<WorkLocationLoaded>(_onWorkLocationLoaded);
    on<WorkLocationSelected>(_onWorkLocationSelected);
    on<ReferralCodeChanged>(_onReferralCodeChanged);
    on<WorkFormSubmitted>(_onWorkFormSubmitted);
  }

  /// Handles loading available work locations.
  Future<void> _onWorkLocationLoaded(
    WorkLocationLoaded event,
    Emitter<WorkState> emit,
  ) async {
    try {
      // Simulate API call to fetch work locations
      final locations = await _getWorkLocations();
      
      emit(state.copyWith(
        locations: locations,
        status: FormzSubmissionStatus.initial,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to load work locations: $error',
      ));
    }
  }

  /// Handles work location selection.
  void _onWorkLocationSelected(
    WorkLocationSelected event,
    Emitter<WorkState> emit,
  ) {
    final workLocationInput = WorkLocationInput.dirty(event.location);
    
    emit(state.copyWith(
      selectedLocation: event.location,
      workLocationInput: workLocationInput,
      isValid: Formz.validate([
        workLocationInput,
        state.referralCode,
      ]),
    ));
  }

  /// Handles referral code changes.
  void _onReferralCodeChanged(
    ReferralCodeChanged event,
    Emitter<WorkState> emit,
  ) {
    final referralCode = ReferralCode.dirty(event.referralCode);
    
    emit(state.copyWith(
      referralCode: referralCode,
      isValid: Formz.validate([
        state.workLocationInput,
        referralCode,
      ]),
    ));
  }

  /// Handles form submission.
  Future<void> _onWorkFormSubmitted(
    WorkFormSubmitted event,
    Emitter<WorkState> emit,
  ) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Simulate API call to submit work location and referral code
      await _submitWorkLocation(
        location: state.selectedLocation!,
        referralCode: state.referralCode.value,
      );

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to submit work location: $error',
      ));
    }
  }

  /// Simulates fetching work locations from API.
  Future<List<WorkLocation>> _getWorkLocations() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // Only Maharashtra cities
    return [
      const WorkLocation(
        id: 'mumbai',
        name: 'Mumbai',
        state: 'Maharashtra',
      ),
      const WorkLocation(
        id: 'pune',
        name: 'Pune',
        state: 'Maharashtra',
      ),
      const WorkLocation(
        id: 'nanded',
        name: 'Nanded',
        state: 'Maharashtra',
      ),
      const WorkLocation(
        id: 'nagpur',
        name: 'Nagpur',
        state: 'Maharashtra',
      ),
      // Add more Maharashtra cities as needed
    ];
  }

  /// Simulates submitting work location to API.
  Future<void> _submitWorkLocation({
    required WorkLocation location,
    required String referralCode,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    
    // In a real app, this would make an API call
    // For now, we'll just simulate success
  }
}
