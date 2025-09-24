import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/support_contact.dart';
import '../data/support_data.dart';

part 'help_support_event.dart';
part 'help_support_state.dart';

class HelpSupportBloc extends Bloc<HelpSupportEvent, HelpSupportState> {
  HelpSupportBloc() : super(const HelpSupportState()) {
    on<HelpSupportLoaded>(_onHelpSupportLoaded);
    on<SupportContactTapped>(_onSupportContactTapped);
    on<EmergencyContactTapped>(_onEmergencyContactTapped);
  }

  void _onHelpSupportLoaded(
    HelpSupportLoaded event,
    Emitter<HelpSupportState> emit,
  ) {
    emit(state.copyWith(
      supportContacts: SupportData.supportContacts,
      emergencyContact: SupportData.emergencyContact,
      status: FormzSubmissionStatus.success,
      clearError: true,
    ));
  }


  void _onSupportContactTapped(
    SupportContactTapped event,
    Emitter<HelpSupportState> emit,
  ) {
    emit(state.copyWith(
      selectedContact: event.contact,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onEmergencyContactTapped(
    EmergencyContactTapped event,
    Emitter<HelpSupportState> emit,
  ) {
    emit(state.copyWith(
      selectedContact: state.emergencyContact,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }
}
