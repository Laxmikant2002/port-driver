import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../models/support_contact.dart';
import '../data/support_data.dart';

part 'help_support_event.dart';
part 'help_support_state.dart';

class HelpSupportBloc extends Bloc<HelpSupportEvent, HelpSupportState> {
  HelpSupportBloc() : super(const HelpSupportState()) {
    on<HelpSupportLoaded>(_onHelpSupportLoaded);
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


}
