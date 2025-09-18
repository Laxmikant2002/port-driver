part of 'insurance_bloc.dart';

abstract class InsuranceEvent extends Equatable {
  const InsuranceEvent();

  @override
  List<Object> get props => [];
}

class InsuranceImageChanged extends InsuranceEvent {
  const InsuranceImageChanged(this.imagePath);
  final String imagePath;
  @override
  List<Object> get props => [imagePath];
}

class InsurancePolicyNumberChanged extends InsuranceEvent {
  const InsurancePolicyNumberChanged(this.policyNumber);
  final String policyNumber;
  @override
  List<Object> get props => [policyNumber];
}

class InsuranceExpiryDateChanged extends InsuranceEvent {
  const InsuranceExpiryDateChanged(this.expiryDate);
  final String expiryDate;
  @override
  List<Object> get props => [expiryDate];
}

class InsuranceSubmitted extends InsuranceEvent {
  const InsuranceSubmitted();
}
