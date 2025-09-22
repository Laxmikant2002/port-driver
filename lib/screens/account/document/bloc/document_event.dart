part of 'document_bloc.dart';

/// Base class for all Document events
sealed class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when documents are loaded
final class DocumentsLoaded extends DocumentEvent {
  const DocumentsLoaded();

  @override
  String toString() => 'DocumentsLoaded()';
}

/// Event triggered when a document is selected for viewing/editing
final class DocumentSelected extends DocumentEvent {
  const DocumentSelected(this.document);

  final Document document;

  @override
  List<Object> get props => [document];

  @override
  String toString() => 'DocumentSelected(document: $document)';
}

/// Event triggered when a document is uploaded
final class DocumentUploaded extends DocumentEvent {
  const DocumentUploaded({
    required this.documentType,
    required this.filePath,
    this.fileName,
    this.metadata,
  });

  final DocumentType documentType;
  final String filePath;
  final String? fileName;
  final Map<String, dynamic>? metadata;

  @override
  List<Object> get props => [documentType, filePath, fileName ?? '', metadata ?? {}];

  @override
  String toString() => 'DocumentUploaded(documentType: $documentType, filePath: $filePath)';
}

/// Event triggered when a document is deleted
final class DocumentDeleted extends DocumentEvent {
  const DocumentDeleted(this.documentId);

  final String documentId;

  @override
  List<Object> get props => [documentId];

  @override
  String toString() => 'DocumentDeleted(documentId: $documentId)';
}

/// Event triggered when document upload is retried
final class DocumentRetryUpload extends DocumentEvent {
  const DocumentRetryUpload({
    required this.documentType,
    required this.filePath,
    this.fileName,
    this.metadata,
  });

  final DocumentType documentType;
  final String filePath;
  final String? fileName;
  final Map<String, dynamic>? metadata;

  @override
  List<Object> get props => [documentType, filePath, fileName ?? '', metadata ?? {}];

  @override
  String toString() => 'DocumentRetryUpload(documentType: $documentType, filePath: $filePath)';
}

/// Event triggered when document status is refreshed
final class DocumentStatusRefreshed extends DocumentEvent {
  const DocumentStatusRefreshed();

  @override
  String toString() => 'DocumentStatusRefreshed()';
}