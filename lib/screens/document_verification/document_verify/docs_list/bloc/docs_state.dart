part of 'docs_bloc.dart';

/// Document verification state containing data and status
final class DocsState extends Equatable {
  const DocsState({
    this.documents = const [],
    this.status = DocsStatus.initial,
    this.completedDocuments = 0,
    this.totalDocuments = 5,
    this.errorMessage,
  });

  final List<Document> documents;
  final DocsStatus status;
  final int completedDocuments;
  final int totalDocuments;
  final String? errorMessage;

  /// Returns the progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (totalDocuments == 0) return 0.0;
    return completedDocuments / totalDocuments;
  }

  /// Returns whether all required documents are completed
  bool get isCompleted {
    return documents
        .where((doc) => doc.isRequired)
        .every((doc) => doc.status == DocumentStatus.verified);
  }

  /// Returns whether documents are being loaded
  bool get isLoading => status == DocsStatus.loading;

  /// Returns whether documents are loaded
  bool get isLoaded => status == DocsStatus.loaded;

  /// Returns whether documents are being uploaded
  bool get isUploading => status == DocsStatus.uploading;

  /// Returns whether all documents are submitted
  bool get isSubmitted => status == DocsStatus.submitted;

  /// Returns whether verification is completed
  bool get isVerificationCompleted => status == DocsStatus.completed;

  /// Returns whether there's an error
  bool get hasError => status == DocsStatus.failure && errorMessage != null;

  /// Returns the next recommended document to upload
  Document? get nextRecommendedDocument {
    try {
      return documents.firstWhere(
        (doc) => doc.status == DocumentStatus.pending && doc.isRequired,
      );
    } catch (e) {
      return documents.isNotEmpty ? documents.first : null;
    }
  }

  DocsState copyWith({
    List<Document>? documents,
    DocsStatus? status,
    int? completedDocuments,
    int? totalDocuments,
    String? errorMessage,
  }) {
    return DocsState(
      documents: documents ?? this.documents,
      status: status ?? this.status,
      completedDocuments: completedDocuments ?? this.completedDocuments,
      totalDocuments: totalDocuments ?? this.totalDocuments,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        documents,
        status,
        completedDocuments,
        totalDocuments,
        errorMessage,
      ];

  @override
  String toString() {
    return 'DocsState('
        'documents: ${documents.length}, '
        'status: $status, '
        'completedDocuments: $completedDocuments, '
        'totalDocuments: $totalDocuments, '
        'errorMessage: $errorMessage'
        ')';
  }
}

/// Enum representing the overall status of document verification
enum DocsStatus {
  /// Initial state
  initial,
  
  /// Loading documents
  loading,
  
  /// Documents loaded successfully
  loaded,
  
  /// Uploading a document
  uploading,
  
  /// All documents submitted for verification
  submitted,
  
  /// All documents verified successfully
  completed,
  
  /// An error occurred
  failure,
}
