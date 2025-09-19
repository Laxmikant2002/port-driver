part of 'work_bloc.dart';

/// Base class for all work location events
sealed class WorkEvent extends Equatable {
  const WorkEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when work locations need to be loaded
final class WorkLocationLoaded extends WorkEvent {
  const WorkLocationLoaded();

  @override
  String toString() => 'WorkLocationLoaded()';
}

/// Event triggered when a work location is selected
final class WorkLocationSelected extends WorkEvent {
  const WorkLocationSelected(this.location);

  final WorkLocation location;

  @override
  List<Object?> get props => [location];

  @override
  String toString() => 'WorkLocationSelected(location: ${location.name})';
}

/// Event triggered when the referral code is changed
final class ReferralCodeChanged extends WorkEvent {
  const ReferralCodeChanged(this.referralCode);

  final String referralCode;

  @override
  List<Object?> get props => [referralCode];

  @override
  String toString() => 'ReferralCodeChanged(referralCode: $referralCode)';
}

/// Event triggered when the work location form is submitted
final class WorkFormSubmitted extends WorkEvent {
  const WorkFormSubmitted();

  @override
  String toString() => 'WorkFormSubmitted()';
}
