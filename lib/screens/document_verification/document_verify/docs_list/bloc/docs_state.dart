part of 'docs_bloc.dart';

/// {@template docs_state}
/// Represents the state of document verification.
/// {@endtemplate}
class DocsState extends Equatable {
  /// {@macro docs_state}
  const DocsState({
    this.documents = const [],
    this.status = DocsStatus.initial,
    this.completedDocuments = 0,
    this.totalDocuments = 5,
    this.errorMessage,
  });

  /// List of all documents required for verification.
  final List<Document> documents;

  /// The current status of document verification.
  final DocsStatus status;

  /// Number of completed documents.
  final int completedDocuments;

  /// Total number of required documents.
  final int totalDocuments;

  /// Error message if any operation fails.
  final String? errorMessage;

  /// Returns the progress percentage (0.0 to 1.0).
  double get progressPercentage {
    if (totalDocuments == 0) return 0.0;
    return completedDocuments / totalDocuments;
  }

  /// Returns whether all required documents are completed.
  bool get isCompleted {
    return documents
        .where((doc) => doc.isRequired)
        .every((doc) => doc.status == DocumentStatus.verified);
  }

  /// Returns the next recommended document to upload.
  Document? get nextRecommendedDocument {
    return documents.firstWhere(
      (doc) => doc.status == DocumentStatus.pending && doc.isRequired,
      orElse: () => documents.first,
    );
  }

  /// Creates a copy of this state with the given fields replaced.
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
      errorMessage: errorMessage ?? this.errorMessage,
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
}

/// {@template docs_status}
/// Enum representing the overall status of document verification.
/// {@endtemplate}
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
