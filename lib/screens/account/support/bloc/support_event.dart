part of 'support_bloc.dart';

/// Base class for all Support events
sealed class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when support data is loaded
final class SupportLoaded extends SupportEvent {
  const SupportLoaded();

  @override
  String toString() => 'SupportLoaded()';
}

/// Event triggered when support subject is changed
final class SupportSubjectChanged extends SupportEvent {
  const SupportSubjectChanged(this.subject);

  final String subject;

  @override
  List<Object> get props => [subject];

  @override
  String toString() => 'SupportSubjectChanged(subject: $subject)';
}

/// Event triggered when support message is changed
final class SupportMessageChanged extends SupportEvent {
  const SupportMessageChanged(this.message);

  final String message;

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'SupportMessageChanged(message: $message)';
}

/// Event triggered when support priority is changed
final class SupportPriorityChanged extends SupportEvent {
  const SupportPriorityChanged(this.priority);

  final String priority;

  @override
  List<Object> get props => [priority];

  @override
  String toString() => 'SupportPriorityChanged(priority: $priority)';
}

/// Event triggered when attachment is added
final class SupportAttachmentAdded extends SupportEvent {
  const SupportAttachmentAdded(this.filePath);

  final String filePath;

  @override
  List<Object> get props => [filePath];

  @override
  String toString() => 'SupportAttachmentAdded(filePath: $filePath)';
}

/// Event triggered when attachment is removed
final class SupportAttachmentRemoved extends SupportEvent {
  const SupportAttachmentRemoved(this.index);

  final int index;

  @override
  List<Object> get props => [index];

  @override
  String toString() => 'SupportAttachmentRemoved(index: $index)';
}

/// Event triggered when support ticket is submitted
final class SupportSubmitted extends SupportEvent {
  const SupportSubmitted();

  @override
  String toString() => 'SupportSubmitted()';
}

/// Event triggered when support ticket is viewed
final class SupportTicketViewed extends SupportEvent {
  const SupportTicketViewed(this.ticketId);

  final String ticketId;

  @override
  List<Object> get props => [ticketId];

  @override
  String toString() => 'SupportTicketViewed(ticketId: $ticketId)';
}

/// Event triggered when support ticket is closed
final class SupportTicketClosed extends SupportEvent {
  const SupportTicketClosed(this.ticketId);

  final String ticketId;

  @override
  List<Object> get props => [ticketId];

  @override
  String toString() => 'SupportTicketClosed(ticketId: $ticketId)';
}
