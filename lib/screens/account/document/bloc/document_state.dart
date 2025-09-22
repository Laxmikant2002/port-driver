part of 'document_bloc.dart';

/// Document state containing document data and submission status
final class DocumentState extends Equatable {
  const DocumentState({
    this.driverDocuments = const [],
    this.vehicleDocuments = const [],
    this.selectedDocument,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final List<Document> driverDocuments;
  final List<Document> vehicleDocuments;
  final Document? selectedDocument;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  /// Returns true if documents are currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns true if documents were loaded successfully
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if document operation failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error message
  bool get hasError => isFailure && errorMessage != null;

  /// Returns the current error message if any
  String? get error => errorMessage;

  /// Returns true if the form is currently being submitted
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

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
    List<Document>? driverDocuments,
    List<Document>? vehicleDocuments,
    Document? selectedDocument,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DocumentState(
      driverDocuments: driverDocuments ?? this.driverDocuments,
      vehicleDocuments: vehicleDocuments ?? this.vehicleDocuments,
      selectedDocument: selectedDocument ?? this.selectedDocument,
      status: status ?? this.status,
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
        driverDocuments,
        vehicleDocuments,
        selectedDocument,
        status,
        errorMessage,
      ];

  @override
  String toString() {
    return 'DocumentState('
        'driverDocuments: ${driverDocuments.length}, '
        'vehicleDocuments: ${vehicleDocuments.length}, '
        'selectedDocument: $selectedDocument, '
        'status: $status, '
        'errorMessage: $errorMessage'
        ')';
  }
}