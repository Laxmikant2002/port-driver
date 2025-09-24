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

