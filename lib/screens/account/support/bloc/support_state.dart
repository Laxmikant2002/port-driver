part of 'support_bloc.dart';

enum SupportSubjectValidationError { empty }

class SupportSubject extends FormzInput<String, SupportSubjectValidationError> {
  const SupportSubject.pure() : super.pure('');
  const SupportSubject.dirty([super.value = '']) : super.dirty();

  @override
  SupportSubjectValidationError? validator(String value) {
    if (value.isEmpty) return SupportSubjectValidationError.empty;
    return null;
  }
}

enum SupportMessageValidationError { empty, tooShort }

class SupportMessage extends FormzInput<String, SupportMessageValidationError> {
  const SupportMessage.pure() : super.pure('');
  const SupportMessage.dirty([super.value = '']) : super.dirty();

  @override
  SupportMessageValidationError? validator(String value) {
    if (value.isEmpty) return SupportMessageValidationError.empty;
    if (value.length < 10) return SupportMessageValidationError.tooShort;
    return null;
  }
}

/// Support state containing form data and submission status
final class SupportState extends Equatable {
  const SupportState({
    this.status = FormzSubmissionStatus.initial,
    this.subject = const SupportSubject.pure(),
    this.message = const SupportMessage.pure(),
    this.priority = 'Medium',
    this.attachments = const [],
    this.supportTickets = const [],
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final SupportSubject subject;
  final SupportMessage message;
  final String priority;
  final List<String> attachments;
  final List<SupportTicket> supportTickets;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([subject, message]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns true if support data is currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns open support tickets
  List<SupportTicket> get openTickets => supportTickets.where((ticket) => ticket.status == 'Open').toList();

  /// Returns closed support tickets
  List<SupportTicket> get closedTickets => supportTickets.where((ticket) => ticket.status == 'Closed').toList();

  /// Returns total number of tickets
  int get totalTickets => supportTickets.length;

  /// Returns number of open tickets
  int get openTicketsCount => openTickets.length;

  /// Returns number of closed tickets
  int get closedTicketsCount => closedTickets.length;

  SupportState copyWith({
    FormzSubmissionStatus? status,
    SupportSubject? subject,
    SupportMessage? message,
    String? priority,
    List<String>? attachments,
    List<SupportTicket>? supportTickets,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupportState(
      status: status ?? this.status,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
      supportTickets: supportTickets ?? this.supportTickets,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        subject,
        message,
        priority,
        attachments,
        supportTickets,
        errorMessage,
      ];

  @override
  String toString() {
    return 'SupportState('
        'status: $status, '
        'subject: $subject, '
        'message: $message, '
        'priority: $priority, '
        'attachments: ${attachments.length}, '
        'supportTickets: ${supportTickets.length}, '
        'errorMessage: $errorMessage'
        ')';
  }
}

/// Model representing a support ticket
class SupportTicket extends Equatable {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.attachments = const [],
    this.response,
  });

  final String id;
  final String subject;
  final String message;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> attachments;
  final String? response;

  SupportTicket copyWith({
    String? id,
    String? subject,
    String? message,
    String? priority,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? attachments,
    String? response,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
      response: response ?? this.response,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subject,
        message,
        priority,
        status,
        createdAt,
        updatedAt,
        attachments,
        response,
      ];

  @override
  String toString() {
    return 'SupportTicket(id: $id, subject: $subject, status: $status)';
  }
}
