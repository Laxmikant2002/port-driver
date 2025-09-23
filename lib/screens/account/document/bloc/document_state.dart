part of 'document_bloc.dart';

enum DrivingLicenseValidationError { empty }

class DrivingLicense extends FormzInput<String, DrivingLicenseValidationError> {
  const DrivingLicense.pure() : super.pure('');
  const DrivingLicense.dirty([super.value = '']) : super.dirty();

  @override
  DrivingLicenseValidationError? validator(String value) {
    if (value.isEmpty) return DrivingLicenseValidationError.empty;
    return null;
  }
}

enum AadhaarValidationError { empty }

class Aadhaar extends FormzInput<String, AadhaarValidationError> {
  const Aadhaar.pure() : super.pure('');
  const Aadhaar.dirty([super.value = '']) : super.dirty();

  @override
  AadhaarValidationError? validator(String value) {
    if (value.isEmpty) return AadhaarValidationError.empty;
    return null;
  }
}

enum PanValidationError { empty }

class Pan extends FormzInput<String, PanValidationError> {
  const Pan.pure() : super.pure('');
  const Pan.dirty([super.value = '']) : super.dirty();

  @override
  PanValidationError? validator(String value) {
    if (value.isEmpty) return PanValidationError.empty;
    return null;
  }
}

enum AddressProofValidationError { empty }

class AddressProof extends FormzInput<String, AddressProofValidationError> {
  const AddressProof.pure() : super.pure('');
  const AddressProof.dirty([super.value = '']) : super.dirty();

  @override
  AddressProofValidationError? validator(String value) {
    if (value.isEmpty) return AddressProofValidationError.empty;
    return null;
  }
}

enum RcBookValidationError { empty }

class RcBook extends FormzInput<String, RcBookValidationError> {
  const RcBook.pure() : super.pure('');
  const RcBook.dirty([super.value = '']) : super.dirty();

  @override
  RcBookValidationError? validator(String value) {
    if (value.isEmpty) return RcBookValidationError.empty;
    return null;
  }
}

enum InsuranceValidationError { empty }

class Insurance extends FormzInput<String, InsuranceValidationError> {
  const Insurance.pure() : super.pure('');
  const Insurance.dirty([super.value = '']) : super.dirty();

  @override
  InsuranceValidationError? validator(String value) {
    if (value.isEmpty) return InsuranceValidationError.empty;
    return null;
  }
}

/// Document state containing form data and submission status
final class DocumentState extends Equatable {
  const DocumentState({
    this.status = FormzSubmissionStatus.initial,
    this.drivingLicense = const DrivingLicense.pure(),
    this.aadhaar = const Aadhaar.pure(),
    this.pan = const Pan.pure(),
    this.addressProof = const AddressProof.pure(),
    this.rcBook = const RcBook.pure(),
    this.insurance = const Insurance.pure(),
    this.driverDocuments = const [],
    this.vehicleDocuments = const [],
    this.selectedDocument,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final DrivingLicense drivingLicense;
  final Aadhaar aadhaar;
  final Pan pan;
  final AddressProof addressProof;
  final RcBook rcBook;
  final Insurance insurance;
  final List<Document> driverDocuments;
  final List<Document> vehicleDocuments;
  final Document? selectedDocument;
  final String? errorMessage;

  /// Returns true if the form is valid and ready for submission
  bool get isValid => Formz.validate([drivingLicense, aadhaar, pan, addressProof, rcBook, insurance]);

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error
  bool get hasError => isFailure && errorMessage != null;

  /// Returns true if documents are currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns total number of documents
  int get totalDocuments => driverDocuments.length + vehicleDocuments.length;

  /// Returns number of verified documents
  int get verifiedDocuments {
    return driverDocuments.where((doc) => doc.status == DocumentStatus.verified).length +
           vehicleDocuments.where((doc) => doc.status == DocumentStatus.verified).length;
  }

  /// Returns number of pending documents
  int get pendingDocuments {
    return driverDocuments.where((doc) => doc.status == DocumentStatus.pending).length +
           vehicleDocuments.where((doc) => doc.status == DocumentStatus.pending).length;
  }

  /// Returns number of rejected documents
  int get rejectedDocuments {
    return driverDocuments.where((doc) => doc.status == DocumentStatus.rejected).length +
           vehicleDocuments.where((doc) => doc.status == DocumentStatus.rejected).length;
  }

  /// Returns true if there are pending verifications
  bool get hasPendingVerifications => pendingDocuments > 0;

  /// Returns true if there are rejected documents
  bool get hasRejectedDocuments => rejectedDocuments > 0;

  /// Returns true if all required documents are verified
  bool get allDocumentsVerified {
    final requiredDriverDocs = driverDocuments.where((doc) => _isRequiredDriverDocument(doc.type)).toList();
    final requiredVehicleDocs = vehicleDocuments.where((doc) => _isRequiredVehicleDocument(doc.type)).toList();
    
    return requiredDriverDocs.every((doc) => doc.status == DocumentStatus.verified) &&
           requiredVehicleDocs.every((doc) => doc.status == DocumentStatus.verified);
  }

  /// Returns verification completion percentage
  double get verificationProgress {
    if (totalDocuments == 0) return 0.0;
    return verifiedDocuments / totalDocuments;
  }

  /// Returns all documents combined
  List<Document> get allDocuments => [...driverDocuments, ...vehicleDocuments];

  DocumentState copyWith({
    FormzSubmissionStatus? status,
    DrivingLicense? drivingLicense,
    Aadhaar? aadhaar,
    Pan? pan,
    AddressProof? addressProof,
    RcBook? rcBook,
    Insurance? insurance,
    List<Document>? driverDocuments,
    List<Document>? vehicleDocuments,
    Document? selectedDocument,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DocumentState(
      status: status ?? this.status,
      drivingLicense: drivingLicense ?? this.drivingLicense,
      aadhaar: aadhaar ?? this.aadhaar,
      pan: pan ?? this.pan,
      addressProof: addressProof ?? this.addressProof,
      rcBook: rcBook ?? this.rcBook,
      insurance: insurance ?? this.insurance,
      driverDocuments: driverDocuments ?? this.driverDocuments,
      vehicleDocuments: vehicleDocuments ?? this.vehicleDocuments,
      selectedDocument: selectedDocument ?? this.selectedDocument,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool _isRequiredDriverDocument(DocumentType type) {
    return type == DocumentType.drivingLicense ||
           type == DocumentType.aadhaar ||
           type == DocumentType.pan;
  }

  bool _isRequiredVehicleDocument(DocumentType type) {
    return type == DocumentType.rcBook ||
           type == DocumentType.insurance;
  }

  @override
  List<Object?> get props => [
        status,
        drivingLicense,
        aadhaar,
        pan,
        addressProof,
        rcBook,
        insurance,
        driverDocuments,
        vehicleDocuments,
        selectedDocument,
        errorMessage,
      ];

  @override
  String toString() {
    return 'DocumentState('
        'status: $status, '
        'drivingLicense: $drivingLicense, '
        'aadhaar: $aadhaar, '
        'pan: $pan, '
        'addressProof: $addressProof, '
        'rcBook: $rcBook, '
        'insurance: $insurance, '
        'driverDocuments: ${driverDocuments.length}, '
        'vehicleDocuments: ${vehicleDocuments.length}, '
        'selectedDocument: $selectedDocument, '
        'errorMessage: $errorMessage'
        ')';
  }
}