part of 'document_upload_bloc.dart';

/// {@template document_upload_state}
/// State for the document upload flow with modern error handling.
/// {@endtemplate}
final class DocumentUploadState extends Equatable {
  /// {@macro document_upload_state}
  const DocumentUploadState({
    this.status = FormzSubmissionStatus.initial,
    this.documents = const [],
    this.error,
    this.isRetrying = false,
  });

  /// The current submission status.
  final FormzSubmissionStatus status;

  /// List of documents to be uploaded.
  final List<DocumentUpload> documents;

  /// Current error if any.
  final DocumentUploadError? error;

  /// Whether a retry operation is in progress.
  final bool isRetrying;

  /// Returns true if the form is valid and ready for submission.
  bool get isValid {
    final requiredDocs = documents.where((doc) => doc.isRequired).toList();
    return requiredDocs.every((doc) => doc.isUploaded);
  }

  /// Returns true if the form is currently being submitted.
  bool get isSubmitting => status == FormzSubmissionStatus.inProgress;

  /// Returns true if the submission was successful.
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if the submission failed.
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error.
  bool get hasError => error != null;

  /// Returns user-friendly error message.
  String? get errorMessage => error != null 
      ? DocumentUploadErrorHandler.getUserFriendlyMessage(error!) 
      : null;

  /// Returns the total number of documents.
  int get totalDocuments => documents.length;

  /// Returns the number of uploaded documents.
  int get uploadedDocuments => documents.where((doc) => doc.isUploaded).length;

  /// Returns the number of verified documents.
  int get verifiedDocuments => documents.where((doc) => doc.isVerified).length;

  /// Returns the number of pending documents.
  int get pendingDocuments => documents.where((doc) => doc.status == local_models.DocumentStatus.pending).length;

  /// Returns the number of rejected documents.
  int get rejectedDocuments => documents.where((doc) => doc.needsAttention).length;

  /// Returns the verification progress percentage.
  double get verificationProgress {
    if (totalDocuments == 0) return 0.0;
    return verifiedDocuments / totalDocuments;
  }

  /// Returns the upload progress percentage.
  double get uploadProgress {
    if (totalDocuments == 0) return 0.0;
    return uploadedDocuments / totalDocuments;
  }

  /// Returns true if there are pending verifications.
  bool get hasPendingVerifications => pendingDocuments > 0;

  /// Returns true if there are rejected documents.
  bool get hasRejectedDocuments => rejectedDocuments > 0;

  /// Returns true if all required documents are uploaded.
  bool get allRequiredDocumentsUploaded {
    final requiredDocs = documents.where((doc) => doc.isRequired).toList();
    return requiredDocs.every((doc) => doc.isUploaded);
  }

  /// Returns true if all required documents are verified.
  bool get allRequiredDocumentsVerified {
    final requiredDocs = documents.where((doc) => doc.isRequired).toList();
    return requiredDocs.every((doc) => doc.isVerified);
  }

  /// Returns the recommended next document to upload.
  DocumentUpload? get recommendedNextDocument {
    final pendingDocs = documents.where((doc) => doc.status == local_models.DocumentStatus.pending).toList();
    if (pendingDocs.isEmpty) return null;

    // Prioritize required documents
    final requiredPending = pendingDocs.where((doc) => doc.isRequired).toList();
    if (requiredPending.isNotEmpty) {
      return requiredPending.first;
    }

    return pendingDocs.first;
  }

  /// Returns documents that are currently being processed.
  List<DocumentUpload> get processingDocuments {
    return documents.where((doc) => doc.isProcessing).toList();
  }

  /// Returns documents that need attention.
  List<DocumentUpload> get documentsNeedingAttention {
    return documents.where((doc) => doc.needsAttention).toList();
  }

  /// Returns documents grouped by status.
  Map<local_models.DocumentStatus, List<DocumentUpload>> get documentsByStatus {
    final Map<local_models.DocumentStatus, List<DocumentUpload>> grouped = {};
    
    for (final doc in documents) {
      grouped.putIfAbsent(doc.status, () => []).add(doc);
    }
    
    return grouped;
  }

  /// Returns documents grouped by type.
  Map<local_models.DocumentType, DocumentUpload> get documentsByType {
    final Map<local_models.DocumentType, DocumentUpload> grouped = {};
    
    for (final doc in documents) {
      grouped[doc.type] = doc;
    }
    
    return grouped;
  }

  /// Creates a copy of this state with the given fields replaced.
  DocumentUploadState copyWith({
    FormzSubmissionStatus? status,
    List<DocumentUpload>? documents,
    DocumentUploadError? error,
    bool? isRetrying,
    bool clearError = false,
  }) {
    return DocumentUploadState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      error: clearError ? null : (error ?? this.error),
      isRetrying: isRetrying ?? this.isRetrying,
    );
  }

  @override
  List<Object?> get props => [status, documents, error, isRetrying];

  @override
  String toString() {
    return 'DocumentUploadState('
        'status: $status, '
        'documents: ${documents.length}, '
        'error: $error, '
        'isRetrying: $isRetrying'
        ')';
  }
}
