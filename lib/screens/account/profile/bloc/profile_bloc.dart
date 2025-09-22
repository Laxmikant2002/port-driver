import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required String phoneNumber}) : super(ProfileState(phoneNumber: phoneNumber)) {
    on<ProfileLoaded>(_onProfileLoaded);
    on<FullNameChanged>(_onFullNameChanged);
    on<ProfilePictureChanged>(_onProfilePictureChanged);
    on<DateOfBirthChanged>(_onDateOfBirthChanged);
    on<GenderChanged>(_onGenderChanged);
    on<PreferredLocationChanged>(_onPreferredLocationChanged);
    on<ServiceAreaChanged>(_onServiceAreaChanged);
    on<LanguagesChanged>(_onLanguagesChanged);
    on<VehicleAssigned>(_onVehicleAssigned);
    on<DriverStatusChanged>(_onDriverStatusChanged);
    on<UpdateProfile>(_onUpdateProfile);
  }

  void _onProfileLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      // TODO: Load profile data from API
      await Future<void>.delayed(const Duration(milliseconds: 800));
      
      // Mock profile data - replace with real API call in production
      final profileData = {
        'fullName': 'John Doe',
        'profilePicture': null,
        'dateOfBirth': DateTime(1990, 5, 15),
        'gender': 'Male',
        'preferredLocation': 'Mumbai',
        'serviceArea': 'Mumbai Central',
        'languagesSpoken': ['English', 'Hindi', 'Marathi'],
        'vehicleId': 'VEH001',
        'vehicleType': 'Car',
        'plateNumber': 'MH01AB1234',
        'assignedByAdmin': true,
        'driverStatus': 'offline',
        'isVerified': false,
        'rating': 0.0,
        'completedTrips': 0,
        'earningsSummary': 0.0,
      };

      final fullName = FullNameInput.dirty(profileData['fullName'] as String);
      final gender = GenderInput.dirty(profileData['gender'] as String);
      final preferredLocation = PreferredLocationInput.dirty(profileData['preferredLocation'] as String);

      emit(state.copyWith(
        fullName: fullName,
        profilePicture: profileData['profilePicture'] as String?,
        dateOfBirth: profileData['dateOfBirth'] as DateTime?,
        gender: gender,
        preferredLocation: preferredLocation,
        serviceArea: profileData['serviceArea'] as String?,
        languagesSpoken: profileData['languagesSpoken'] as List<String>,
        vehicleId: profileData['vehicleId'] as String?,
        vehicleType: profileData['vehicleType'] as String?,
        plateNumber: profileData['plateNumber'] as String?,
        assignedByAdmin: profileData['assignedByAdmin'] as bool,
        driverStatus: DriverStatus.values.firstWhere(
          (e) => e.name == profileData['driverStatus'],
          orElse: () => DriverStatus.offline,
        ),
        isVerified: profileData['isVerified'] as bool,
        rating: profileData['rating'] as double,
        completedTrips: profileData['completedTrips'] as int,
        earningsSummary: profileData['earningsSummary'] as double,
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onFullNameChanged(
    FullNameChanged event,
    Emitter<ProfileState> emit,
  ) {
    final fullName = FullNameInput.dirty(event.fullName);
    emit(state.copyWith(
      fullName: fullName,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onProfilePictureChanged(
    ProfilePictureChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      profilePicture: event.imagePath,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onDateOfBirthChanged(
    DateOfBirthChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      dateOfBirth: event.dateOfBirth,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onGenderChanged(
    GenderChanged event,
    Emitter<ProfileState> emit,
  ) {
    final gender = GenderInput.dirty(event.gender);
    emit(state.copyWith(
      gender: gender,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onPreferredLocationChanged(
    PreferredLocationChanged event,
    Emitter<ProfileState> emit,
  ) {
    final preferredLocation = PreferredLocationInput.dirty(event.preferredLocation);
    emit(state.copyWith(
      preferredLocation: preferredLocation,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onServiceAreaChanged(
    ServiceAreaChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      serviceArea: event.serviceArea,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onLanguagesChanged(
    LanguagesChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      languagesSpoken: event.languagesSpoken,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onVehicleAssigned(
    VehicleAssigned event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      vehicleId: event.vehicleId,
      vehicleType: event.vehicleType,
      plateNumber: event.plateNumber,
      assignedByAdmin: event.assignedByAdmin,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onDriverStatusChanged(
    DriverStatusChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      driverStatus: event.driverStatus,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // Validate all required fields
    final fullName = FullNameInput.dirty(state.fullName.value);
    final preferredLocation = PreferredLocationInput.dirty(state.preferredLocation.value);
    
    // Update state with validation
    emit(state.copyWith(
      fullName: fullName,
      preferredLocation: preferredLocation,
    ));
    
    // Use Formz.validate for comprehensive validation
    if (!Formz.validate([fullName, preferredLocation])) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please fix the validation errors before submitting',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress, clearError: true));
    
    try {
      // TODO: Implement profile update to API
      await Future<void>.delayed(const Duration(seconds: 2)); // Simulate API call
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

}
