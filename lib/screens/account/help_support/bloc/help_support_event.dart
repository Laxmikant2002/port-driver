part of 'help_support_bloc.dart';

/// Base class for all HelpSupport events
sealed class HelpSupportEvent extends Equatable {
  const HelpSupportEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when help support screen is loaded
final class HelpSupportLoaded extends HelpSupportEvent {
  const HelpSupportLoaded();

  @override
  String toString() => 'HelpSupportLoaded()';
}

/// Event triggered when support contact is tapped
final class SupportContactTapped extends HelpSupportEvent {
  const SupportContactTapped(this.contact);

  final SupportContact contact;

  @override
  List<Object> get props => [contact];

  @override
  String toString() => 'SupportContactTapped(contact: $contact)';
}

/// Event triggered when emergency contact is tapped
final class EmergencyContactTapped extends HelpSupportEvent {
  const EmergencyContactTapped();

  @override
  String toString() => 'EmergencyContactTapped()';
}
