import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'support_event.dart';
part 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc() : super(const SupportState()) {
    on<SupportLoaded>(_onSupportLoaded);
    on<SupportSubjectChanged>(_onSupportSubjectChanged);
    on<SupportMessageChanged>(_onSupportMessageChanged);
    on<SupportPriorityChanged>(_onSupportPriorityChanged);
    on<SupportAttachmentAdded>(_onSupportAttachmentAdded);
    on<SupportAttachmentRemoved>(_onSupportAttachmentRemoved);
    on<SupportSubmitted>(_onSupportSubmitted);
    on<SupportTicketViewed>(_onSupportTicketViewed);
    on<SupportTicketClosed>(_onSupportTicketClosed);
  }

  Future<void> _onSupportLoaded(
    SupportLoaded event,
    Emitter<SupportState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // In a real implementation, this would load support data from API
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to load support data: ${error.toString()}',
      ));
    }
  }

  void _onSupportSubjectChanged(
    SupportSubjectChanged event,
    Emitter<SupportState> emit,
  ) {
    final subject = SupportSubject.dirty(event.subject);
    emit(state.copyWith(
      subject: subject,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onSupportMessageChanged(
    SupportMessageChanged event,
    Emitter<SupportState> emit,
  ) {
    final message = SupportMessage.dirty(event.message);
    emit(state.copyWith(
      message: message,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onSupportPriorityChanged(
    SupportPriorityChanged event,
    Emitter<SupportState> emit,
  ) {
    emit(state.copyWith(
      priority: event.priority,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onSupportAttachmentAdded(
    SupportAttachmentAdded event,
    Emitter<SupportState> emit,
  ) {
    final attachments = List<String>.from(state.attachments);
    attachments.add(event.filePath);
    
    emit(state.copyWith(
      attachments: attachments,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onSupportAttachmentRemoved(
    SupportAttachmentRemoved event,
    Emitter<SupportState> emit,
  ) {
    final attachments = List<String>.from(state.attachments);
    attachments.removeAt(event.index);
    
    emit(state.copyWith(
      attachments: attachments,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onSupportSubmitted(
    SupportSubmitted event,
    Emitter<SupportState> emit,
  ) async {
    // Validate all fields before submission
    final subject = SupportSubject.dirty(state.subject.value);
    final message = SupportMessage.dirty(state.message.value);

    emit(state.copyWith(
      subject: subject,
      message: message,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please complete all required fields correctly',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // In a real implementation, this would submit support ticket to API
      await Future.delayed(const Duration(milliseconds: 1000));
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to submit support ticket: ${error.toString()}',
      ));
    }
  }

  void _onSupportTicketViewed(
    SupportTicketViewed event,
    Emitter<SupportState> emit,
  ) {
    // In a real implementation, this would track ticket view
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onSupportTicketClosed(
    SupportTicketClosed event,
    Emitter<SupportState> emit,
  ) {
    // In a real implementation, this would close support ticket
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }
}
