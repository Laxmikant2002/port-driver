part of 'insurance_bloc.dart';

/// Base class for all Insurance events
sealed class InsuranceEvent extends Equatable {
  const InsuranceEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when insurance image is changed
final class InsuranceImageChanged extends InsuranceEvent {
  const InsuranceImageChanged(this.imagePath);
  final String imagePath;

  @override
  List<Object> get props => [imagePath];

  @override
  String toString() => 'InsuranceImageChanged(imagePath: $imagePath)';
}


/// Event triggered when insurance form is submitted
final class InsuranceSubmitted extends InsuranceEvent {
  const InsuranceSubmitted();

  @override
  String toString() => 'InsuranceSubmitted()';
}
