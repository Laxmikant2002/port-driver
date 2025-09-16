part of 'work_bloc.dart';

/// {@template work_event}
/// Base class for all work location events.
/// {@endtemplate}
abstract class WorkEvent extends Equatable {
  /// {@macro work_event}
  const WorkEvent();

  @override
  List<Object?> get props => [];
}

/// {@template work_location_loaded}
/// Event triggered when work locations need to be loaded.
/// {@endtemplate}
class WorkLocationLoaded extends WorkEvent {
  /// {@macro work_location_loaded}
  const WorkLocationLoaded();
}

/// {@template work_location_selected}
/// Event triggered when a work location is selected.
/// {@endtemplate}
class WorkLocationSelected extends WorkEvent {
  /// {@macro work_location_selected}
  const WorkLocationSelected(this.location);

  /// The selected work location.
  final WorkLocation location;

  @override
  List<Object?> get props => [location];
}

/// {@template referral_code_changed}
/// Event triggered when the referral code is changed.
/// {@endtemplate}
class ReferralCodeChanged extends WorkEvent {
  /// {@macro referral_code_changed}
  const ReferralCodeChanged(this.referralCode);

  /// The new referral code value.
  final String referralCode;

  @override
  List<Object?> get props => [referralCode];
}

/// {@template work_form_submitted}
/// Event triggered when the work location form is submitted.
/// {@endtemplate}
class WorkFormSubmitted extends WorkEvent {
  /// {@macro work_form_submitted}
  const WorkFormSubmitted();
}
