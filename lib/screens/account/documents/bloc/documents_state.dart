part of 'documents_bloc.dart';

/// {@template documents_status}
/// Status of the documents loading/management.
/// {@endtemplate}
enum DocumentsStatus {
  /// Initial state
  initial,
  
  /// Loading documents
  loading,
  
  /// Documents loaded successfully
  success,
  
  /// Failed to load documents
  failure,
  
  /// Re-uploading document
  reuploading,
}

/// {@template documents_state}
/// State for documents management.
/// {@endtemplate}
final class DocumentsState extends Equatable {
  /// {@macro documents_state}
  const DocumentsState({
    this.status = DocumentsStatus.initial,
    this.documents = const [],
    this.errorMessage,
    this.selectedDocumentId,
  });

  /// The current status.
  final DocumentsStatus status;

  /// List of documents.
  final List<DocumentUpload> documents;

  /// Error message if any.
  final String? errorMessage;

  /// ID of the currently selected document.
  final String? selectedDocumentId;

  /// Returns true if documents are loading.
  bool get isLoading => status == DocumentsStatus.loading;

  /// Returns true if documents loaded successfully.
  bool get isSuccess => status == DocumentsStatus.success;

  /// Returns true if there's an error.
  bool get hasError => status == DocumentsStatus.failure && errorMessage != null;

  /// Returns true if re-uploading.
  bool get isReuploading => status == DocumentsStatus.reuploading;

  /// Returns documents that are approved.
  List<DocumentUpload> get approvedDocuments {
    return documents.where((doc) => doc.status == local_models.DocumentStatus.verified).toList();
  }

  /// Returns documents that are expired.
  List<DocumentUpload> get expiredDocuments {
    return documents.where((doc) => doc.isExpired).toList();
  }

  /// Returns documents that are rejected.
  List<DocumentUpload> get rejectedDocuments {
    return documents.where((doc) => doc.status == local_models.DocumentStatus.rejected).toList();
  }

  /// Returns documents that are expiring soon (within 30 days).
  List<DocumentUpload> get expiringSoonDocuments {
    return documents.where((doc) => doc.isExpiringSoon).toList();
  }

  /// Returns documents grouped by status.
  Map<local_models.DocumentStatus, List<DocumentUpload>> get documentsByStatus {
    final Map<local_models.DocumentStatus, List<DocumentUpload>> grouped = {};
    
    for (final doc in documents) {
      grouped.putIfAbsent(doc.status, () => []).add(doc);
    }
    
    return grouped;
  }

  /// Returns documents grouped by expiry status.
  Map<String, List<DocumentUpload>> get documentsByExpiry {
    return {
      'expired': expiredDocuments,
      'expiring_soon': expiringSoonDocuments,
      'valid': documents.where((doc) => !doc.isExpired && !doc.isExpiringSoon).toList(),
    };
  }

  /// Returns the total number of documents.
  int get totalDocuments => documents.length;

  /// Returns the number of approved documents.
  int get approvedCount => approvedDocuments.length;

  /// Returns the number of expired documents.
  int get expiredCount => expiredDocuments.length;

  /// Returns the number of rejected documents.
  int get rejectedCount => rejectedDocuments.length;

  /// Returns the number of documents expiring soon.
  int get expiringSoonCount => expiringSoonDocuments.length;

  /// Returns true if there are any expired documents.
  bool get hasExpiredDocuments => expiredCount > 0;

  /// Returns true if there are any documents expiring soon.
  bool get hasExpiringSoonDocuments => expiringSoonCount > 0;

  /// Returns true if there are any rejected documents.
  bool get hasRejectedDocuments => rejectedCount > 0;

  /// Returns the verification completion percentage.
  double get verificationProgress {
    if (totalDocuments == 0) return 0.0;
    return approvedCount / totalDocuments;
  }

  /// Creates a copy of this state with the given fields replaced.
  DocumentsState copyWith({
    DocumentsStatus? status,
    List<DocumentUpload>? documents,
    String? errorMessage,
    String? selectedDocumentId,
    bool clearError = false,
  }) {
    return DocumentsState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedDocumentId: selectedDocumentId ?? this.selectedDocumentId,
    );
  }

  @override
  List<Object?> get props => [status, documents, errorMessage, selectedDocumentId];

  @override
  String toString() {
    return 'DocumentsState('
        'status: $status, '
        'documents: ${documents.length}, '
        'errorMessage: $errorMessage, '
        'selectedDocumentId: $selectedDocumentId'
        ')';
  }
}
